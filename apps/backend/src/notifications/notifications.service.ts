import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { initializeApp, getApps, cert, App } from 'firebase-admin/app';
import { getMessaging, MulticastMessage } from 'firebase-admin/messaging';

export interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private readonly firebaseApp: App | null;

  constructor(private readonly prisma: PrismaService) {
    this.firebaseApp = this.initFirebase();
  }

  private initFirebase(): App | null {
    if (getApps().length > 0) return getApps()[0];

    const raw = process.env.FCM_SERVICE_ACCOUNT_JSON;
    if (!raw) {
      this.logger.warn(
        'FCM_SERVICE_ACCOUNT_JSON not set — push notifications are disabled. ' +
          'Set this env var with your Firebase service-account JSON to enable them.',
      );
      return null;
    }

    try {
      const serviceAccount = JSON.parse(raw);
      const app = initializeApp({ credential: cert(serviceAccount) });
      this.logger.log('Firebase Admin SDK initialised — push notifications enabled.');
      return app;
    } catch (err) {
      this.logger.error('Failed to parse FCM_SERVICE_ACCOUNT_JSON — push notifications disabled.', err);
      return null;
    }
  }

  async registerDevice(userId: string, dto: RegisterDeviceDto): Promise<void> {
    await this.prisma.deviceToken.upsert({
      where: { fcm_token: dto.fcm_token },
      update: { user_id: userId, platform: dto.platform },
      create: { user_id: userId, fcm_token: dto.fcm_token, platform: dto.platform },
    });
  }

  async removeDevice(userId: string, fcmToken: string): Promise<void> {
    await this.prisma.deviceToken.deleteMany({
      where: { user_id: userId, fcm_token: fcmToken },
    });
  }

  async removeAllDevicesForUser(userId: string): Promise<void> {
    await this.prisma.deviceToken.deleteMany({ where: { user_id: userId } });
  }

  /**
   * Send a push notification to all registered devices for a user.
   * No-ops silently if FCM is not configured or the user has no registered devices.
   */
  async sendToUser(userId: string, payload: PushPayload): Promise<void> {
    if (!this.firebaseApp) return;

    const tokens = await this.prisma.deviceToken.findMany({
      where: { user_id: userId },
      select: { fcm_token: true, id: true },
    });

    if (tokens.length === 0) return;

    const message: MulticastMessage = {
      tokens: tokens.map((t) => t.fcm_token),
      notification: { title: payload.title, body: payload.body },
      data: payload.data ?? {},
    };

    try {
      const result = await getMessaging(this.firebaseApp).sendEachForMulticast(message);

      // Prune tokens that the device has deregistered
      const staleIds: string[] = [];
      result.responses.forEach((resp, idx) => {
        if (
          !resp.success &&
          (resp.error?.code === 'messaging/registration-token-not-registered' ||
            resp.error?.code === 'messaging/invalid-registration-token')
        ) {
          staleIds.push(tokens[idx].id);
        }
      });

      if (staleIds.length > 0) {
        await this.prisma.deviceToken.deleteMany({ where: { id: { in: staleIds } } });
        this.logger.log(`Removed ${staleIds.length} stale FCM token(s) for user ${userId}`);
      }

      this.logger.log(
        `Push sent to user ${userId}: ${result.successCount} ok, ${result.failureCount} failed`,
      );
    } catch (err) {
      this.logger.error(`Failed to send push to user ${userId}`, err);
    }
  }
}
