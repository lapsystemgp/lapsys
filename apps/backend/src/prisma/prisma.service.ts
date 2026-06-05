import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient, Prisma } from '@prisma/client';

const TRANSIENT_CODES = new Set(['P1001', 'P1002', 'P1017', 'P2024']);
const MAX_RETRIES = 3;
const BASE_DELAY_MS = 150;

function isTransientError(error: unknown): boolean {
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    return TRANSIENT_CODES.has(error.code);
  }
  return (
    error instanceof Prisma.PrismaClientInitializationError ||
    error instanceof Prisma.PrismaClientRustPanicError
  );
}

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    super();
    // Retry transient DB errors (Neon cold-start, connection pool timeout, etc.)
    this.$use(async (params, next) => {
      let lastError: unknown;
      for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
        try {
          return await next(params);
        } catch (error) {
          lastError = error;
          if (attempt < MAX_RETRIES && isTransientError(error)) {
            this.logger.warn(
              `Transient DB error (attempt ${attempt}/${MAX_RETRIES}): ${(error as Error).message}`,
            );
            await new Promise((r) => setTimeout(r, BASE_DELAY_MS * attempt));
            continue;
          }
          throw error;
        }
      }
      throw lastError;
    });
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
