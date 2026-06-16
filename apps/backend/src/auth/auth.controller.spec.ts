import { Test, TestingModule } from '@nestjs/testing';
import { UnauthorizedException } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { AuditLogService } from '../common/services/audit-log.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { Role } from '@prisma/client';

const LOGIN_RESULT = {
  access_token: 'access-tok',
  refresh_token: 'refresh-tok',
  user: { id: 'u1', email: 'p@test.com', role: Role.Patient, lab_onboarding_status: null },
};

describe('AuthController', () => {
  let controller: AuthController;

  const mockAuthService = {
    registerPatient: jest.fn(),
    registerLab: jest.fn(),
    validateUser: jest.fn(),
    login: jest.fn(),
    getCurrentUser: jest.fn(),
    refreshAccessToken: jest.fn(),
    revokeRefreshToken: jest.fn(),
  };

  const mockAuditLog = { log: jest.fn() };

  const mockRes = () => ({ cookie: jest.fn(), clearCookie: jest.fn() });

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        { provide: AuthService, useValue: mockAuthService },
        { provide: AuditLogService, useValue: mockAuditLog },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({ canActivate: () => true })
      .compile();

    controller = module.get<AuthController>(AuthController);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  // ─── POST /auth/login ────────────────────────────────────────────────────────

  describe('login', () => {
    it('sets the HTTP-only cookie and returns access_token + refresh_token in the body', async () => {
      const res = mockRes();
      mockAuthService.validateUser.mockResolvedValue({
        id: 'u1', email: 'p@test.com', role: Role.Patient,
        created_at: new Date(), updated_at: new Date(),
      });
      mockAuthService.login.mockResolvedValue(LOGIN_RESULT);

      const result = await controller.login(
        { email: 'p@test.com', password: 'password123', selectedRole: 'patient' },
        res as any,
      );

      // Cookie must be set (for web)
      expect(res.cookie).toHaveBeenCalledWith(
        'access_token',
        LOGIN_RESULT.access_token,
        expect.objectContaining({ httpOnly: true }),
      );
      // Tokens also returned in body (for mobile)
      expect(result).toMatchObject({
        access_token: LOGIN_RESULT.access_token,
        refresh_token: LOGIN_RESULT.refresh_token,
        user: expect.objectContaining({ email: 'p@test.com' }),
      });
    });

    it('throws UnauthorizedException when credentials are invalid', async () => {
      mockAuthService.validateUser.mockResolvedValue(null);

      await expect(
        controller.login(
          { email: 'bad@test.com', password: 'wrong', selectedRole: 'patient' },
          mockRes() as any,
        ),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('throws UnauthorizedException when role does not match the account', async () => {
      mockAuthService.validateUser.mockResolvedValue({ wrongRole: true as const });

      await expect(
        controller.login(
          { email: 'lab@test.com', password: 'pw', selectedRole: 'patient' },
          mockRes() as any,
        ),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('records an audit log entry on successful login', async () => {
      const res = mockRes();
      mockAuthService.validateUser.mockResolvedValue({
        id: 'u1', email: 'p@test.com', role: Role.Patient,
        created_at: new Date(), updated_at: new Date(),
      });
      mockAuthService.login.mockResolvedValue(LOGIN_RESULT);

      await controller.login(
        { email: 'p@test.com', password: 'password123', selectedRole: 'patient' },
        res as any,
      );

      expect(mockAuditLog.log).toHaveBeenCalledWith(
        'auth.login',
        expect.objectContaining({ userId: LOGIN_RESULT.user.id }),
      );
    });
  });

  // ─── POST /auth/refresh ──────────────────────────────────────────────────────

  describe('refresh', () => {
    it('delegates to authService.refreshAccessToken and returns the new token pair', async () => {
      const newPair = { access_token: 'new-access', refresh_token: 'new-refresh' };
      mockAuthService.refreshAccessToken.mockResolvedValue(newPair);

      const result = await controller.refresh({ refresh_token: 'old-refresh-tok' });

      expect(mockAuthService.refreshAccessToken).toHaveBeenCalledWith('old-refresh-tok');
      expect(result).toEqual(newPair);
    });

    it('propagates UnauthorizedException from the service when token is invalid', async () => {
      mockAuthService.refreshAccessToken.mockRejectedValue(
        new UnauthorizedException('Invalid or expired refresh token'),
      );

      await expect(controller.refresh({ refresh_token: 'bad' })).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  // ─── POST /auth/logout ───────────────────────────────────────────────────────

  describe('logout', () => {
    it('clears the auth cookie on logout', async () => {
      const res = mockRes();
      await controller.logout(res as any, {});

      expect(res.clearCookie).toHaveBeenCalledWith(
        'access_token',
        expect.objectContaining({ path: '/' }),
      );
    });

    it('revokes the refresh token when provided in the body (mobile logout)', async () => {
      const res = mockRes();
      mockAuthService.revokeRefreshToken.mockResolvedValue(undefined);

      await controller.logout(res as any, { refresh_token: 'tok-to-revoke' });

      expect(mockAuthService.revokeRefreshToken).toHaveBeenCalledWith('tok-to-revoke');
    });

    it('does not call revokeRefreshToken when no token is in the body (web logout)', async () => {
      const res = mockRes();
      await controller.logout(res as any, {});

      expect(mockAuthService.revokeRefreshToken).not.toHaveBeenCalled();
    });

    it('records an audit log entry on logout', async () => {
      const res = mockRes();
      await controller.logout(res as any, {});

      expect(mockAuditLog.log).toHaveBeenCalledWith('auth.logout', {});
    });
  });

  // ─── GET /auth/me ────────────────────────────────────────────────────────────

  describe('getMe', () => {
    it('returns the current user from the service', async () => {
      const user = { id: 'u1', email: 'p@test.com', role: Role.Patient };
      mockAuthService.getCurrentUser.mockResolvedValue(user);

      const result = await controller.getMe({ user: { id: 'u1' } } as any);

      expect(mockAuthService.getCurrentUser).toHaveBeenCalledWith('u1');
      expect(result).toEqual(user);
    });

    it('throws UnauthorizedException when no user is attached to the request', async () => {
      await expect(controller.getMe({ user: {} } as any)).rejects.toThrow(UnauthorizedException);
    });
  });
});
