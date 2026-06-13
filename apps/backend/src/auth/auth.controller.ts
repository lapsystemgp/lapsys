import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Logger,
  Post,
  Req,
  Res,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiCookieAuth } from '@nestjs/swagger';
import { Response, Request } from 'express';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AUTH_COOKIE_NAME } from './auth.constants';
import { PatientRegisterDto } from './dto/patient-register.dto';
import { LabRegisterDto } from './dto/lab-register.dto';
import { AuditLogService } from '../common/services/audit-log.service';
import { Role } from '@prisma/client';

@ApiTags('auth')
@Controller('auth')
@ApiCookieAuth()
export class AuthController {
  private readonly logger = new Logger(AuthController.name);

  constructor(
    private readonly authService: AuthService,
    private readonly auditLogService: AuditLogService,
  ) {}

  @Post('register/patient')
  @ApiOperation({ summary: 'Register a new patient' })
  @ApiResponse({ status: 201, description: 'User successfully created.' })
  @ApiResponse({ status: 400, description: 'Validation failed or email taken.' })
  async registerPatient(@Body() registerDto: PatientRegisterDto) {
    this.logger.log(`Incoming patient registration request for: ${registerDto.email}`);
    const result = await this.authService.registerPatient(registerDto);
    this.auditLogService.log('auth.register.patient', { userId: result.id, email: result.email });
    return result;
  }

  @Post('register/lab')
  @ApiOperation({ summary: 'Register a new lab account (PendingReview)' })
  @ApiResponse({ status: 201, description: 'Lab account successfully created (pending review).' })
  @ApiResponse({ status: 400, description: 'Validation failed or email taken.' })
  async registerLab(@Body() registerDto: LabRegisterDto) {
    this.logger.log(`Incoming lab registration request for: ${registerDto.email}`);
    const result = await this.authService.registerLab(registerDto);
    this.auditLogService.log('auth.register.lab', { userId: result.id, email: result.email });
    return result;
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login user and establish session' })
  @ApiResponse({ status: 200, description: 'Login successful' })
  @ApiResponse({ status: 401, description: 'Invalid credentials' })
  async login(@Body() loginDto: LoginDto, @Res({ passthrough: true }) response: Response) {
    const result = await this.authService.validateUser(loginDto);
    if (!result) {
      throw new UnauthorizedException('Invalid credentials');
    }
    if ('wrongRole' in result) {
      throw new UnauthorizedException(
        'Wrong account type. Please select the correct role for your account.',
      );
    }

    const { access_token, refresh_token, user: userData } = await this.authService.login(
      result as { id: string; email: string; role: Role },
    );
    this.auditLogService.log('auth.login', { userId: userData.id, role: userData.role });

    // Web clients use the HTTP-only cookie; mobile clients use the token from the response body.
    response.cookie(AUTH_COOKIE_NAME, access_token, {
      httpOnly: true,
      path: '/',
      maxAge: 8 * 3600 * 1000, // 8 hours
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production',
    });

    return { message: 'Login successful', user: userData, access_token, refresh_token };
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  @ApiOperation({ summary: 'Get current user (Protected)' })
  @ApiResponse({ status: 200, description: 'Profile retrieved' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMe(@Req() req: Request) {
    // JwtStrategy sets req.user to include id/role, but we fetch the canonical user from DB.
    // @ts-expect-error - passport attaches user at runtime
    const userId: string | undefined = req.user?.id;
    if (!userId) {
      throw new UnauthorizedException();
    }
    return this.authService.getCurrentUser(userId);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Rotate refresh token and issue a new access token (mobile)' })
  @ApiResponse({ status: 200, description: 'New token pair issued' })
  @ApiResponse({ status: 401, description: 'Invalid or expired refresh token' })
  async refresh(@Body() dto: RefreshTokenDto) {
    const tokens = await this.authService.refreshAccessToken(dto.refresh_token);
    return tokens;
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Logout (clears session cookie and revokes refresh token)' })
  @ApiResponse({ status: 200, description: 'Logged out' })
  async logout(
    @Res({ passthrough: true }) response: Response,
    @Body() body: { refresh_token?: string },
  ) {
    response.clearCookie(AUTH_COOKIE_NAME, { path: '/' });
    if (body?.refresh_token) {
      await this.authService.revokeRefreshToken(body.refresh_token);
    }
    this.auditLogService.log('auth.logout', {});
    return { message: 'Logged out' };
  }
}
