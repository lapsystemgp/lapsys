import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private readonly apiKey: string | undefined;
  private readonly from: string;

  constructor(private readonly config: ConfigService) {
    this.apiKey = this.config.get<string>('RESEND_API_KEY') || undefined;
    this.from = this.config.get<string>('MAIL_FROM') ?? 'onboarding@resend.dev';
  }

  async sendOtpEmail(email: string, code: string): Promise<void> {
    if (!this.apiKey) {
      this.logger.warn(
        `[DEV FALLBACK] RESEND_API_KEY is not set — skipping real email. OTP for ${email}: ${code}`,
      );
      return;
    }

    // Dynamic import keeps the Resend client tree-shaken when the key is absent.
    const { Resend } = await import('resend');
    const resend = new Resend(this.apiKey);

    const { error } = await resend.emails.send({
      from: this.from,
      to: email,
      subject: 'Your TesTly verification code',
      html: `
        <div style="font-family:sans-serif;max-width:480px;margin:0 auto">
          <h2 style="color:#2563eb">Verify your email</h2>
          <p>Enter this 6-digit code in the TesTly app to complete your registration:</p>
          <div style="font-size:2rem;font-weight:bold;letter-spacing:0.2em;color:#1e40af;padding:16px 0">${code}</div>
          <p style="color:#6b7280;font-size:0.875rem">This code expires in 10 minutes. If you didn't request this, you can ignore this email.</p>
        </div>
      `,
    });

    if (error) {
      this.logger.error(`Failed to send OTP email to ${email}: ${JSON.stringify(error)}`);
      throw new Error('Failed to send verification email');
    }

    this.logger.log(`OTP email sent to ${email}`);
  }
}
