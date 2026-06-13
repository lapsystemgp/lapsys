import {
  Injectable,
  ConflictException,
  ForbiddenException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { PatientRegisterDto } from './dto/patient-register.dto';
import { LabRegisterDto } from './dto/lab-register.dto';
import * as bcrypt from 'bcrypt';
import { createHash, randomBytes } from 'crypto';
import { LabOnboardingStatus, Role } from '@prisma/client';

const REFRESH_TOKEN_TTL_DAYS = 30;

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async registerPatient(registerDto: PatientRegisterDto) {
    const normalizedEmail = this.normalizeEmail(registerDto.email);
    const existingUser = await this.prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (existingUser) {
      throw new ConflictException('Email already registered');
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(registerDto.password, salt);

    const user = await this.prisma.user.create({
      data: {
        email: normalizedEmail,
        password_hash,
        role: Role.Patient,
        patient_profile: {
          create: {
            full_name: registerDto.full_name,
            phone: registerDto.phone,
            address: registerDto.address,
          },
        },
      },
      select: { id: true, email: true, role: true, created_at: true },
    });

    return user;
  }

  async registerLab(registerDto: LabRegisterDto) {
    const normalizedEmail = this.normalizeEmail(registerDto.email);
    const existingUser = await this.prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (existingUser) {
      throw new ConflictException('Email already registered');
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(registerDto.password, salt);

    const user = await this.prisma.user.create({
      data: {
        email: normalizedEmail,
        password_hash,
        role: Role.LabStaff,
        lab_profile: {
          create: {
            lab_name: registerDto.lab_name.trim(),
            address: registerDto.address.trim(),
            phone: registerDto.phone?.trim() || null,
            home_collection: registerDto.home_collection ?? false,
            accreditation: registerDto.accreditation?.trim() || null,
            turnaround_time: registerDto.turnaround_time?.trim() || null,
            onboarding_status: LabOnboardingStatus.PendingReview,
          },
        },
      },
      select: { id: true, email: true, role: true, created_at: true },
    });

    return user;
  }

  async validateUser(loginDto: LoginDto) {
    const normalizedEmail = this.normalizeEmail(loginDto.email);
    const user = await this.prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (!user) return null;
    const passwordValid = await bcrypt.compare(loginDto.password, user.password_hash);
    if (!passwordValid) return null;
    if (!this.matchesSelectedRole(user.role, loginDto.selectedRole)) {
      return { wrongRole: true as const };
    }
    const { password_hash, ...result } = user;
    return result;
  }

  private matchesSelectedRole(role: Role, selectedRole: LoginDto['selectedRole']) {
    if (selectedRole === 'patient') {
      return role === Role.Patient;
    }

    if (selectedRole === 'lab') {
      return role === Role.LabStaff;
    }

    if (selectedRole === 'admin') {
      return role === Role.Admin;
    }

    return false;
  }

  private normalizeEmail(email: string) {
    return email.trim().toLowerCase();
  }

  async login(user: { id: string; email: string; role: Role }) {
    const profile = await this.prisma.user.findUnique({
      where: { id: user.id },
      select: {
        lab_profile: { select: { onboarding_status: true } },
      },
    });

    const payload: Record<string, unknown> = {
      email: user.email,
      sub: user.id,
      role: user.role,
    };

    if (user.role === Role.LabStaff) {
      payload.lab_onboarding_status = profile?.lab_profile?.onboarding_status ?? null;
    }

    const access_token = this.jwtService.sign(payload);
    const refresh_token = await this.createRefreshToken(user.id);

    return {
      access_token,
      refresh_token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        lab_onboarding_status: payload.lab_onboarding_status ?? null,
      },
    };
  }

  async refreshAccessToken(rawRefreshToken: string) {
    const tokenHash = this.hashToken(rawRefreshToken);
    const stored = await this.prisma.refreshToken.findUnique({
      where: { token_hash: tokenHash },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            role: true,
            lab_profile: { select: { onboarding_status: true } },
          },
        },
      },
    });

    if (!stored || stored.revoked || stored.expires_at < new Date()) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    // Rotate: revoke the used token and issue a new one
    await this.prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revoked: true },
    });

    const { user } = stored;
    const payload: Record<string, unknown> = {
      email: user.email,
      sub: user.id,
      role: user.role,
    };
    if (user.role === Role.LabStaff) {
      payload.lab_onboarding_status = user.lab_profile?.onboarding_status ?? null;
    }

    const new_access_token = this.jwtService.sign(payload);
    const new_refresh_token = await this.createRefreshToken(user.id);

    return { access_token: new_access_token, refresh_token: new_refresh_token };
  }

  async revokeRefreshToken(rawRefreshToken: string) {
    const tokenHash = this.hashToken(rawRefreshToken);
    await this.prisma.refreshToken.updateMany({
      where: { token_hash: tokenHash, revoked: false },
      data: { revoked: true },
    });
  }

  async revokeAllRefreshTokensForUser(userId: string) {
    await this.prisma.refreshToken.updateMany({
      where: { user_id: userId, revoked: false },
      data: { revoked: true },
    });
  }

  private async createRefreshToken(userId: string): Promise<string> {
    const raw = randomBytes(64).toString('hex');
    const tokenHash = this.hashToken(raw);
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_TTL_DAYS);

    await this.prisma.refreshToken.create({
      data: { user_id: userId, token_hash: tokenHash, expires_at: expiresAt },
    });

    return raw;
  }

  private hashToken(raw: string): string {
    return createHash('sha256').update(raw).digest('hex');
  }

  async getCurrentUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        role: true,
        lab_profile: { select: { id: true, onboarding_status: true, lab_name: true } },
        patient_profile: { select: { id: true, full_name: true } },
      },
    });

    if (!user) {
      throw new ForbiddenException('User not found');
    }

    return user;
  }
}
