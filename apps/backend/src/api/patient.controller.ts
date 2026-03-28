import { Body, Controller, Get, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '@prisma/client';
import { PatientService } from './patient.service';
import { UpdatePatientProfileDto } from './dto/update-patient-profile.dto';
import { CreateReviewDto } from './dto/create-review.dto';

type RequestWithUser = {
  user?: { id?: string };
};

@Controller('patient')
@UseGuards(JwtAuthGuard, RolesGuard)
export class PatientController {
  constructor(private readonly patientService: PatientService) {}

  @Get('workspace')
  @Roles(Role.Patient)
  getWorkspace(@Req() req: RequestWithUser) {
    return this.patientService.getWorkspace(req.user?.id ?? '');
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
