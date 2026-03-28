import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class AuditLogService {
  private readonly logger = new Logger('AuditLog');

  log(event: string, details: Record<string, unknown>) {
    this.logger.log(
      JSON.stringify({
        event,
        details,
        timestamp: new Date().toISOString(),
      }),
    );
  }
}
