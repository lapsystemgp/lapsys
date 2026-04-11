import { Body, Controller, Get, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '@prisma/client';
import { PatientService } from './patient.service';
import { UpdatePatientProfileDto } from './dto/update-patient-profile.dto';
import { CreateReviewDto } from './dto/create-review.dto';
import {
  StructuredResultsService,
  type HealthProfileRange,
} from './structured-results.service';

type RequestWithUser = {
  user?: { id?: string };
};

@Controller('patient')
@UseGuards(JwtAuthGuard, RolesGuard)
export class PatientController {
  constructor(
    private readonly patientService: PatientService,
    private readonly structuredResultsService: StructuredResultsService,
  ) {}

  @Get('workspace')
  @Roles(Role.Patient)
  getWorkspace(@Req() req: RequestWithUser) {
    return this.patientService.getWorkspace(req.user?.id ?? '');
  }

  @Get('health-profile')
  @Roles(Role.Patient)
  getHealthProfile(@Req() req: RequestWithUser, @Query('range') range?: string) {
    const allowed: HealthProfileRange[] = ['3m', '6m', '12m', 'all'];
    const resolved = allowed.includes(range as HealthProfileRange)
      ? (range as HealthProfileRange)
      : '12m';
    return this.structuredResultsService.getHealthProfile(req.user?.id ?? '', resolved);
  }

  @Patch('profile')
  @Roles(Role.Patient)
  updateProfile(@Req() req: RequestWithUser, @Body() dto: UpdatePatientProfileDto) {
    return this.patientService.updateProfile(req.user?.id ?? '', dto);
  }

  @Post('reviews')
  @Roles(Role.Patient)
  createReview(@Req() req: RequestWithUser, @Body() dto: CreateReviewDto) {
    return this.patientService.createReview(req.user?.id ?? '', dto);
  }
}
