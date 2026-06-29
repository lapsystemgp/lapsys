import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import type SMTPTransport from 'nodemailer/lib/smtp-transport';

const BREVO_ENDPOINT = 'https://api.brevo.com/v3/smtp/email';

type MailContent = { subject: string; html: string; text: string };

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private readonly from: string;
  private readonly brevoKey: string | undefined;
  private transporter: nodemailer.Transporter | null = null;
  private mode: 'brevo' | 'smtp' | 'none' = 'none';

  constructor(private readonly config: ConfigService) {
    const host = this.config.get<string>('SMTP_HOST') || undefined;
    const port = Number(this.config.get<string>('SMTP_PORT') ?? 587);
    const user = this.config.get<string>('SMTP_USER') || undefined;
    const pass = this.config.get<string>('SMTP_PASS') || undefined;
    this.brevoKey = this.config.get<string>('BREVO_API_KEY') || undefined;
    // Sender must match a verified sender (Brevo) or the authenticated account
    // (Gmail). Normalize to lowercase — Brevo's sender check is case-sensitive and
    // rejects "Foo@gmail.com" if the verified sender is "foo@gmail.com".
    this.from = (this.config.get<string>('MAIL_FROM') || user || 'no-reply@localhost')
      .trim()
      .toLowerCase();

    // Prefer Brevo's HTTP API: it works over port 443, which PaaS hosts (Railway)
    // don't block — unlike outbound SMTP ports.
    if (this.brevoKey) {
      this.mode = 'brevo';
      this.logger.log(`Mail transport ready: Brevo HTTP API, sender ${this.from}`);
    } else if (host && user && pass) {
      this.mode = 'smtp';
      // `family` is honored by nodemailer at runtime but missing from its types.
      const options: SMTPTransport.Options & { family?: number } = {
        host,
        port,
        secure: port === 465, // 465 = implicit TLS; 587 = STARTTLS
        auth: { user, pass },
        // Force IPv4: some hosts have no IPv6 route (ENETUNREACH to IPv6 SMTP).
        family: 4,
        connectionTimeout: 10_000,
        greetingTimeout: 10_000,
        socketTimeout: 15_000,
      };
      this.transporter = nodemailer.createTransport(options);
      this.logger.log(`Mail transport ready: SMTP ${host}:${port} as ${user}`);
    } else {
      this.logger.warn(
        'Mail transport NOT configured (set BREVO_API_KEY, or SMTP_HOST/USER/PASS) — OTP codes will only be logged.',
      );
    }
  }

  async sendOtpEmail(email: string, code: string): Promise<void> {
    const content: MailContent = {
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
    };

    if (this.mode === 'none') {
      this.logger.warn(`[DEV FALLBACK] mail not configured — OTP for ${email}: ${code}`);
      return;
    }

    try {
      await this.deliver(email, content);
      this.logger.log(`OTP email sent to ${email} via ${this.mode}`);
    } catch (err) {
      this.logger.error(
        `Failed to send OTP email to ${email}: ${err instanceof Error ? err.message : String(err)}`,
      );
      throw new Error('Failed to send verification email');
    }
  }

  private async deliver(to: string, content: MailContent): Promise<void> {
    if (this.mode === 'brevo') {
      const res = await fetch(BREVO_ENDPOINT, {
        method: 'POST',
        headers: {
          'api-key': this.brevoKey as string,
          'content-type': 'application/json',
          accept: 'application/json',
        },
        body: JSON.stringify({
          sender: { email: this.from, name: 'TesTly' },
          to: [{ email: to }],
          subject: content.subject,
          htmlContent: content.html,
          textContent: content.text,
        }),
      });
      if (!res.ok) {
        throw new Error(`Brevo ${res.status}: ${await res.text()}`);
      }
      return;
    }

    await this.transporter!.sendMail({
      from: `TesTly <${this.from}>`,
      to,
      subject: content.subject,
      text: content.text,
      html: content.html,
    });
  }
}
