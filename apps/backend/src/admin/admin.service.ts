import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { LabOnboardingStatus, Role } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuditLogService } from '../common/services/audit-log.service';
import { SetLabOnboardingStatusDto } from './dto/set-lab-onboarding-status.dto';

type AdminLabRecord = {
  id: string;
  lab_name: string;
  phone: string | null;
  address: string;
  accreditation: string | null;
  turnaround_time: string | null;
  home_collection: boolean;
  onboarding_status: LabOnboardingStatus;
  rating_average: number | null;
  review_count: number;
  created_at: Date;
  updated_at: Date;
  user: { id: string; email: string };
  _count: { bookings: number };
};

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditLogService: AuditLogService,
  ) {}

  async getWorkspace(userId: string) {
    await this.assertAdmin(userId);

    const [totalLabs, pendingLabs, activeLabs, rejectedLabs, suspendedLabs, labs, activeTestsByLab, activeSlotsByLab] =
      await Promise.all([
        this.prisma.labProfile.count(),
        this.prisma.labProfile.count({
          where: { onboarding_status: LabOnboardingStatus.PendingReview },
        }),
        this.prisma.labProfile.count({
          where: { onboarding_status: LabOnboardingStatus.Active },
        }),
        this.prisma.labProfile.count({
          where: { onboarding_status: LabOnboardingStatus.Rejected },
        }),
        this.prisma.labProfile.count({
          where: { onboarding_status: LabOnboardingStatus.Suspended },
        }),
        this.prisma.labProfile.findMany({
          orderBy: [{ onboarding_status: 'asc' }, { created_at: 'desc' }],
          select: {
            id: true,
            lab_name: true,
            phone: true,
            address: true,
            accreditation: true,
            turnaround_time: true,
            home_collection: true,
            onboarding_status: true,
            rating_average: true,
            review_count: true,
            created_at: true,
            updated_at: true,
            user: {
              select: {
                id: true,
                email: true,
              },
            },
            _count: {
              select: {
                bookings: true,
              },
            },
          },
        }),
        this.prisma.labTest.groupBy({
          by: ['lab_profile_id'],
          where: { is_active: true },
          _count: { _all: true },
        }),
        this.prisma.labScheduleSlot.groupBy({
          by: ['lab_profile_id'],
          where: { is_active: true },
          _count: { _all: true },
        }),
      ]);

    const activeTestsCountByLab = new Map(
      activeTestsByLab.map((entry) => [entry.lab_profile_id, entry._count._all]),
    );
    const activeScheduleSlotsCountByLab = new Map(
      activeSlotsByLab.map((entry) => [entry.lab_profile_id, entry._count._all]),
    );
    const enrichedLabs = (labs as AdminLabRecord[]).map((lab) =>
      this.toAdminLabResponse(lab, {
        activeTestsCount: activeTestsCountByLab.get(lab.id) ?? 0,
        activeScheduleSlotsCount: activeScheduleSlotsCountByLab.get(lab.id) ?? 0,
      }),
    );
    const readyPendingLabs = enrichedLabs.filter(
      (lab) => lab.onboardingStatus === LabOnboardingStatus.PendingReview && lab.onboardingReadiness.isReady,
    ).length;
    const incompleteLabs = enrichedLabs.filter((lab) => !lab.onboardingReadiness.isReady).length;

    return {
      stats: {
        totalLabs,
        pendingLabs,
        activeLabs,
        rejectedLabs,
        suspendedLabs,
        readyPendingLabs,
        incompleteLabs,
      },
      labs: enrichedLabs,
    };
  }

  async setLabOnboardingStatus(
    userId: string,
    labProfileId: string,
    dto: SetLabOnboardingStatusDto,
  ) {
    await this.assertAdmin(userId);

    const existing = await this.prisma.labProfile.findUnique({
      where: { id: labProfileId },
      select: {
        id: true,
        lab_name: true,
        phone: true,
        accreditation: true,
        turnaround_time: true,
        onboarding_status: true,
        user: {
          select: {
            email: true,
          },
        },
      },
    });

    if (!existing) {
      throw new NotFoundException('Lab not found');
    }

    if (dto.status === LabOnboardingStatus.Active) {
      const readiness = await this.getOnboardingReadiness(existing.id, {
        phone: existing.phone ?? null,
        accreditation: existing.accreditation ?? null,
        turnaround_time: existing.turnaround_time ?? null,
      });

      if (!readiness.isReady) {
        throw new BadRequestException(
          `Lab is not ready for activation. Missing: ${readiness.missingRequirements.join(', ')}`,
        );
      }
    }

    const updated = await this.prisma.labProfile.update({
      where: { id: labProfileId },
      data: {
        onboarding_status: dto.status,
      },
      select: {
        id: true,
        lab_name: true,
        phone: true,
        accreditation: true,
        turnaround_time: true,
        onboarding_status: true,
        updated_at: true,
        user: {
          select: {
            email: true,
          },
        },
      },
    });

    this.auditLogService.log('admin.lab_onboarding_status.updated', {
      adminUserId: userId,
      labProfileId: updated.id,
      previousStatus: existing.onboarding_status,
      nextStatus: updated.onboarding_status,
      labEmail: updated.user.email,
    });

    return {
      id: updated.id,
      labName: updated.lab_name,
      email: updated.user.email,
      onboardingStatus: updated.onboarding_status,
      updatedAt: updated.updated_at.toISOString(),
    };
  }

  private toAdminLabResponse(
    lab: AdminLabRecord,
    counts: { activeTestsCount: number; activeScheduleSlotsCount: number },
  ) {
    const onboardingReadiness = this.buildOnboardingReadiness({
      phone: lab.phone ?? null,
      accreditation: lab.accreditation ?? null,
      turnaroundTime: lab.turnaround_time ?? null,
      activeTestsCount: counts.activeTestsCount,
      activeScheduleSlotsCount: counts.activeScheduleSlotsCount,
    });

    return {
      id: lab.id,
      labName: lab.lab_name,
      email: lab.user.email,
      phone: lab.phone ?? '',
      address: lab.address,
      accreditation: lab.accreditation ?? '',
      turnaroundTime: lab.turnaround_time ?? '',
      homeCollection: lab.home_collection,
      onboardingStatus: lab.onboarding_status,
      ratingAverage: lab.rating_average,
      reviewCount: lab.review_count,
      testsCount: counts.activeTestsCount,
      bookingsCount: lab._count.bookings,
      scheduleSlotsCount: counts.activeScheduleSlotsCount,
      onboardingReadiness,
      createdAt: lab.created_at.toISOString(),
      updatedAt: lab.updated_at.toISOString(),
    };
  }

  private async getOnboardingReadiness(
    labProfileId: string,
    base: { phone: string | null; accreditation: string | null; turnaround_time: string | null },
  ) {
    const [activeTestsCount, activeScheduleSlotsCount] = await Promise.all([
      this.prisma.labTest.count({
        where: { lab_profile_id: labProfileId, is_active: true },
      }),
      this.prisma.labScheduleSlot.count({
        where: { lab_profile_id: labProfileId, is_active: true },
      }),
    ]);

    return this.buildOnboardingReadiness({
      phone: base.phone,
      accreditation: base.accreditation,
      turnaroundTime: base.turnaround_time,
      activeTestsCount,
      activeScheduleSlotsCount,
    });
  }

  private buildOnboardingReadiness(params: {
    phone: string | null;
    accreditation: string | null;
    turnaroundTime: string | null;
    activeTestsCount: number;
    activeScheduleSlotsCount: number;
  }) {
    const missingRequirements: string[] = [];

    if (!params.phone?.trim()) {
      missingRequirements.push('phone number');
    }
    if (!params.accreditation?.trim()) {
      missingRequirements.push('accreditation');
    }
    if (!params.turnaroundTime?.trim()) {
      missingRequirements.push('turnaround time');
    }
    if (params.activeTestsCount < 1) {
      missingRequirements.push('at least 1 active test');
    }
    if (params.activeScheduleSlotsCount < 1) {
      missingRequirements.push('at least 1 active schedule slot');
    }

    const totalRequirements = 5;
    const completedRequirements = totalRequirements - missingRequirements.length;

    return {
      isReady: missingRequirements.length === 0,
      completedRequirements,
      totalRequirements,
      missingRequirements,
    };
  }

  private async assertAdmin(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, role: true },
    });

    if (!user || user.role !== Role.Admin) {
      throw new ForbiddenException('Only admins can access this resource');
    }
  }
}
