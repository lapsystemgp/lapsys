import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { LabOnboardingStatus, Role } from '@prisma/client';
import { AuditLogService } from '../common/services/audit-log.service';
import { AdminService } from './admin.service';

describe('AdminService', () => {
  const prismaMock = {
    user: {
      findUnique: jest.fn(),
    },
    labProfile: {
      count: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
  } as any;

  const auditLogMock = { log: jest.fn() } as unknown as AuditLogService;

  let service: AdminService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new AdminService(prismaMock, auditLogMock);
  });

  it('rejects non-admin workspace access', async () => {
    prismaMock.user.findUnique.mockResolvedValue({ id: 'user-1', role: Role.Patient });

    await expect(service.getWorkspace('user-1')).rejects.toThrow(ForbiddenException);
  });

  it('returns admin workspace with lab stats', async () => {
    prismaMock.user.findUnique.mockResolvedValue({ id: 'admin-1', role: Role.Admin });
    prismaMock.labProfile.count
      .mockResolvedValueOnce(4)
      .mockResolvedValueOnce(1)
      .mockResolvedValueOnce(2)
      .mockResolvedValueOnce(1)
      .mockResolvedValueOnce(0);
    prismaMock.labProfile.findMany.mockResolvedValue([
      {
        id: 'lab-1',
        lab_name: 'Alpha Lab',
        phone: '+20 10 0000 0000',
        address: 'Cairo',
        accreditation: 'CAP',
        turnaround_time: '24 hours',
        home_collection: true,
        onboarding_status: LabOnboardingStatus.PendingReview,
        rating_average: 4.8,
        review_count: 10,
        created_at: new Date('2026-01-01T00:00:00.000Z'),
        updated_at: new Date('2026-01-02T00:00:00.000Z'),
        user: { id: 'lab-user-1', email: 'alpha@example.com' },
        _count: { tests: 7, bookings: 14, schedule_slots: 4 },
      },
    ]);

    const result = await service.getWorkspace('admin-1');

    expect(result.stats.totalLabs).toBe(4);
    expect(result.stats.pendingLabs).toBe(1);
    expect(result.labs[0]).toEqual(
      expect.objectContaining({
        id: 'lab-1',
        labName: 'Alpha Lab',
        email: 'alpha@example.com',
        onboardingStatus: LabOnboardingStatus.PendingReview,
        testsCount: 7,
      }),
    );
  });

  it('updates lab onboarding status', async () => {
    prismaMock.user.findUnique.mockResolvedValue({ id: 'admin-1', role: Role.Admin });
    prismaMock.labProfile.findUnique.mockResolvedValue({
      id: 'lab-1',
      lab_name: 'Alpha Lab',
      onboarding_status: LabOnboardingStatus.PendingReview,
      user: { email: 'alpha@example.com' },
    });
    prismaMock.labProfile.update.mockResolvedValue({
      id: 'lab-1',
      lab_name: 'Alpha Lab',
      onboarding_status: LabOnboardingStatus.Active,
      updated_at: new Date('2026-01-03T00:00:00.000Z'),
      user: { email: 'alpha@example.com' },
    });

    const result = await service.setLabOnboardingStatus('admin-1', 'lab-1', {
      status: LabOnboardingStatus.Active,
    });

    expect(prismaMock.labProfile.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'lab-1' },
        data: { onboarding_status: LabOnboardingStatus.Active },
      }),
    );
    expect(result.onboardingStatus).toBe(LabOnboardingStatus.Active);
  });

  it('throws when updating a missing lab', async () => {
    prismaMock.user.findUnique.mockResolvedValue({ id: 'admin-1', role: Role.Admin });
    prismaMock.labProfile.findUnique.mockResolvedValue(null);

    await expect(
      service.setLabOnboardingStatus('admin-1', 'missing-lab', {
        status: LabOnboardingStatus.Rejected,
      }),
    ).rejects.toThrow(NotFoundException);
  });
});
