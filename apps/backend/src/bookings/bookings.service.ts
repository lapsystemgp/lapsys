import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  BookingStatus,
  BookingType,
  LabOnboardingStatus,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AvailabilityQueryDto } from './dto/availability-query.dto';
import { CreateBookingDto } from './dto/create-booking.dto';

type BookingWithRelations = {
  id: string;
  booking_type: BookingType;
  status: BookingStatus;
  scheduled_at: Date;
  home_address: string | null;
  total_price_egp: number;
  created_at: Date;
  patient_profile: { id: string; full_name: string | null; phone: string | null; address: string | null };
  lab_profile: { id: string; lab_name: string; address: string; home_collection: boolean };
  lab_test: { id: string; name: string; price_egp: number };
  schedule_slot: { id: string; starts_at: Date; ends_at: Date } | null;
  status_events: Array<{
    id: string;
    status: BookingStatus;
    note: string | null;
    created_at: Date;
    actor_user_id: string | null;
  }>;
};

const ACTIVE_SLOT_STATUSES: BookingStatus[] = [
  BookingStatus.Pending,
  BookingStatus.Confirmed,
  BookingStatus.Completed,
];

@Injectable()
export class BookingsService {
  constructor(private readonly prisma: PrismaService) {}

  async getAvailability(query: AvailabilityQueryDto) {
    const days = query.days ?? 7;
    const dateFrom = query.dateFrom ? new Date(`${query.dateFrom}T00:00:00`) : new Date();
    dateFrom.setHours(0, 0, 0, 0);
    const endDate = new Date(dateFrom);
    endDate.setDate(endDate.getDate() + days);

    const labTest = await this.prisma.labTest.findFirst({
      where: {
        id: query.testId,
        lab_profile_id: query.labId,
        is_active: true,
        lab_profile: { onboarding_status: LabOnboardingStatus.Active },
      },
      select: { id: true },
    });

    if (!labTest) {
      throw new NotFoundException('Lab test not found');
    }

    const slots = (await this.prisma.labScheduleSlot.findMany({
      where: {
        lab_profile_id: query.labId,
        is_active: true,
        starts_at: { gte: dateFrom, lt: endDate },
      },
      orderBy: { starts_at: 'asc' },
      include: {
        booking: {
          select: {
            id: true,
            status: true,
          },
        },
      },
    })) as Array<{
      id: string;
      starts_at: Date;
      ends_at: Date;
      booking: { id: string; status: BookingStatus } | null;
    }>;

    return {
      items: slots
        .filter((slot: { booking: { status: BookingStatus } | null }) => !slot.booking || !ACTIVE_SLOT_STATUSES.includes(slot.booking.status))
        .map((slot: { id: string; starts_at: Date; ends_at: Date }) => ({
          id: slot.id,
          startsAt: slot.starts_at.toISOString(),
          endsAt: slot.ends_at.toISOString(),
        })),
    };
  }

