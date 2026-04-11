import { Injectable, ConflictException, ForbiddenException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { PatientRegisterDto } from './dto/patient-register.dto';
import { LabRegisterDto } from './dto/lab-register.dto';
import * as bcrypt from 'bcrypt';
import { LabOnboardingStatus, Role } from '@prisma/client';

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

    if (
      user &&
      (await bcrypt.compare(loginDto.password, user.password_hash)) &&
      this.matchesSelectedRole(user.role, loginDto.selectedRole)
    ) {
      const { password_hash, ...result } = user;
      return result;
    }
    return null;
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

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        lab_onboarding_status: payload.lab_onboarding_status ?? null,
      },
    };
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
