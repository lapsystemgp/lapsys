import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { LabOnboardingStatus, Role } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuditLogService } from '../common/services/audit-log.service';
import { SetLabOnboardingStatusDto } from './dto/set-lab-onboarding-status.dto';

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditLogService: AuditLogService,
  ) {}

  async getWorkspace(userId: string) {
    await this.assertAdmin(userId);

    const [totalLabs, pendingLabs, activeLabs, rejectedLabs, suspendedLabs, labs] =
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
                tests: true,
                bookings: true,
                schedule_slots: true,
              },
            },
          },
        }),
      ]);

    return {
      stats: {
        totalLabs,
        pendingLabs,
        activeLabs,
        rejectedLabs,
        suspendedLabs,
      },
      labs: labs.map((lab) => ({
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
        testsCount: lab._count.tests,
        bookingsCount: lab._count.bookings,
        scheduleSlotsCount: lab._count.schedule_slots,
        createdAt: lab.created_at.toISOString(),
        updatedAt: lab.updated_at.toISOString(),
      })),
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

    const updated = await this.prisma.labProfile.update({
      where: { id: labProfileId },
      data: {
        onboarding_status: dto.status,
      },
      select: {
        id: true,
        lab_name: true,
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