  async createBooking(userId: string, dto: CreateBookingDto) {
    const patientProfile = await this.prisma.patientProfile.findUnique({
      where: { user_id: userId },
      select: { id: true, address: true },
    });

    if (!patientProfile) {
      throw new ForbiddenException('Only patients can create bookings');
    }

    const test = await this.prisma.labTest.findFirst({
      where: {
        id: dto.testId,
        lab_profile_id: dto.labId,
        is_active: true,
        lab_profile: { onboarding_status: LabOnboardingStatus.Active },
      },
      select: {
        id: true,
        price_egp: true,
        lab_profile_id: true,
        lab_profile: { select: { home_collection: true } },
      },
    });

    if (!test) {
      throw new NotFoundException('Selected test is not available');
    }

    if (dto.bookingType === BookingType.HomeCollection && !test.lab_profile.home_collection) {
      throw new BadRequestException('This lab does not support home collection');
    }

    const normalizedAddress = dto.homeAddress?.trim();
    if (dto.bookingType === BookingType.HomeCollection && !normalizedAddress) {
      throw new BadRequestException('Home address is required for home collection');
    }

    const slot = await this.prisma.labScheduleSlot.findFirst({
      where: {
        id: dto.slotId,
        lab_profile_id: dto.labId,
        is_active: true,
      },
      select: {
        id: true,
        starts_at: true,
      },
    });

    if (!slot) {
      throw new NotFoundException('Selected slot is not available');
    }

    if (slot.starts_at.getTime() <= Date.now()) {
      throw new BadRequestException('Selected slot must be in the future');
    }

    const conflictingBooking = await this.prisma.booking.findFirst({
      where: {
        schedule_slot_id: slot.id,
        status: { in: ACTIVE_SLOT_STATUSES },
      },
      select: { id: true },
    });

    if (conflictingBooking) {
      throw new ConflictException('Selected slot is already booked');
    }

    const totalPrice =
      test.price_egp + (dto.bookingType === BookingType.HomeCollection ? 100 : 0);

    const created = await this.prisma.$transaction(async (tx: any) => {
      const booking = await tx.booking.create({
        data: {
          patient_profile_id: patientProfile.id,
          lab_profile_id: test.lab_profile_id,
          lab_test_id: test.id,
          booking_type: dto.bookingType,
          status: BookingStatus.Pending,
          scheduled_at: slot.starts_at,
          home_address:
            dto.bookingType === BookingType.HomeCollection
              ? normalizedAddress
              : patientProfile.address ?? null,
          total_price_egp: totalPrice,
          schedule_slot_id: slot.id,
        },
        include: this.bookingInclude(),
      });

      await tx.bookingStatusEvent.create({
        data: {
          booking_id: booking.id,
          status: BookingStatus.Pending,
          note: 'Booking created by patient',
          actor_user_id: userId,
        },
      });

      return tx.booking.findUniqueOrThrow({
        where: { id: booking.id },
        include: this.bookingInclude(),
      });
    });

    return this.toBookingResponse(created);
  }

  async listPatientBookings(userId: string) {
    const patientProfile = await this.prisma.patientProfile.findUnique({
      where: { user_id: userId },
      select: { id: true },
    });

    if (!patientProfile) {
      throw new ForbiddenException('Only patients can access patient bookings');
    }

    const bookings = await this.prisma.booking.findMany({
      where: { patient_profile_id: patientProfile.id },
      orderBy: { scheduled_at: 'desc' },
      include: this.bookingInclude(),
    });

    return { items: (bookings as BookingWithRelations[]).map((booking: BookingWithRelations) => this.toBookingResponse(booking)) };
  }

  async listLabBookings(userId: string) {
    const labProfile = await this.prisma.labProfile.findUnique({
      where: { user_id: userId },
      select: { id: true },
    });

    if (!labProfile) {
      throw new ForbiddenException('Only lab staff can access lab bookings');
    }

    const bookings = await this.prisma.booking.findMany({
      where: { lab_profile_id: labProfile.id },
      orderBy: { scheduled_at: 'desc' },
      include: this.bookingInclude(),
    });

    return { items: (bookings as BookingWithRelations[]).map((booking: BookingWithRelations) => this.toBookingResponse(booking)) };
  }

  async cancelByPatient(userId: string, bookingId: string) {
    const patientProfile = await this.prisma.patientProfile.findUnique({
      where: { user_id: userId },
      select: { id: true },
    });

    if (!patientProfile) {
      throw new ForbiddenException('Only patients can cancel bookings');
    }

    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { id: true, status: true, patient_profile_id: true },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.patient_profile_id !== patientProfile.id) {
      throw new ForbiddenException('You can only cancel your own bookings');
    }

    if (
      booking.status !== BookingStatus.Pending &&
      booking.status !== BookingStatus.Confirmed
    ) {
      throw new BadRequestException('Booking cannot be cancelled in its current status');
    }

