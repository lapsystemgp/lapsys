import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '@prisma/client';

@Controller('api/patient')
@UseGuards(JwtAuthGuard, RolesGuard)
export class PatientController {
  @Get('data')
  @Roles(Role.Patient)
  getPatientData() {
    return {
      message: 'This is protected Patient data.',
      timestamp: new Date().toISOString(),
    };
  }
}
