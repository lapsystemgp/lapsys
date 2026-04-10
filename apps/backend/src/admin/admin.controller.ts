import { Body, Controller, Get, Param, Patch, Req, UseGuards } from '@nestjs/common';
import { Role } from '@prisma/client';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { AdminService } from './admin.service';
import { SetLabOnboardingStatusDto } from './dto/set-lab-onboarding-status.dto';

type RequestWithUser = {
  user?: { id?: string };
};

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.Admin)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('workspace')
  getWorkspace(@Req() req: RequestWithUser) {
    return this.adminService.getWorkspace(req.user?.id ?? '');
  }

  @Patch('labs/:labProfileId/status')
  setLabOnboardingStatus(
    @Req() req: RequestWithUser,
    @Param('labProfileId') labProfileId: string,
    @Body() dto: SetLabOnboardingStatusDto,
  ) {
    return this.adminService.setLabOnboardingStatus(req.user?.id ?? '', labProfileId, dto);
  }
}
