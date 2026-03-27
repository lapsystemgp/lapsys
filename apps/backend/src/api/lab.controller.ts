import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '@prisma/client';
import { LabActiveGuard } from '../auth/guards/lab-active.guard';

@Controller('api/lab')
@UseGuards(JwtAuthGuard, RolesGuard, LabActiveGuard)
export class LabController {
  @Get('data')
  @Roles(Role.LabStaff)
  getLabData() {
    return {
      message: 'This is protected Lab Staff data.',
      timestamp: new Date().toISOString(),
    };
  }
}
