import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private readonly user: string | undefined;
  private readonly from: string;
  private transporter: nodemailer.Transporter | null = null;

  constructor(private readonly config: ConfigService) {
    const host = this.config.get<string>('SMTP_HOST') || undefined;
    const port = Number(this.config.get<string>('SMTP_PORT') ?? 587);
    this.user = this.config.get<string>('SMTP_USER') || undefined;
    const pass = this.config.get<string>('SMTP_PASS') || undefined;
    // Many providers (Brevo, Gmail) require the From to match the verified sender.
    this.from = this.config.get<string>('MAIL_FROM') || this.user || 'no-reply@localhost';

    if (host && this.user && pass) {
      this.transporter = nodemailer.createTransport({
        host,
        port,
        secure: port === 465, // 465 = implicit TLS; 587 = STARTTLS
        auth: { user: this.user, pass },
        // Fail fast instead of hanging for minutes if the host blocks outbound SMTP.
        connectionTimeout: 10_000,
        greetingTimeout: 10_000,
        socketTimeout: 15_000,
      });
    }
  }

  async sendOtpEmail(email: string, code: string): Promise<void> {
    if (!this.transporter) {
      this.logger.warn(
        `[DEV FALLBACK] SMTP not configured (need SMTP_HOST/SMTP_USER/SMTP_PASS) — skipping real email. OTP for ${email}: ${code}`,
      );
      return;
    }

    try {
      await this.transporter.sendMail({
        from: `TesTly <${this.from}>`,
        to: email,
        subject: 'Your TesTly verification code',
        text: `Your TesTly verification code is ${code}. It expires in 10 minutes.`,
        html: `
          <div style="font-family:sans-serif;max-width:480px;margin:0 auto">
            <h2 style="color:#2563eb">Verify your email</h2>
            <p>Enter this 6-digit code in the TesTly app to complete your registration:</p>
            <div style="font-size:2rem;font-weight:bold;letter-spacing:0.2em;color:#1e40af;padding:16px 0">${code}</div>
            <p style="color:#6b7280;font-size:0.875rem">This code expires in 10 minutes. If you didn't request this, you can ignore this email.</p>
          </div>
        `,
      });
      this.logger.log(`OTP email sent to ${email}`);
    } catch (err) {
      this.logger.error(
        `Failed to send OTP email to ${email}: ${err instanceof Error ? err.message : String(err)}`,
      );
      throw new Error('Failed to send verification email');
    }
  }
}
