import { Test, TestingModule } from '@nestjs/testing';
import { UnauthorizedException } from '@nestjs/common';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

describe('NotificationsController', () => {
  let controller: NotificationsController;

  const mockNotificationsService = {
    registerDevice: jest.fn(),
    removeDevice: jest.fn(),
  };

  const authedReq = (userId = 'user-1') => ({ user: { id: userId } });

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [NotificationsController],
      providers: [
        { provide: NotificationsService, useValue: mockNotificationsService },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({ canActivate: () => true })
      .compile();

    controller = module.get<NotificationsController>(NotificationsController);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  // ─── POST /notifications/device ───────────────────────────────────────────

  describe('registerDevice', () => {
    it('calls NotificationsService.registerDevice with the authenticated user id and DTO', async () => {
      mockNotificationsService.registerDevice.mockResolvedValue(undefined);

      await controller.registerDevice(authedReq() as any, {
        fcm_token: 'test-fcm-token',
        platform: 'ios',
      });

      expect(mockNotificationsService.registerDevice).toHaveBeenCalledWith('user-1', {
        fcm_token: 'test-fcm-token',
        platform: 'ios',
      });
    });

    it('works for android platform', async () => {
      mockNotificationsService.registerDevice.mockResolvedValue(undefined);

      await controller.registerDevice(authedReq('user-2') as any, {
        fcm_token: 'android-token',
        platform: 'android',
      });

      expect(mockNotificationsService.registerDevice).toHaveBeenCalledWith('user-2', {
        fcm_token: 'android-token',
        platform: 'android',
      });
    });

    it('throws UnauthorizedException when no user id is on the request', async () => {
      await expect(
        controller.registerDevice({ user: {} } as any, {
          fcm_token: 'tok',
          platform: 'ios',
        }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  // ─── DELETE /notifications/device ─────────────────────────────────────────

  describe('removeDevice', () => {
    it('calls NotificationsService.removeDevice with the user id and token from the body', async () => {
      mockNotificationsService.removeDevice.mockResolvedValue(undefined);

      await controller.removeDevice(authedReq() as any, { fcm_token: 'tok-to-remove' });

      expect(mockNotificationsService.removeDevice).toHaveBeenCalledWith(
        'user-1',
        'tok-to-remove',
      );
    });

    it('throws UnauthorizedException when no user id is on the request', async () => {
      await expect(
        controller.removeDevice({ user: {} } as any, { fcm_token: 'tok' }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });
});
