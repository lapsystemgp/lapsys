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

  async getAggregateStats(userId: string) {
    await this.assertAdmin(userId);

    const [totalBookings, revenueAggregate] = await Promise.all([
      this.prisma.booking.count(),
      this.prisma.booking.aggregate({
        _sum: { total_price_egp: true },
        where: { payment_status: 'Paid' },
      }),
    ]);

    return {
      totalBookings,
      totalRevenueEgp: revenueAggregate._sum.total_price_egp ?? 0,
    };
  }

  async listPatients(userId: string) {
    await this.assertAdmin(userId);

    const patients = await this.prisma.patientProfile.findMany({
      orderBy: { created_at: 'desc' },
      select: {
        id: true,
        full_name: true,
        created_at: true,
        user: { select: { email: true } },
        _count: { select: { bookings: true } },
      },
    });

    return {
      items: patients.map((p) => ({
        id: p.id,
        name: p.full_name ?? null,
        email: p.user.email,
        bookingCount: p._count.bookings,
        joinedAt: p.created_at.toISOString(),
      })),
    };
  }

  async listRecentPayments(userId: string, limit?: number) {
    await this.assertAdmin(userId);

    const take = Math.min(Math.max(limit ?? 60, 1), 200);

    const rows = await this.prisma.booking.findMany({
      take,
      orderBy: { created_at: 'desc' },
      select: {
        id: true,
        status: true,
        booking_type: true,
        scheduled_at: true,
        total_price_egp: true,
        payment_method: true,
        payment_status: true,
        payment_reference: true,
        payment_paid_at: true,
        payment_failed_at: true,
        payment_failure_reason: true,
        created_at: true,
        patient_profile: {
          select: {
            full_name: true,
            user: { select: { email: true } },
          },
        },
        lab_profile: {
          select: { lab_name: true },
        },
        lab_test: { select: { name: true } },
      },
    });

    return {
      items: rows.map((row) => ({
        bookingId: row.id,
        bookingStatus: row.status,
        bookingType: row.booking_type,
        scheduledAt: row.scheduled_at.toISOString(),
        totalPriceEgp: row.total_price_egp,
        paymentMethod: row.payment_method,
        paymentStatus: row.payment_status,
        paymentReference: row.payment_reference ?? null,
        paymentPaidAt: row.payment_paid_at ? row.payment_paid_at.toISOString() : null,
        paymentFailedAt: row.payment_failed_at ? row.payment_failed_at.toISOString() : null,
        paymentFailureReason: row.payment_failure_reason ?? null,
        createdAt: row.created_at.toISOString(),
        patientEmail: row.patient_profile.user.email,
        patientName: row.patient_profile.full_name ?? null,
        labName: row.lab_profile.lab_name,
        testName: row.lab_test.name,
      })),
    };
  }

  async getChartData(userId: string) {
    await this.assertAdmin(userId);

    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 29);
    thirtyDaysAgo.setHours(0, 0, 0, 0);

    const [recentBookings, paidBookings, allBookingsForTests] = await Promise.all([
      this.prisma.booking.findMany({
        where: { created_at: { gte: thirtyDaysAgo } },
        select: { created_at: true },
      }),
      this.prisma.booking.findMany({
        where: { payment_status: 'Paid' },
        select: {
          total_price_egp: true,
          lab_profile: { select: { city: true } },
        },
      }),
      this.prisma.booking.findMany({
        select: { lab_test: { select: { name: true } } },
      }),
    ]);

    // Booking volume per day — fill zeros for days with no bookings
    const volumeMap = new Map<string, number>();
    for (let i = 0; i < 30; i++) {
      const d = new Date(thirtyDaysAgo);
      d.setDate(d.getDate() + i);
      volumeMap.set(d.toISOString().slice(0, 10), 0);
    }
    for (const b of recentBookings) {
      const key = b.created_at.toISOString().slice(0, 10);
      if (volumeMap.has(key)) volumeMap.set(key, (volumeMap.get(key) ?? 0) + 1);
    }
    const bookingVolume = Array.from(volumeMap.entries()).map(([date, count]) => ({ date, count }));

    // Revenue by city (paid bookings only)
    const cityMap = new Map<string, number>();
    for (const b of paidBookings) {
      const city = b.lab_profile.city ?? 'Unknown';
      cityMap.set(city, (cityMap.get(city) ?? 0) + b.total_price_egp);
    }
    const revenueByCity = Array.from(cityMap.entries())
      .map(([city, revenue]) => ({ city, revenue }))
      .sort((a, b) => b.revenue - a.revenue)
      .slice(0, 8);

    // Popular tests by total bookings
    const testMap = new Map<string, number>();
    for (const b of allBookingsForTests) {
      const name = b.lab_test.name;
      testMap.set(name, (testMap.get(name) ?? 0) + 1);
    }
    const popularTests = Array.from(testMap.entries())
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 8);

    return { bookingVolume, revenueByCity, popularTests };
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
