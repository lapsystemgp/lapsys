import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  BookingStatus,
  Prisma,
  ResultStatus,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { BookingsService } from '../bookings/bookings.service';
import { CreateLabTestDto } from './dto/create-lab-test.dto';
import { UpdateLabTestDto } from './dto/update-lab-test.dto';
import { CreateScheduleSlotDto } from './dto/create-schedule-slot.dto';
import { UpdateScheduleSlotDto } from './dto/update-schedule-slot.dto';
import { UploadResultDto } from './dto/upload-result.dto';
import { SetResultStatusDto } from './dto/set-result-status.dto';
import { LabStorageService, UploadedLabFile } from './lab-storage.service';

@Injectable()
export class LabService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly bookingsService: BookingsService,
    private readonly labStorageService: LabStorageService,
  ) {}

  async getWorkspace(userId: string) {
    const labProfile = await this.prisma.labProfile.findUnique({
      where: { user_id: userId },
      select: { id: true, lab_name: true, address: true },
    });

    if (!labProfile) {
      throw new ForbiddenException('Only lab staff can access workspace');
    }

    const [bookingQueue, tests, slots, stats, topTests] = await Promise.all([
      this.bookingsService.listLabBookings(userId),
      this.prisma.labTest.findMany({
        where: { lab_profile_id: labProfile.id },
        orderBy: { created_at: 'desc' },
      }),
      this.prisma.labScheduleSlot.findMany({
        where: { lab_profile_id: labProfile.id },
        orderBy: { starts_at: 'asc' },
        take: 120,
      }),
      this.computeAnalytics(labProfile.id),
      this.prisma.booking.groupBy({
        by: ['lab_test_id'],
        where: { lab_profile_id: labProfile.id },
        _count: { _all: true },
        orderBy: { _count: { lab_test_id: 'desc' } },
        take: 5,
      }),
    ]);

    const testNames = await this.prisma.labTest.findMany({
      where: { id: { in: topTests.map((t) => t.lab_test_id) } },
      select: { id: true, name: true },
    });
    const testNameMap = new Map(testNames.map((t) => [t.id, t.name]));

    return {
      lab: {
        id: labProfile.id,
        name: labProfile.lab_name,
        address: labProfile.address,
      },
      bookings: bookingQueue.items,
      tests: tests.map((test) => ({
        id: test.id,
        name: test.name,
        category: test.category,
        priceEgp: test.price_egp,
        description: test.description ?? '',
        preparation: test.preparation ?? '',
        turnaroundTime: test.turnaround_time ?? '',
        parametersCount: test.parameters_count ?? null,
        isActive: test.is_active,
      })),
      schedule: slots.map((slot) => ({
        id: slot.id,
        startsAt: slot.starts_at.toISOString(),
        endsAt: slot.ends_at.toISOString(),
        capacity: slot.capacity,
        isActive: slot.is_active,
      })),
      analytics: {
        ...stats,
        topTests: topTests.map((item) => ({
          testId: item.lab_test_id,
          testName: testNameMap.get(item.lab_test_id) ?? 'Unknown Test',
          count: item._count._all,
        })),
      },
    };
  }

  async createLabTest(userId: string, dto: CreateLabTestDto) {
    const labProfileId = await this.getLabProfileId(userId);
    const created = await this.prisma.labTest.create({
      data: {
        lab_profile_id: labProfileId,
        name: dto.name.trim(),
        category: dto.category.trim(),
        price_egp: dto.priceEgp,
        description: dto.description?.trim() || null,
        preparation: dto.preparation?.trim() || null,
        turnaround_time: dto.turnaroundTime?.trim() || null,
        parameters_count: dto.parametersCount ?? null,
        is_active: dto.isActive ?? true,
      },
    });

    return {
      id: created.id,
      name: created.name,
      category: created.category,
      priceEgp: created.price_egp,
      description: created.description ?? '',
      preparation: created.preparation ?? '',
      turnaroundTime: created.turnaround_time ?? '',
      parametersCount: created.parameters_count ?? null,
      isActive: created.is_active,
    };
  }

  async updateLabTest(userId: string, testId: string, dto: UpdateLabTestDto) {
    const labProfileId = await this.getLabProfileId(userId);
    const existing = await this.prisma.labTest.findUnique({
      where: { id: testId },
      select: { id: true, lab_profile_id: true },
    });

    if (!existing) throw new NotFoundException('Test not found');
    if (existing.lab_profile_id !== labProfileId) {
      throw new ForbiddenException('You can only update your own lab tests');
    }

    const updated = await this.prisma.labTest.update({
      where: { id: testId },
      data: {
        ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
        ...(dto.category !== undefined ? { category: dto.category.trim() } : {}),
        ...(dto.priceEgp !== undefined ? { price_egp: dto.priceEgp } : {}),
        ...(dto.description !== undefined ? { description: dto.description.trim() || null } : {}),
        ...(dto.preparation !== undefined ? { preparation: dto.preparation.trim() || null } : {}),
        ...(dto.turnaroundTime !== undefined ? { turnaround_time: dto.turnaroundTime.trim() || null } : {}),
        ...(dto.parametersCount !== undefined ? { parameters_count: dto.parametersCount } : {}),
        ...(dto.isActive !== undefined ? { is_active: dto.isActive } : {}),
      },
    });

    return {
      id: updated.id,
      name: updated.name,
      category: updated.category,
      priceEgp: updated.price_egp,
      description: updated.description ?? '',
      preparation: updated.preparation ?? '',
      turnaroundTime: updated.turnaround_time ?? '',
      parametersCount: updated.parameters_count ?? null,
      isActive: updated.is_active,
    };
  }

  async deleteLabTest(userId: string, testId: string) {
    const labProfileId = await this.getLabProfileId(userId);
    const existing = await this.prisma.labTest.findUnique({
      where: { id: testId },
      select: { id: true, lab_profile_id: true },
    });

    if (!existing) throw new NotFoundException('Test not found');
    if (existing.lab_profile_id !== labProfileId) {
      throw new ForbiddenException('You can only delete your own lab tests');
    }

    const linkedBookings = await this.prisma.booking.count({
      where: { lab_test_id: testId },
    });

    if (linkedBookings > 0) {
      throw new BadRequestException('Cannot delete test that already has bookings');
    }

    await this.prisma.labTest.delete({ where: { id: testId } });
    return { success: true };
  }

  async createScheduleSlot(userId: string, dto: CreateScheduleSlotDto) {
    const labProfileId = await this.getLabProfileId(userId);

    const startsAt = new Date(dto.startsAt);
    const endsAt = new Date(dto.endsAt);
    this.validateScheduleWindow(startsAt, endsAt);

    const created = await this.prisma.labScheduleSlot.create({
      data: {
        lab_profile_id: labProfileId,
        starts_at: startsAt,
        ends_at: endsAt,
        capacity: dto.capacity ?? 1,
        is_active: true,
      },
    });

    return {
      id: created.id,
      startsAt: created.starts_at.toISOString(),
      endsAt: created.ends_at.toISOString(),
      capacity: created.capacity,
      isActive: created.is_active,
    };
  }

  async updateScheduleSlot(userId: string, slotId: string, dto: UpdateScheduleSlotDto) {
    const labProfileId = await this.getLabProfileId(userId);

    const slot = await this.prisma.labScheduleSlot.findUnique({
      where: { id: slotId },
      select: { id: true, lab_profile_id: true, starts_at: true, ends_at: true },
    });
    if (!slot) throw new NotFoundException('Slot not found');
    if (slot.lab_profile_id !== labProfileId) {
      throw new ForbiddenException('You can only update your own schedule slots');
    }

    const startsAt = dto.startsAt ? new Date(dto.startsAt) : slot.starts_at;
    const endsAt = dto.endsAt ? new Date(dto.endsAt) : slot.ends_at;
    this.validateScheduleWindow(startsAt, endsAt);

    const updated = await this.prisma.labScheduleSlot.update({
      where: { id: slotId },
      data: {
        ...(dto.startsAt !== undefined ? { starts_at: startsAt } : {}),
        ...(dto.endsAt !== undefined ? { ends_at: endsAt } : {}),
        ...(dto.capacity !== undefined ? { capacity: dto.capacity } : {}),
        ...(dto.isActive !== undefined ? { is_active: dto.isActive } : {}),
      },
    });

    return {
      id: updated.id,
      startsAt: updated.starts_at.toISOString(),
      endsAt: updated.ends_at.toISOString(),
      capacity: updated.capacity,
      isActive: updated.is_active,
    };
  }

  async deactivateScheduleSlot(userId: string, slotId: string) {
    const labProfileId = await this.getLabProfileId(userId);
    const slot = await this.prisma.labScheduleSlot.findUnique({
      where: { id: slotId },
      select: { id: true, lab_profile_id: true },
    });
    if (!slot) throw new NotFoundException('Slot not found');
    if (slot.lab_profile_id !== labProfileId) {
      throw new ForbiddenException('You can only delete your own schedule slots');
    }

    await this.prisma.labScheduleSlot.update({
      where: { id: slotId },
      data: { is_active: false },
    });

    return { success: true };
  }

  async uploadResult(
    userId: string,
    bookingId: string,
    file: UploadedLabFile | undefined,
    dto: UploadResultDto,
  ) {
    if (!file) throw new BadRequestException('PDF file is required');
    if (!file.mimetype.includes('pdf')) {
      throw new BadRequestException('Only PDF files are supported');
    }

    const labProfileId = await this.getLabProfileId(userId);
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        lab_profile_id: true,
        status: true,
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.lab_profile_id !== labProfileId) {
      throw new ForbiddenException('You can only upload results for your own lab bookings');
    }
    if (booking.status === BookingStatus.Rejected || booking.status === BookingStatus.Cancelled) {
      throw new BadRequestException('Cannot upload result for cancelled/rejected booking');
    }

    const stored = await this.labStorageService.saveResultFile(file);
    let parsedHighlights: Prisma.JsonValue | null = null;
    if (dto.highlights?.trim()) {
      try {
        parsedHighlights = JSON.parse(dto.highlights) as Prisma.JsonValue;
      } catch {
        throw new BadRequestException('Invalid highlights JSON');
      }
    }

    const result = await this.prisma.$transaction(async (tx: any) => {
      const resultFile = await tx.resultFile.upsert({
        where: { booking_id: booking.id },
        create: {
          booking_id: booking.id,
          status: ResultStatus.Uploaded,
          file_name: stored.fileName,
          file_url: stored.fileUrl,
          mime_type: stored.mimeType,
          size_bytes: stored.sizeBytes,
          uploaded_by_user_id: userId,
        },
        update: {
          status: ResultStatus.Uploaded,
          file_name: stored.fileName,
          file_url: stored.fileUrl,
          mime_type: stored.mimeType,
          size_bytes: stored.sizeBytes,
          uploaded_by_user_id: userId,
          uploaded_at: new Date(),
        },
      });

      await tx.resultSummary.upsert({
        where: { booking_id: booking.id },
        create: {
          booking_id: booking.id,
          summary: dto.summary.trim(),
          highlights: parsedHighlights,
        },
        update: {
          summary: dto.summary.trim(),
          highlights: parsedHighlights,
        },
      });

      await tx.bookingStatusEvent.create({
        data: {
          booking_id: booking.id,
          status: booking.status,
          note: 'Result file uploaded by lab',
          actor_user_id: userId,
        },
      });

      return resultFile;
    });

    return {
      bookingId: booking.id,
      resultStatus: result.status,
      fileName: result.file_name,
      fileUrl: result.file_url,
    };
  }

  async setResultStatus(userId: string, bookingId: string, dto: SetResultStatusDto) {
    const labProfileId = await this.getLabProfileId(userId);
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { id: true, lab_profile_id: true },
    });
    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.lab_profile_id !== labProfileId) {
      throw new ForbiddenException('You can only update your own lab results');
    }

    const existing = await this.prisma.resultFile.findUnique({
      where: { booking_id: booking.id },
      select: { id: true },
    });
    if (!existing) throw new BadRequestException('Upload result file first');

    const updated = await this.prisma.$transaction(async (tx: any) => {
      const file = await tx.resultFile.update({
        where: { booking_id: booking.id },
        data: { status: dto.status },
      });

      if (dto.status === ResultStatus.Delivered) {
        await tx.booking.update({
          where: { id: booking.id },
          data: { status: BookingStatus.Completed },
        });

        await tx.bookingStatusEvent.create({
          data: {
            booking_id: booking.id,
            status: BookingStatus.Completed,
            note: 'Result delivered to patient',
            actor_user_id: userId,
          },
        });
      }

      return file;
    });

    return {
      bookingId: booking.id,
      resultStatus: updated.status,
    };
  }

  private async computeAnalytics(labProfileId: string) {
    const [totalBookings, completedBookings, pendingResults, revenueRows, totalSlots, occupiedSlots] =
      await Promise.all([
        this.prisma.booking.count({ where: { lab_profile_id: labProfileId } }),
        this.prisma.booking.count({
          where: { lab_profile_id: labProfileId, status: BookingStatus.Completed },
        }),
        this.prisma.booking.count({
          where: {
            lab_profile_id: labProfileId,
            OR: [{ result_file: null }, { result_file: { status: { not: ResultStatus.Delivered } } }],
          },
        }),
        this.prisma.booking.findMany({
          where: {
            lab_profile_id: labProfileId,
            status: { in: [BookingStatus.Confirmed, BookingStatus.Completed] },
          },
          select: { total_price_egp: true },
        }),
        this.prisma.labScheduleSlot.count({
          where: {
            lab_profile_id: labProfileId,
            is_active: true,
            starts_at: { gte: new Date() },
          },
        }),
        this.prisma.booking.count({
          where: {
            lab_profile_id: labProfileId,
            schedule_slot_id: { not: null },
            status: { in: [BookingStatus.Pending, BookingStatus.Confirmed, BookingStatus.Completed] },
          },
        }),
      ]);

    const revenueEstimate = revenueRows.reduce((sum, row) => sum + row.total_price_egp, 0);
    const capacityUsagePercent =
      totalSlots > 0 ? Number(((occupiedSlots / totalSlots) * 100).toFixed(2)) : 0;

    return {
      totalBookings,
      completedBookings,
      pendingResults,
      revenueEstimateEgp: revenueEstimate,
      capacityUsagePercent,
    };
  }

  private async getLabProfileId(userId: string) {
    const labProfile = await this.prisma.labProfile.findUnique({
      where: { user_id: userId },
      select: { id: true },
    });
    if (!labProfile) throw new ForbiddenException('Only lab staff can perform this action');
    return labProfile.id;
  }

  private validateScheduleWindow(startsAt: Date, endsAt: Date) {
    if (Number.isNaN(startsAt.getTime()) || Number.isNaN(endsAt.getTime())) {
      throw new BadRequestException('Invalid schedule datetime');
    }
    if (endsAt.getTime() <= startsAt.getTime()) {
      throw new BadRequestException('Slot end time must be after start time');
    }
    if (startsAt.getTime() <= Date.now()) {
      throw new BadRequestException('Slot start time must be in the future');
    }
  }
}
