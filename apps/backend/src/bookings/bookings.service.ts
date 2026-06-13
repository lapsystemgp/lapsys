import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import {
  BookingStatus,
  BookingType,
  KitStatus,
  LabOnboardingStatus,
  PaymentMethod,
  PaymentStatus,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AvailabilityQueryDto } from './dto/availability-query.dto';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateKitStatusDto } from './dto/update-kit-status.dto';
import { AuditLogService } from '../common/services/audit-log.service';
import { NotificationsService } from '../notifications/notifications.service';

type BookingWithRelations = {
  id: string;
  booking_type: BookingType;
  status: BookingStatus;
  scheduled_at: Date;
  home_address: string | null;
  total_price_egp: number;
  payment_method: PaymentMethod;
  payment_status: PaymentStatus;
  payment_reference: string | null;
  payment_paid_at: Date | null;
  payment_failed_at: Date | null;
  payment_failure_reason: string | null;
  kit_status: KitStatus | null;
  kit_tracking_number: string | null;
  kit_shipped_at: Date | null;
  kit_delivered_at: Date | null;
  sample_received_at: Date | null;
  created_at: Date;
  patient_profile: { id: string; full_name: string | null; phone: string | null; address: string | null };
  lab_profile: { id: string; lab_name: string; address: string; home_collection: boolean; home_test_kit: boolean };
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
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditLogService: AuditLogService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async getAvailability(query: AvailabilityQueryDto) {
    const days = query.days ?? 7;
    // Build window bounds in UTC so server timezone (e.g. Cairo UTC+2/+3) doesn't
    // shift the boundary and mis-bucket or drop slots near midnight.
    const dateFrom = query.dateFrom
      ? new Date(`${query.dateFrom}T00:00:00Z`)
      : new Date();
    const endDate = new Date(dateFrom);
    endDate.setUTCDate(endDate.getUTCDate() + days);

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
        lab_profile: { select: { home_collection: true, home_test_kit: true } },
      },
    });

    if (!test) {
      throw new NotFoundException('Selected test is not available');
    }

    if (dto.bookingType === BookingType.HomeCollection && !test.lab_profile.home_collection) {
      throw new BadRequestException('This lab does not support home collection');
    }

    if (dto.bookingType === BookingType.HomeTestKit && !test.lab_profile.home_test_kit) {
      throw new BadRequestException('This lab does not offer home test kits');
    }

    const normalizedAddress = dto.homeAddress?.trim();
    if (
      (dto.bookingType === BookingType.HomeCollection || dto.bookingType === BookingType.HomeTestKit) &&
      !normalizedAddress
    ) {
      throw new BadRequestException('Home address is required for home collection and home test kit bookings');
    }

    const paymentMethod = dto.paymentMethod ?? PaymentMethod.Online;
    if (paymentMethod === PaymentMethod.CashHomeCollection && dto.bookingType !== BookingType.HomeCollection) {
      throw new BadRequestException('Cash on home collection is only available for home collection bookings');
    }
    if (paymentMethod === PaymentMethod.CashLabVisit && dto.bookingType !== BookingType.LabVisit) {
      throw new BadRequestException('Cash at lab visit is only available for lab visit bookings');
    }
    if (paymentMethod === PaymentMethod.CashOnDelivery && dto.bookingType !== BookingType.HomeTestKit) {
      throw new BadRequestException('Cash on delivery is only available for home test kit bookings');
    }

    let slot: { id: string; starts_at: Date } | null = null;
    let scheduledAt: Date;

    if (dto.bookingType === BookingType.HomeTestKit) {
      // No appointment slot for kit orders — estimate delivery in 5 days
      scheduledAt = new Date(Date.now() + 5 * 24 * 60 * 60 * 1000);
    } else {
      if (!dto.slotId) {
        throw new BadRequestException('A time slot is required for lab visit and home collection bookings');
      }
      slot = await this.prisma.labScheduleSlot.findFirst({
        where: {
          id: dto.slotId,
          lab_profile_id: dto.labId,
          is_active: true,
        },
        select: { id: true, starts_at: true },
      });

      if (!slot) {
        throw new NotFoundException('Selected slot is not available');
      }

      if (slot.starts_at.getTime() <= Date.now()) {
        throw new BadRequestException('Selected slot must be in the future');
      }

      scheduledAt = slot.starts_at;
    }

    const totalPrice =
      test.price_egp +
      (dto.bookingType === BookingType.HomeCollection ? 100 : 0) +
      (dto.bookingType === BookingType.HomeTestKit ? 150 : 0);

    const created = await this.prisma.$transaction(async (tx: any) => {
      if (slot) {
        const conflictingBooking = await tx.booking.findFirst({
          where: {
            schedule_slot_id: slot.id,
            status: { in: ACTIVE_SLOT_STATUSES },
          },
          select: { id: true },
        });

        if (conflictingBooking) {
          throw new ConflictException('Selected slot is already booked');
        }
      }

      let booking: any;
      try {
        booking = await tx.booking.create({
          data: {
            patient_profile_id: patientProfile.id,
            lab_profile_id: test.lab_profile_id,
            lab_test_id: test.id,
            booking_type: dto.bookingType,
            status: BookingStatus.Pending,
            scheduled_at: scheduledAt,
            home_address:
              dto.bookingType === BookingType.HomeCollection || dto.bookingType === BookingType.HomeTestKit
                ? normalizedAddress
                : null,
            total_price_egp: totalPrice,
            payment_method: paymentMethod,
            payment_status: PaymentStatus.Pending,
            schedule_slot_id: slot?.id ?? null,
            ...(dto.bookingType === BookingType.HomeTestKit
              ? { kit_status: KitStatus.AwaitingShipment }
              : {}),
          },
          include: this.bookingInclude(),
        });
      } catch (err: any) {
        if (err?.code === 'P2002') {
          throw new ConflictException('Selected slot is already booked');
        }
        throw err;
      }

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

    const response = this.toBookingResponse(created);
    this.auditLogService.log('booking.created', {
      bookingId: response.id,
      patientUserId: userId,
      bookingType: response.bookingType,
      status: response.status,
      paymentMethod: response.paymentMethod,
      paymentStatus: response.paymentStatus,
    });

    // Notify the lab that a new booking arrived
    const labUser = await this.prisma.labProfile.findUnique({
      where: { id: created.lab_profile.id },
      select: { user_id: true },
    });
    if (labUser) {
      this.notificationsService.sendToUser(labUser.user_id, {
        title: 'New Booking',
        body: `New booking for ${created.lab_test.name} from a patient.`,
        data: { type: 'new_booking', bookingId: response.id },
      });
    }

    return response;
  }

  /**
   * Graduation demo: simulates an online payment gateway (no real charges).
   */
  async demoOnlinePayment(userId: string, bookingId: string, outcome: 'success' | 'failure') {
    const patientProfile = await this.prisma.patientProfile.findUnique({
      where: { user_id: userId },
      select: { id: true },
    });

    if (!patientProfile) {
      throw new ForbiddenException('Only patients can complete payment');
    }

    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        patient_profile_id: true,
        payment_method: true,
        payment_status: true,
        status: true,
      },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.patient_profile_id !== patientProfile.id) {
      throw new ForbiddenException('You can only pay for your own bookings');
    }

    if (booking.payment_method !== PaymentMethod.Online) {
      throw new BadRequestException('This booking does not use online payment');
    }

    if (booking.status !== BookingStatus.Pending) {
      throw new BadRequestException('Payment can only be completed while the booking is pending');
    }

    if (booking.payment_status === PaymentStatus.Paid) {
      throw new BadRequestException('This booking is already paid');
    }

    if (booking.payment_status === PaymentStatus.Refunded) {
      throw new BadRequestException('This booking was refunded and cannot be paid again');
    }

    const now = new Date();

    const updated = await this.prisma.booking.update({
      where: { id: booking.id },
      data:
        outcome === 'success'
          ? {
              payment_status: PaymentStatus.Paid,
              payment_reference: `DEMO-PAY-${randomUUID()}`,
              payment_paid_at: now,
              payment_failed_at: null,
              payment_failure_reason: null,
            }
          : {
              payment_status: PaymentStatus.Failed,
              payment_failed_at: now,
              payment_failure_reason: 'Simulated gateway decline (demo only)',
            },
      include: this.bookingInclude(),
    });

    const response = this.toBookingResponse(updated as BookingWithRelations);
    this.auditLogService.log(
      outcome === 'success' ? 'booking.payment.demo_succeeded' : 'booking.payment.demo_failed',
      {
        bookingId: response.id,
        patientUserId: userId,
        paymentStatus: response.paymentStatus,
      },
    );
    return response;
  }

  async markCashCollected(userId: string, bookingId: string) {
    const labProfile = await this.prisma.labProfile.findUnique({
      where: { user_id: userId },
      select: { id: true, onboarding_status: true },
    });

    if (!labProfile) {
      throw new ForbiddenException('Only lab staff can record cash collection');
    }

    if (labProfile.onboarding_status !== LabOnboardingStatus.Active) {
      throw new ForbiddenException('Lab account is not active');
    }

    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        lab_profile_id: true,
        payment_method: true,
        payment_status: true,
        status: true,
      },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.lab_profile_id !== labProfile.id) {
      throw new ForbiddenException('You can only update your own lab bookings');
    }

    if (
      booking.payment_method !== PaymentMethod.CashHomeCollection &&
      booking.payment_method !== PaymentMethod.CashLabVisit &&
      booking.payment_method !== PaymentMethod.CashOnDelivery
    ) {
      throw new BadRequestException('Cash collection applies only to cash payment bookings');
    }

    if (booking.payment_status === PaymentStatus.Paid) {
      return this.toBookingResponse(
        (await this.prisma.booking.findUniqueOrThrow({
          where: { id: booking.id },
          include: this.bookingInclude(),
        })) as BookingWithRelations,
      );
    }

    if (booking.payment_status !== PaymentStatus.Pending) {
      throw new BadRequestException('Cash cannot be recorded for this payment state');
    }

    if (
      booking.status !== BookingStatus.Pending &&
      booking.status !== BookingStatus.Confirmed
    ) {
      throw new BadRequestException('Cash can only be recorded for active bookings');
    }

    const now = new Date();
    const updated = await this.prisma.booking.update({
      where: { id: booking.id },
      data: {
        payment_status: PaymentStatus.Paid,
        payment_reference: `DEMO-CASH-${now.getTime()}`,
        payment_paid_at: now,
      },
      include: this.bookingInclude(),
    });

    const response = this.toBookingResponse(updated as BookingWithRelations);
    this.auditLogService.log('booking.payment.cash_marked_collected', {
      bookingId: response.id,
      labUserId: userId,
    });
    return response;
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
      select: { id: true, status: true, patient_profile_id: true, payment_status: true },
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

    const refundPayment =
      booking.payment_status === PaymentStatus.Paid ? PaymentStatus.Refunded : undefined;

    const updated = await this.prisma.$transaction(async (tx: any) => {
      await tx.booking.update({
        where: { id: booking.id },
        data: {
          status: BookingStatus.Cancelled,
          schedule_slot_id: null,
          ...(refundPayment !== undefined ? { payment_status: refundPayment } : {}),
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

    const response = this.toBookingResponse(updated);
    this.auditLogService.log('booking.cancelled_by_patient', {
      bookingId: response.id,
      patientUserId: userId,
    });
    return response;
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
      select: {
        id: true,
        status: true,
        lab_profile_id: true,
        payment_method: true,
        payment_status: true,
      },
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

    if (
      status === BookingStatus.Confirmed &&
      booking.payment_method === PaymentMethod.Online &&
      booking.payment_status !== PaymentStatus.Paid
    ) {
      throw new BadRequestException(
        'Online payment must be completed before the lab can confirm this booking',
      );
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

    const response = this.toBookingResponse(updated);
    this.auditLogService.log('booking.status_updated_by_lab', {
      bookingId: response.id,
      labUserId: userId,
      status: response.status,
      paymentStatus: response.paymentStatus,
    });

    // Notify the patient of the confirmation or rejection
    const patientUser = await this.prisma.patientProfile.findUnique({
      where: { id: updated.patient_profile.id },
      select: { user_id: true },
    });
    if (patientUser) {
      const isConfirmed = status === BookingStatus.Confirmed;
      this.notificationsService.sendToUser(patientUser.user_id, {
        title: isConfirmed ? 'Booking Confirmed' : 'Booking Rejected',
        body: isConfirmed
          ? `Your booking for ${updated.lab_test.name} has been confirmed.`
          : `Your booking for ${updated.lab_test.name} was not accepted. You can book again.`,
        data: { type: 'booking_status', bookingId: response.id, status },
      });
    }

    return response;
  }

  private bookingInclude() {
    return {
      patient_profile: { select: { id: true, full_name: true, phone: true, address: true } },
      lab_profile: { select: { id: true, lab_name: true, address: true, home_collection: true, home_test_kit: true } },
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
      paymentMethod: booking.payment_method,
      paymentStatus: booking.payment_status,
      paymentReference: booking.payment_reference ?? null,
      paymentPaidAt: booking.payment_paid_at ? booking.payment_paid_at.toISOString() : null,
      paymentFailedAt: booking.payment_failed_at ? booking.payment_failed_at.toISOString() : null,
      paymentFailureReason: booking.payment_failure_reason ?? null,
      kitStatus: booking.kit_status ?? null,
      kitTrackingNumber: booking.kit_tracking_number ?? null,
      kitShippedAt: booking.kit_shipped_at ? booking.kit_shipped_at.toISOString() : null,
      kitDeliveredAt: booking.kit_delivered_at ? booking.kit_delivered_at.toISOString() : null,
      sampleReceivedAt: booking.sample_received_at ? booking.sample_received_at.toISOString() : null,
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
        homeTestKit: booking.lab_profile.home_test_kit,
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

  async updateKitStatus(userId: string, bookingId: string, dto: UpdateKitStatusDto) {
    const labProfile = await this.prisma.labProfile.findUnique({
      where: { user_id: userId },
      select: { id: true, onboarding_status: true },
    });

    if (!labProfile) {
      throw new ForbiddenException('Only lab staff can update kit status');
    }

    if (labProfile.onboarding_status !== LabOnboardingStatus.Active) {
      throw new ForbiddenException('Lab account is not active');
    }

    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        lab_profile_id: true,
        booking_type: true,
        kit_status: true,
        status: true,
        payment_status: true,
        payment_method: true,
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.lab_profile_id !== labProfile.id) {
      throw new ForbiddenException('You can only update your own lab bookings');
    }
    if (booking.booking_type !== BookingType.HomeTestKit) {
      throw new BadRequestException('Kit status only applies to home test kit bookings');
    }
    if (booking.status === BookingStatus.Cancelled || booking.status === BookingStatus.Rejected) {
      throw new BadRequestException('Cannot update kit status for cancelled or rejected bookings');
    }
    if (
      dto.kitStatus === KitStatus.Shipped &&
      booking.payment_method !== PaymentMethod.CashOnDelivery &&
      booking.payment_status !== PaymentStatus.Paid
    ) {
      throw new BadRequestException('Cannot ship kit before payment is completed');
    }

    const ORDER: KitStatus[] = [
      KitStatus.AwaitingShipment,
      KitStatus.Shipped,
      KitStatus.Delivered,
      KitStatus.SampleReceived,
    ];
    const currentIdx = ORDER.indexOf(booking.kit_status ?? KitStatus.AwaitingShipment);
    const newIdx = ORDER.indexOf(dto.kitStatus);

    if (newIdx !== currentIdx + 1) {
      throw new BadRequestException(
        `Kit must advance one stage at a time. Current: ${booking.kit_status ?? KitStatus.AwaitingShipment}`,
      );
    }

    const now = new Date();
    const timestampField: Record<KitStatus, string | null> = {
      [KitStatus.AwaitingShipment]: null,
      [KitStatus.Shipped]: 'kit_shipped_at',
      [KitStatus.Delivered]: 'kit_delivered_at',
      [KitStatus.SampleReceived]: 'sample_received_at',
    };

    const updated = await this.prisma.booking.update({
      where: { id: bookingId },
      data: {
        kit_status: dto.kitStatus,
        ...(dto.kitStatus === KitStatus.Shipped && dto.trackingNumber
          ? { kit_tracking_number: dto.trackingNumber }
          : {}),
        ...(timestampField[dto.kitStatus] ? { [timestampField[dto.kitStatus]!]: now } : {}),
      },
      include: this.bookingInclude(),
    });

    const response = this.toBookingResponse(updated as BookingWithRelations);
    this.auditLogService.log('booking.kit_status_updated', {
      bookingId: response.id,
      labUserId: userId,
      kitStatus: dto.kitStatus,
    });

    // Notify the patient when their kit ships
    if (dto.kitStatus === KitStatus.Shipped) {
      const patientUser = await this.prisma.patientProfile.findUnique({
        where: { id: (updated as BookingWithRelations).patient_profile.id },
        select: { user_id: true },
      });
      if (patientUser) {
        this.notificationsService.sendToUser(patientUser.user_id, {
          title: 'Kit Shipped',
          body: 'Your test kit is on the way!',
          data: {
            type: 'kit_shipped',
            bookingId: response.id,
            trackingNumber: dto.trackingNumber ?? '',
          },
        });
      }
    }

    return response;
  }
}
