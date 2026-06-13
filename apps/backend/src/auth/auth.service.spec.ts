import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { Role } from '@prisma/client';

describe('AuthService', () => {
  let service: AuthService;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    refreshToken: {
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
  };

  const mockJwtService = {
    sign: jest.fn(() => 'test_token'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: JwtService, useValue: mockJwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ─── register ────────────────────────────────────────────────────────────────

  describe('register', () => {
    it('creates a new patient user when email is unique', async () => {
      const dto = { email: 'test@example.com', password: 'password123' };
      mockPrismaService.user.findUnique.mockResolvedValue(null);
      mockPrismaService.user.create.mockResolvedValue({
        id: '1',
        email: dto.email,
        role: Role.Patient,
        created_at: new Date(),
      });

      const result = await service.registerPatient(dto);
      expect(result.email).toEqual(dto.email);
      expect(mockPrismaService.user.create).toHaveBeenCalled();
    });

    it('normalises email casing during lab registration', async () => {
      const dto = {
        email: 'Lab@Example.com',
        password: 'password123',
        lab_name: 'Alpha Lab',
        address: 'Cairo',
      };
      mockPrismaService.user.findUnique.mockResolvedValue(null);
      mockPrismaService.user.create.mockResolvedValue({
        id: '1',
        email: 'lab@example.com',
        role: Role.LabStaff,
        created_at: new Date(),
      });

      await service.registerLab(dto);

      expect(mockPrismaService.user.findUnique).toHaveBeenCalledWith({
        where: { email: 'lab@example.com' },
      });
      expect(mockPrismaService.user.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ email: 'lab@example.com' }),
        }),
      );
    });

    it('throws ConflictException when email is already registered', async () => {
      const dto = { email: 'exist@example.com', password: 'password123' };
      mockPrismaService.user.findUnique.mockResolvedValue({ email: dto.email });

      await expect(service.registerPatient(dto)).rejects.toThrow(ConflictException);
    });
  });

  // ─── validateUser ────────────────────────────────────────────────────────────

  describe('validateUser', () => {
    it('returns user when credentials are correct', async () => {
      const dto = { email: 'test@example.com', password: 'password123', selectedRole: 'patient' as const };
      const password_hash = await bcrypt.hash(dto.password, 10);
      mockPrismaService.user.findUnique.mockResolvedValue({
        id: '1',
        email: dto.email,
        password_hash,
        role: Role.Patient,
      });

      const result = await service.validateUser(dto);
      expect(result).not.toBeNull();
      if (result && !('wrongRole' in result)) {
        expect(result.email).toEqual(dto.email);
        // @ts-expect-error password_hash must not leak
        expect(result.password_hash).toBeUndefined();
      }
    });

    it('returns null when password does not match', async () => {
      const dto = { email: 'test@example.com', password: 'wrong', selectedRole: 'patient' as const };
      const password_hash = await bcrypt.hash('correct', 10);
      mockPrismaService.user.findUnique.mockResolvedValue({
        email: dto.email,
        password_hash,
        role: Role.Patient,
      });

      expect(await service.validateUser(dto)).toBeNull();
    });

    it('returns { wrongRole: true } when selected role mismatches account role', async () => {
      const dto = { email: 'lab@example.com', password: 'password123', selectedRole: 'patient' as const };
      const password_hash = await bcrypt.hash(dto.password, 10);
      mockPrismaService.user.findUnique.mockResolvedValue({
        id: '1',
        email: dto.email,
        password_hash,
        role: Role.LabStaff,
      });

      expect(await service.validateUser(dto)).toEqual({ wrongRole: true });
    });

    it('returns admin user when selectedRole is admin', async () => {
      const dto = { email: 'admin@example.com', password: 'password123', selectedRole: 'admin' as const };
      const password_hash = await bcrypt.hash(dto.password, 10);
      mockPrismaService.user.findUnique.mockResolvedValue({
        id: 'admin-1',
        email: dto.email,
        password_hash,
        role: Role.Admin,
      });

      const result = await service.validateUser(dto);
      if (result && !('wrongRole' in result)) {
        expect(result.role).toBe(Role.Admin);
      }
    });
  });

  // ─── login ───────────────────────────────────────────────────────────────────

  describe('login', () => {
    it('returns access_token, refresh_token and user object', async () => {
      const user = { id: '1', email: 'test@example.com', role: Role.Patient };
      mockPrismaService.user.findUnique.mockResolvedValue({ lab_profile: null });
      mockPrismaService.refreshToken.create.mockResolvedValue({ id: 'rt-1' });

      const result = await service.login(user);

      expect(result.access_token).toBe('test_token');
      expect(typeof result.refresh_token).toBe('string');
      expect(result.refresh_token.length).toBeGreaterThan(0);
      expect(result.user.email).toBe(user.email);
      expect(mockPrismaService.refreshToken.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ user_id: user.id }),
        }),
      );
    });

    it('includes lab_onboarding_status in the JWT payload for LabStaff', async () => {
      const user = { id: '2', email: 'lab@example.com', role: Role.LabStaff };
      mockPrismaService.user.findUnique.mockResolvedValue({
        lab_profile: { onboarding_status: 'Active' },
      });
      mockPrismaService.refreshToken.create.mockResolvedValue({ id: 'rt-2' });

      await service.login(user);

      expect(mockJwtService.sign).toHaveBeenCalledWith(
        expect.objectContaining({ lab_onboarding_status: 'Active' }),
      );
    });
  });

  // ─── refreshAccessToken ──────────────────────────────────────────────────────

  describe('refreshAccessToken', () => {
    const RAW_TOKEN = 'valid-raw-token-64-hex-chars-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

    it('returns a new token pair and revokes the old refresh token', async () => {
      mockPrismaService.refreshToken.findUnique.mockResolvedValue({
        id: 'rt-old',
        revoked: false,
        expires_at: new Date(Date.now() + 86400_000), // expires tomorrow
        user: { id: 'u1', email: 'p@test.com', role: Role.Patient, lab_profile: null },
      });
      mockPrismaService.refreshToken.update.mockResolvedValue({ id: 'rt-old', revoked: true });
      mockPrismaService.refreshToken.create.mockResolvedValue({ id: 'rt-new' });

      const result = await service.refreshAccessToken(RAW_TOKEN);

      expect(result.access_token).toBe('test_token');
      expect(typeof result.refresh_token).toBe('string');

      // Old token must be revoked
      expect(mockPrismaService.refreshToken.update).toHaveBeenCalledWith(
        expect.objectContaining({ data: { revoked: true } }),
      );
      // A new token must be persisted
      expect(mockPrismaService.refreshToken.create).toHaveBeenCalledWith(
        expect.objectContaining({ data: expect.objectContaining({ user_id: 'u1' }) }),
      );
    });

    it('throws UnauthorizedException when token is not found', async () => {
      mockPrismaService.refreshToken.findUnique.mockResolvedValue(null);

      await expect(service.refreshAccessToken(RAW_TOKEN)).rejects.toThrow(UnauthorizedException);
    });

    it('throws UnauthorizedException when token is revoked', async () => {
      mockPrismaService.refreshToken.findUnique.mockResolvedValue({
        id: 'rt-1',
        revoked: true,
        expires_at: new Date(Date.now() + 86400_000),
        user: { id: 'u1', email: 'p@test.com', role: Role.Patient, lab_profile: null },
      });

      await expect(service.refreshAccessToken(RAW_TOKEN)).rejects.toThrow(UnauthorizedException);
    });

    it('throws UnauthorizedException when token is expired', async () => {
      mockPrismaService.refreshToken.findUnique.mockResolvedValue({
        id: 'rt-1',
        revoked: false,
        expires_at: new Date(Date.now() - 1000), // already expired
        user: { id: 'u1', email: 'p@test.com', role: Role.Patient, lab_profile: null },
      });

      await expect(service.refreshAccessToken(RAW_TOKEN)).rejects.toThrow(UnauthorizedException);
    });

    it('does not call update when token validation fails', async () => {
      mockPrismaService.refreshToken.findUnique.mockResolvedValue(null);

      await expect(service.refreshAccessToken(RAW_TOKEN)).rejects.toThrow();
      expect(mockPrismaService.refreshToken.update).not.toHaveBeenCalled();
    });
  });

  // ─── revokeRefreshToken ──────────────────────────────────────────────────────

  describe('revokeRefreshToken', () => {
    it('marks the matching token as revoked by its hash', async () => {
      const raw = 'some-raw-token';
      mockPrismaService.refreshToken.updateMany.mockResolvedValue({ count: 1 });

      await service.revokeRefreshToken(raw);

      expect(mockPrismaService.refreshToken.updateMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({ revoked: false }),
          data: { revoked: true },
        }),
      );
      // The actual stored token_hash must differ from the raw value (it is hashed)
      const callArgs = mockPrismaService.refreshToken.updateMany.mock.calls[0][0];
      expect(callArgs.where.token_hash).not.toBe(raw);
    });

    it('is idempotent — does not throw when no matching token exists', async () => {
      mockPrismaService.refreshToken.updateMany.mockResolvedValue({ count: 0 });
      await expect(service.revokeRefreshToken('nonexistent')).resolves.not.toThrow();
    });
  });

  // ─── revokeAllRefreshTokensForUser ───────────────────────────────────────────

  describe('revokeAllRefreshTokensForUser', () => {
    it('revokes every active token for the user', async () => {
      mockPrismaService.refreshToken.updateMany.mockResolvedValue({ count: 3 });

      await service.revokeAllRefreshTokensForUser('user-99');

      expect(mockPrismaService.refreshToken.updateMany).toHaveBeenCalledWith({
        where: { user_id: 'user-99', revoked: false },
        data: { revoked: true },
      });
    });
  });
});
