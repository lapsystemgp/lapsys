import {
  Injectable,
  Logger,
  ConflictException,
  ForbiddenException,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { PatientRegisterDto } from './dto/patient-register.dto';
import { LabRegisterDto } from './dto/lab-register.dto';
import * as bcrypt from 'bcrypt';
import { createHash, randomBytes, randomInt } from 'crypto';
import { LabOnboardingStatus, Role } from '@prisma/client';
import { MailService } from '../mail/mail.service';

const REFRESH_TOKEN_TTL_DAYS = 30;
const OTP_TTL_MINUTES = 10;
const OTP_MAX_ATTEMPTS = 5;

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private mailService: MailService,
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

    await this.issueEmailOtpOrRollback(user.id, user.email);

    return { ...user, email_verification_required: true };
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

    await this.issueEmailOtpOrRollback(user.id, user.email);

    return { ...user, email_verification_required: true };
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
    if (!user.email_verified) {
      return { emailNotVerified: true as const, email: user.email };
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

  private hashCode(raw: string): string {
    return createHash('sha256').update(raw).digest('hex');
  }

  // Issue the OTP during registration. If sending the email fails, roll back the
  // just-created user so the signup can be retried cleanly instead of leaving an
  // orphaned, unverified account that blocks re-registration with a 409.
  private async issueEmailOtpOrRollback(userId: string, email: string): Promise<void> {
    try {
      await this.issueEmailOtp(userId, email);
    } catch (err) {
      // PatientProfile/LabProfile don't cascade on user delete, so remove them
      // first; email codes cascade with the user.
      await this.prisma
        .$transaction([
          this.prisma.patientProfile.deleteMany({ where: { user_id: userId } }),
          this.prisma.labProfile.deleteMany({ where: { user_id: userId } }),
          this.prisma.user.delete({ where: { id: userId } }),
        ])
        .catch(() => undefined);
      this.logger.error(
        `Registration rolled back for ${email}: failed to send verification email — ${
          err instanceof Error ? err.message : String(err)
        }`,
      );
      throw new ServiceUnavailableException(
        'Could not send the verification email. Please try again shortly.',
      );
    }
  }

  private async issueEmailOtp(userId: string, email: string): Promise<void> {
    const code = randomInt(100000, 1000000).toString();
    const codeHash = this.hashCode(code);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + OTP_TTL_MINUTES);

    // Delete any prior codes for this user
    await this.prisma.emailVerificationCode.deleteMany({ where: { user_id: userId } });

    await this.prisma.emailVerificationCode.create({
      data: { user_id: userId, code_hash: codeHash, expires_at: expiresAt },
    });

    await this.mailService.sendOtpEmail(email, code);
  }

  async verifyEmailOtp(
    email: string,
    code: string,
  ): Promise<ReturnType<AuthService['login']>> {
    const normalizedEmail = this.normalizeEmail(email);
    const user = await this.prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (!user) {
      throw new ForbiddenException('Invalid or expired code');
    }

    if (user.email_verified) {
      // Already verified — just issue tokens (idempotent)
      return this.login({ id: user.id, email: user.email, role: user.role });
    }

    const record = await this.prisma.emailVerificationCode.findFirst({
      where: { user_id: user.id },
      orderBy: { created_at: 'desc' },
    });

    if (!record) {
      throw new ForbiddenException('Invalid or expired code');
    }

    if (record.expires_at < new Date()) {
      throw new ForbiddenException('Verification code has expired');
    }

    if (record.attempts >= OTP_MAX_ATTEMPTS) {
      throw new ForbiddenException('Too many failed attempts. Please request a new code.');
    }

    const codeHash = this.hashCode(code);
    if (codeHash !== record.code_hash) {
      await this.prisma.emailVerificationCode.update({
        where: { id: record.id },
        data: { attempts: { increment: 1 } },
      });
      throw new ForbiddenException('Invalid or expired code');
    }

    // Success: mark email verified and clean up
    await this.prisma.user.update({
      where: { id: user.id },
      data: { email_verified: true, email_verified_at: new Date() },
    });
    await this.prisma.emailVerificationCode.deleteMany({ where: { user_id: user.id } });

    return this.login({ id: user.id, email: user.email, role: user.role });
  }

  async resendEmailOtp(email: string): Promise<{ message: string }> {
    const normalizedEmail = this.normalizeEmail(email);
    const user = await this.prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    // Always return generic success to avoid leaking whether the email exists
    if (user && !user.email_verified) {
      await this.issueEmailOtp(user.id, user.email);
    }

    return { message: 'If that email is pending verification, a new code has been sent.' };
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
