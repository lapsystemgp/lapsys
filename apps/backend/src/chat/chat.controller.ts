import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import type { Response } from 'express';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ChatService, StreamEvent } from './chat.service';
import { SendMessageDto } from './dto/send-message.dto';

type RequestWithUser = {
  user?: { id?: string };
};

@Controller('chat')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('conversations')
  @Roles(Role.Patient)
  listConversations(@Req() req: RequestWithUser) {
    return this.chatService.listConversations(req.user?.id ?? '');
  }

  @Get('conversations/:id/messages')
  @Roles(Role.Patient)
  getMessages(
    @Req() req: RequestWithUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.chatService.getMessages(req.user?.id ?? '', id);
  }

  /**
   * Sends a message and streams the assistant reply as Server-Sent Events.
   * Uses @Res() directly, so it bypasses the global interceptors/filters —
   * errors are surfaced as an `error` SSE event instead of an HTTP error body.
   */
  @Post('messages')
  @Roles(Role.Patient)
  async sendMessage(
    @Req() req: RequestWithUser,
    @Body() dto: SendMessageDto,
    @Res() res: Response,
  ) {
    res.set({
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-transform',
      Connection: 'keep-alive',
      'X-Accel-Buffering': 'no',
    });
    res.flushHeaders();

    const write = (event: StreamEvent) => {
      res.write(`data: ${JSON.stringify(event)}\n\n`);
    };

    try {
      await this.chatService.streamReply(
        req.user?.id ?? '',
        dto.text,
        dto.conversationId,
        write,
      );
    } catch (err) {
      const message =
        err instanceof Error ? err.message : 'Failed to generate a reply.';
      write({ type: 'error', message });
    } finally {
      res.end();
    }
  }
}
