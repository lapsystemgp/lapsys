/**
 * Phase 0 — NotificationsService tests
 *
 * Firebase Admin SDK is mocked at the module level so tests never need real
 * FCM credentials.  The mock is set up before the service is constructed so
 * the constructor's initFirebase() path is fully controlled.
 */

// ─── Firebase mocks (must be declared before any import that touches firebase) ──
const mockSendEachForMulticast: jest.Mock = jest.fn();
const mockGetMessaging: jest.Mock = jest.fn(() => ({ sendEachForMulticast: mockSendEachForMulticast }));
const mockInitializeApp: jest.Mock = jest.fn(() => ({ name: '[DEFAULT]' } as any));
const mockGetApps: jest.Mock = jest.fn(() => [] as any[]);

jest.mock('firebase-admin/app', () => ({
  getApps: () => mockGetApps(),
  initializeApp: (options: any) => mockInitializeApp(options),
  cert: (sa: any) => sa,
}));

jest.mock('firebase-admin/messaging', () => ({
  getMessaging: (app: any) => mockGetMessaging(app),
}));

import { NotificationsService } from './notifications.service';

// ─── Prisma mock ──────────────────────────────────────────────────────────────
const prismaMock = {
  deviceToken: {
    upsert: jest.fn(),
    deleteMany: jest.fn(),
    findMany: jest.fn(),
  },
};

