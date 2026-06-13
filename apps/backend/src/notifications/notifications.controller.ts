import {
  Body,
  Controller,
  Delete,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { RegisterDeviceDto } from './dto/register-device.dto';

type RequestWithUser = { user?: { id?: string } };

@ApiTags('notifications')
@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('device')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Register or refresh a mobile device token for push notifications' })
  @ApiResponse({ status: 204, description: 'Token registered' })
  async registerDevice(@Req() req: RequestWithUser, @Body() dto: RegisterDeviceDto) {
    const userId = req.user?.id;
    if (!userId) throw new UnauthorizedException();
    await this.notificationsService.registerDevice(userId, dto);
  }

  @Delete('device')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Remove a device token (call on logout)' })
  @ApiResponse({ status: 204, description: 'Token removed' })
  async removeDevice(
    @Req() req: RequestWithUser,
    @Body() body: { fcm_token: string },
  ) {
    const userId = req.user?.id;
    if (!userId) throw new UnauthorizedException();
    await this.notificationsService.removeDevice(userId, body.fcm_token);
  }
}