    const updated = await this.prisma.$transaction(async (tx: any) => {
      const record = await tx.booking.update({
        where: { id: booking.id },
        data: {
          status: BookingStatus.Cancelled,
          schedule_slot_id: null,
        },
        include: this.bookingInclude(),
      });

      await tx.bookingStatusEvent.create({
        data: {
          booking_id: booking.id,
          status: BookingStatus.Cancelled,
          note: 'Cancelled by patient',
          actor_user_id: userId,
        },
      });

      return tx.booking.findUniqueOrThrow({
        where: { id: booking.id },
        include: this.bookingInclude(),
      });
    });

    return this.toBookingResponse(updated);
  }

  async setLabBookingStatus(
    userId: string,
    bookingId: string,
    status: BookingStatus,
  ) {
    if (status !== BookingStatus.Confirmed && status !== BookingStatus.Rejected) {
      throw new BadRequestException('Labs can only set status to Confirmed or Rejected');
    }

    const labProfile = await this.prisma.labProfile.findUnique({
      where: { user_id: userId },
      select: { id: true, onboarding_status: true },
    });

    if (!labProfile) {
      throw new ForbiddenException('Only lab staff can update booking status');
    }

    if (labProfile.onboarding_status !== LabOnboardingStatus.Active) {
      throw new ForbiddenException('Lab account is not active');
    }

    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { id: true, status: true, lab_profile_id: true },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.lab_profile_id !== labProfile.id) {
      throw new ForbiddenException('You can only update your own lab bookings');
    }

    if (booking.status !== BookingStatus.Pending) {
      throw new BadRequestException('Only pending bookings can be updated by lab');
    }

    const updated = await this.prisma.$transaction(async (tx: any) => {
      await tx.booking.update({
        where: { id: booking.id },
        data: {
          status,
          ...(status === BookingStatus.Rejected ? { schedule_slot_id: null } : {}),
        },
      });

      await tx.bookingStatusEvent.create({
        data: {
          booking_id: booking.id,
          status,
          note: status === BookingStatus.Confirmed ? 'Confirmed by lab' : 'Rejected by lab',
          actor_user_id: userId,
        },
      });

      return tx.booking.findUniqueOrThrow({
        where: { id: booking.id },
        include: this.bookingInclude(),
      });
    });

    return this.toBookingResponse(updated);
  }

  private bookingInclude() {
    return {
      patient_profile: { select: { id: true, full_name: true, phone: true, address: true } },
      lab_profile: { select: { id: true, lab_name: true, address: true, home_collection: true } },
      lab_test: { select: { id: true, name: true, price_egp: true } },
      schedule_slot: { select: { id: true, starts_at: true, ends_at: true } },
      status_events: {
        orderBy: { created_at: 'asc' as const },
        select: { id: true, status: true, note: true, created_at: true, actor_user_id: true },
      },
    };
  }

  private toBookingResponse(booking: BookingWithRelations) {
    return {
      id: booking.id,
      status: booking.status,
      bookingType: booking.booking_type,
      scheduledAt: booking.scheduled_at.toISOString(),
      homeAddress: booking.home_address ?? null,
      totalPriceEgp: booking.total_price_egp,
      createdAt: booking.created_at.toISOString(),
      patient: {
        id: booking.patient_profile.id,
        fullName: booking.patient_profile.full_name,
        phone: booking.patient_profile.phone,
      },
      lab: {
        id: booking.lab_profile.id,
        name: booking.lab_profile.lab_name,
        address: booking.lab_profile.address,
        homeCollection: booking.lab_profile.home_collection,
      },
      test: {
        id: booking.lab_test.id,
        name: booking.lab_test.name,
        priceEgp: booking.lab_test.price_egp,
      },
      slot: booking.schedule_slot
        ? {
            id: booking.schedule_slot.id,
            startsAt: booking.schedule_slot.starts_at.toISOString(),
            endsAt: booking.schedule_slot.ends_at.toISOString(),
          }
        : null,
      timeline: booking.status_events.map((event: BookingWithRelations['status_events'][number]) => ({
        id: event.id,
        status: event.status,
        note: event.note ?? null,
        actorUserId: event.actor_user_id ?? null,
        createdAt: event.created_at.toISOString(),
      })),
    };
  }
}