function buildService(): NotificationsService {
  return new NotificationsService(prismaMock as any);
}

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('NotificationsService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Default: no existing Firebase app instances
    mockGetApps.mockReturnValue([]);
  });

  // ─── FCM initialisation ────────────────────────────────────────────────────

  describe('FCM initialisation', () => {
    it('does not call initializeApp when FCM_SERVICE_ACCOUNT_JSON is not set', () => {
      delete process.env.FCM_SERVICE_ACCOUNT_JSON;
      buildService();
      expect(mockInitializeApp).not.toHaveBeenCalled();
    });

    it('calls initializeApp with parsed credentials when env var is set', () => {
      const fakeCredential = { project_id: 'testly', private_key: 'key', client_email: 'e@t.com' };
      process.env.FCM_SERVICE_ACCOUNT_JSON = JSON.stringify(fakeCredential);
      buildService();
      expect(mockInitializeApp).toHaveBeenCalledWith(
        expect.objectContaining({ credential: fakeCredential }),
      );
      delete process.env.FCM_SERVICE_ACCOUNT_JSON;
    });

    it('reuses the existing app when one is already initialised', () => {
      const existingApp = { name: '[DEFAULT]' } as any;
      mockGetApps.mockReturnValue([existingApp]);
      buildService();
      expect(mockInitializeApp).not.toHaveBeenCalled();
    });
  });

  // ─── registerDevice ────────────────────────────────────────────────────────

  describe('registerDevice', () => {
    it('upserts the device token keyed by fcm_token', async () => {
      prismaMock.deviceToken.upsert.mockResolvedValue({});
      const service = buildService();

      await service.registerDevice('user-1', { fcm_token: 'tok-abc', platform: 'ios' });

      expect(prismaMock.deviceToken.upsert).toHaveBeenCalledWith({
        where: { fcm_token: 'tok-abc' },
        update: { user_id: 'user-1', platform: 'ios' },
        create: { user_id: 'user-1', fcm_token: 'tok-abc', platform: 'ios' },
      });
    });

    it('updates the owner when the same fcm_token is re-registered by a different user', async () => {
      prismaMock.deviceToken.upsert.mockResolvedValue({});
      const service = buildService();

      await service.registerDevice('user-2', { fcm_token: 'tok-abc', platform: 'android' });

      expect(prismaMock.deviceToken.upsert).toHaveBeenCalledWith(
        expect.objectContaining({
          update: { user_id: 'user-2', platform: 'android' },
        }),
      );
    });
  });

  // ─── removeDevice ──────────────────────────────────────────────────────────

  describe('removeDevice', () => {
    it('deletes the device token scoped to the requesting user', async () => {
      prismaMock.deviceToken.deleteMany.mockResolvedValue({ count: 1 });
      const service = buildService();

      await service.removeDevice('user-1', 'tok-to-remove');

      expect(prismaMock.deviceToken.deleteMany).toHaveBeenCalledWith({
        where: { user_id: 'user-1', fcm_token: 'tok-to-remove' },
      });
    });

    it('does not throw when the token does not exist', async () => {
      prismaMock.deviceToken.deleteMany.mockResolvedValue({ count: 0 });
      const service = buildService();

      await expect(service.removeDevice('user-1', 'ghost-tok')).resolves.not.toThrow();
    });
  });

  // ─── removeAllDevicesForUser ───────────────────────────────────────────────

  describe('removeAllDevicesForUser', () => {
    it('deletes all device tokens for the user', async () => {
      prismaMock.deviceToken.deleteMany.mockResolvedValue({ count: 3 });
      const service = buildService();

      await service.removeAllDevicesForUser('user-99');

      expect(prismaMock.deviceToken.deleteMany).toHaveBeenCalledWith({
        where: { user_id: 'user-99' },
      });
    });
  });

  // ─── sendToUser — FCM disabled ─────────────────────────────────────────────

  describe('sendToUser (FCM not configured)', () => {
    beforeEach(() => {
      delete process.env.FCM_SERVICE_ACCOUNT_JSON;
    });

    it('returns without querying device tokens when FCM is disabled', async () => {
      const service = buildService();

      await service.sendToUser('user-1', { title: 'Hi', body: 'World' });

      expect(prismaMock.deviceToken.findMany).not.toHaveBeenCalled();
      expect(mockSendEachForMulticast).not.toHaveBeenCalled();
    });
  });

  // ─── sendToUser — FCM enabled ──────────────────────────────────────────────

  describe('sendToUser (FCM configured)', () => {
    beforeEach(() => {
      process.env.FCM_SERVICE_ACCOUNT_JSON = JSON.stringify({
        project_id: 'testly', private_key: 'key', client_email: 'e@t.com',
      });
    });

    afterEach(() => {
      delete process.env.FCM_SERVICE_ACCOUNT_JSON;
    });

    it('returns without calling FCM when the user has no registered devices', async () => {
      prismaMock.deviceToken.findMany.mockResolvedValue([]);
      const service = buildService();

      await service.sendToUser('user-no-devices', { title: 'Hi', body: 'There' });

      expect(mockSendEachForMulticast).not.toHaveBeenCalled();
    });

    it('sends a multicast message to all registered device tokens', async () => {
      prismaMock.deviceToken.findMany.mockResolvedValue([
        { id: 'dt-1', fcm_token: 'fcm-tok-a' },
        { id: 'dt-2', fcm_token: 'fcm-tok-b' },
      ]);
      mockSendEachForMulticast.mockResolvedValue({
        successCount: 2,
        failureCount: 0,
        responses: [{ success: true }, { success: true }],
      });
      const service = buildService();

      await service.sendToUser('user-1', {
        title: 'Booking Confirmed',
        body: 'Your booking is confirmed.',
        data: { type: 'booking_status', bookingId: 'b-1' },
      });

      expect(mockSendEachForMulticast).toHaveBeenCalledWith(
        expect.objectContaining({
          tokens: ['fcm-tok-a', 'fcm-tok-b'],
          notification: { title: 'Booking Confirmed', body: 'Your booking is confirmed.' },
          data: { type: 'booking_status', bookingId: 'b-1' },
        }),
      );
    });

    it('prunes stale tokens that FCM reports as no longer registered', async () => {
      prismaMock.deviceToken.findMany.mockResolvedValue([
        { id: 'dt-valid', fcm_token: 'tok-valid' },
        { id: 'dt-stale', fcm_token: 'tok-stale' },
      ]);
      mockSendEachForMulticast.mockResolvedValue({
        successCount: 1,
        failureCount: 1,
        responses: [
          { success: true },
          {
            success: false,
            error: { code: 'messaging/registration-token-not-registered' },
          },
        ],
      });
      prismaMock.deviceToken.deleteMany.mockResolvedValue({ count: 1 });
      const service = buildService();

      await service.sendToUser('user-1', { title: 'Test', body: 'Test' });

      expect(prismaMock.deviceToken.deleteMany).toHaveBeenCalledWith({
        where: { id: { in: ['dt-stale'] } },
      });
    });

    it('does not call deleteMany when all sends succeed', async () => {
      prismaMock.deviceToken.findMany.mockResolvedValue([{ id: 'dt-1', fcm_token: 'tok-1' }]);
      mockSendEachForMulticast.mockResolvedValue({
        successCount: 1,
        failureCount: 0,
        responses: [{ success: true }],
      });
      const service = buildService();

      await service.sendToUser('user-1', { title: 'T', body: 'B' });

      expect(prismaMock.deviceToken.deleteMany).not.toHaveBeenCalled();
    });

    it('does not throw when FCM itself throws — errors are caught internally', async () => {
      prismaMock.deviceToken.findMany.mockResolvedValue([{ id: 'dt-1', fcm_token: 'tok-1' }]);
      mockSendEachForMulticast.mockRejectedValue(new Error('FCM network error'));
      const service = buildService();

      await expect(
        service.sendToUser('user-1', { title: 'T', body: 'B' }),
      ).resolves.not.toThrow();
    });
  });
});
