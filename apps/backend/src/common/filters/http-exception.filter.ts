import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const isHttpException = exception instanceof HttpException;
    const status = isHttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    if (!isHttpException) {
      this.logger.error(`Unhandled exception on ${request.method} ${request.originalUrl}`, exception instanceof Error ? exception.stack : String(exception));
    }

    const payload = isHttpException ? exception.getResponse() : null;
    const message =
      typeof payload === 'string'
        ? payload
        : typeof payload === 'object' &&
            payload !== null &&
            'message' in payload
          ? (payload as { message?: string | string[] }).message
          : 'Internal server error';

    response.status(status).json({
      statusCode: status,
      message,
      timestamp: new Date().toISOString(),
      path: request.originalUrl,
    });
  }
}
