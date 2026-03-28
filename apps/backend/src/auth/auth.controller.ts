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
import { ApiTags, ApiOperation, ApiResponse, ApiCookieAuth } from '@nestjs/swagger';
import { Response, Request } from 'express';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AUTH_COOKIE_NAME } from './auth.constants';
import { PatientRegisterDto } from './dto/patient-register.dto';
import { LabRegisterDto } from './dto/lab-register.dto';
import { AuditLogService } from '../common/services/audit-log.service';

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
    const user = await this.authService.validateUser(loginDto);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const { access_token, user: userData } = await this.authService.login(user);
    this.auditLogService.log('auth.login', { userId: userData.id, role: userData.role });
    
    // Set HttpOnly cookie
    response.cookie(AUTH_COOKIE_NAME, access_token, {
      httpOnly: true,
      path: '/',
      maxAge: 3600 * 1000, // 1 hour
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production',
    });

    return { message: 'Login successful', user: userData };
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

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Logout (clears session cookie)' })
  @ApiResponse({ status: 200, description: 'Logged out' })
  logout(@Res({ passthrough: true }) response: Response) {
    response.clearCookie(AUTH_COOKIE_NAME, { path: '/' });
    this.auditLogService.log('auth.logout', {});
    return { message: 'Logged out' };
  }
}
