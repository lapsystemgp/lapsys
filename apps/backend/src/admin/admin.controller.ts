import { Body, Controller, Get, Param, Patch, Query, Req, UseGuards } from '@nestjs/common';
import { Role } from '@prisma/client';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { PrismaService } from '../prisma/prisma.service';
import { AdminService } from './admin.service';
import { SetLabOnboardingStatusDto } from './dto/set-lab-onboarding-status.dto';

type RequestWithUser = {
  user?: { id?: string };
};

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.Admin)
export class AdminController {
  constructor(
    private readonly adminService: AdminService,
    private readonly prisma: PrismaService,
  ) {}

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

  @Get('stats')
  getAggregateStats(@Req() req: RequestWithUser) {
    return this.adminService.getAggregateStats(req.user?.id ?? '');
  }

  @Get('patients')
  listPatients(@Req() req: RequestWithUser) {
    return this.adminService.listPatients(req.user?.id ?? '');
  }

  @Get('payments/recent')
  listRecentPayments(@Req() req: RequestWithUser) {
    return this.adminService.listRecentPayments(req.user?.id ?? '');
  }

  @Get('analytics/charts')
  getChartData(@Req() req: RequestWithUser) {
    return this.adminService.getChartData(req.user?.id ?? '');
  }

  /** Top zero-result search queries — shows catalog gaps. */
  @Get('search-insights')
  async getSearchInsights(@Query('days') daysParam?: string) {
    const days = Math.min(parseInt(daysParam ?? '30', 10) || 30, 90);
    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    const rows = await this.prisma.$queryRaw<
      Array<{ query: string; source: string; count: number; last_seen: Date }>
    >`
      SELECT query, source, COUNT(*)::int AS count, MAX(created_at) AS last_seen
      FROM "SearchZeroResultLog"
      WHERE created_at > ${since}
      GROUP BY query, source
      ORDER BY count DESC
      LIMIT 100
    `;

    return {
      period: `${days}d`,
      totalEvents: rows.reduce((sum, r) => sum + r.count, 0),
      queries: rows.map((r) => ({
        query: r.query,
        source: r.source,
        count: r.count,
        lastSeen: r.last_seen,
      })),
    };
  }
}
