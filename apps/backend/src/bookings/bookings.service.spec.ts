import { BadRequestException, ConflictException, ForbiddenException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  BookingStatus,
  BookingType,
  KitStatus,
  LabOnboardingStatus,
  PaymentMethod,
  PaymentStatus,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { BookingsService } from './bookings.service';
import { AuditLogService } from '../common/services/audit-log.service';

function bookingRecord(overrides?: Partial<any>) {
  return {
    id: 'booking-1',
    booking_type: BookingType.LabVisit,
    status: BookingStatus.Pending,
    scheduled_at: new Date('2026-04-01T10:00:00.000Z'),
    home_address: null,
    total_price_egp: 450,
    payment_method: PaymentMethod.Online,
    payment_status: PaymentStatus.Pending,
    payment_reference: null,
    payment_paid_at: null,
    payment_failed_at: null,
    payment_failure_reason: null,
    created_at: new Date('2026-03-28T10:00:00.000Z'),
    patient_profile: {
      id: 'patient-profile-1',
      full_name: 'Test Patient',
      phone: '+20 10 0000 0000',
      address: 'Cairo',
    },
    lab_profile: {
      id: 'lab-profile-1',
      lab_name: 'Lab One',
      address: 'Downtown Cairo',
      home_collection: true,
      home_test_kit: false,
    },
    kit_status: null,
    kit_tracking_number: null,
    kit_shipped_at: null,
    kit_delivered_at: null,
    sample_received_at: null,
    lab_test: {
      id: 'test-1',
      name: 'CBC',
      price_egp: 450,
    },
    schedule_slot: {
      id: 'slot-1',
      starts_at: new Date('2026-04-01T10:00:00.000Z'),
      ends_at: new Date('2026-04-01T10:30:00.000Z'),
    },
    status_events: [
      {
        id: 'evt-1',
        status: BookingStatus.Pending,
        note: 'Created',
        created_at: new Date('2026-03-28T10:00:00.000Z'),
        actor_user_id: 'patient-1',
      },
    ],
    ...overrides,
  };
}

describe('BookingsService', () => {
  let service: BookingsService;

  const prismaMock = {
    labTest: {
      findFirst: jest.fn(),
    },
    labScheduleSlot: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
    },
    patientProfile: {
      findUnique: jest.fn(),
    },
    labProfile: {
      findUnique: jest.fn(),
    },
    booking: {
      findFirst: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    bookingStatusEvent: {
      create: jest.fn(),
    },
    $transaction: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BookingsService,
        {
          provide: PrismaService,
          useValue: prismaMock,
        },
        {
          provide: AuditLogService,
          useValue: { log: jest.fn() },
        },
      ],
    }).compile();

    service = module.get<BookingsService>(BookingsService);
    jest.clearAllMocks();
  });

  it('filters out unavailable slots in availability', async () => {
    prismaMock.labTest.findFirst.mockResolvedValue({ id: 'test-1' });
    prismaMock.labScheduleSlot.findMany.mockResolvedValue([
      {
        id: 'slot-1',
        starts_at: new Date('2026-04-01T10:00:00.000Z'),
        ends_at: new Date('2026-04-01T10:30:00.000Z'),
        booking: null,
      },
      {
        id: 'slot-2',
        starts_at: new Date('2026-04-01T11:00:00.000Z'),
        ends_at: new Date('2026-04-01T11:30:00.000Z'),
        booking: { id: 'b2', status: BookingStatus.Pending },
      },
      {
        id: 'slot-3',
        starts_at: new Date('2026-04-01T12:00:00.000Z'),
        ends_at: new Date('2026-04-01T12:30:00.000Z'),
        booking: { id: 'b3', status: BookingStatus.Cancelled },
      },
    ]);

    const response = await service.getAvailability({
      labId: 'lab-profile-1',
      testId: 'test-1',
      days: 7,
    });

    expect(response.items).toHaveLength(2);
    expect(response.items.map((slot: { id: string }) => slot.id)).toEqual(['slot-1', 'slot-3']);
  });

  it('requires home address for home collection bookings', async () => {
    prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-profile-1', address: null });
    prismaMock.labTest.findFirst.mockResolvedValue({
      id: 'test-1',
      price_egp: 450,
      lab_profile_id: 'lab-profile-1',
      lab_profile: { home_collection: true },
    });

    await expect(
      service.createBooking('patient-1', {
        labId: 'lab-profile-1',
        testId: 'test-1',
        slotId: 'slot-1',
        bookingType: BookingType.HomeCollection,
      }),
    ).rejects.toThrow(BadRequestException);
  });

  it('prevents creating booking on occupied slots', async () => {
    prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-profile-1', address: 'Cairo' });
    prismaMock.labTest.findFirst.mockResolvedValue({
      id: 'test-1',
      price_egp: 450,
      lab_profile_id: 'lab-profile-1',
      lab_profile: { home_collection: true },
    });
    prismaMock.labScheduleSlot.findFirst.mockResolvedValue({
      id: 'slot-1',
      starts_at: new Date('2099-01-01T09:00:00.000Z'),
    });
    prismaMock.booking.findFirst.mockResolvedValue({ id: 'booking-existing' });

    await expect(
      service.createBooking('patient-1', {
        labId: 'lab-profile-1',
        testId: 'test-1',
        slotId: 'slot-1',
        bookingType: BookingType.LabVisit,
      }),
    ).rejects.toThrow(ConflictException);
  });

  it('cancels booking by patient and frees slot reference', async () => {
    prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-profile-1' });
    prismaMock.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      status: BookingStatus.Pending,
      patient_profile_id: 'patient-profile-1',
      payment_status: PaymentStatus.Pending,
    });

    const tx = {
      booking: {
        update: jest.fn().mockResolvedValue(bookingRecord()),
        findUniqueOrThrow: jest.fn().mockResolvedValue(bookingRecord({ status: BookingStatus.Cancelled, schedule_slot: null })),
      },
      bookingStatusEvent: {
        create: jest.fn().mockResolvedValue({ id: 'evt-2' }),
      },
    };
    prismaMock.$transaction.mockImplementation(async (cb: any) => cb(tx));

    const result = await service.cancelByPatient('patient-1', 'booking-1');

    expect(tx.booking.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ status: BookingStatus.Cancelled, schedule_slot_id: null }),
      }),
    );
    expect(result.status).toBe(BookingStatus.Cancelled);
  });

  it('rejects lab status update when booking is not pending', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({
      id: 'lab-profile-1',
      onboarding_status: LabOnboardingStatus.Active,
    });
    prismaMock.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      status: BookingStatus.Confirmed,
      lab_profile_id: 'lab-profile-1',
      payment_method: PaymentMethod.Online,
      payment_status: PaymentStatus.Paid,
    });

    await expect(
      service.setLabBookingStatus('lab-user-1', 'booking-1', BookingStatus.Rejected),
    ).rejects.toThrow(BadRequestException);
  });

  it('blocks lab confirmation when online payment is not completed', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({
      id: 'lab-profile-1',
      onboarding_status: LabOnboardingStatus.Active,
    });
    prismaMock.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      status: BookingStatus.Pending,
      lab_profile_id: 'lab-profile-1',
      payment_method: PaymentMethod.Online,
      payment_status: PaymentStatus.Pending,
    });

    await expect(
      service.setLabBookingStatus('lab-user-1', 'booking-1', BookingStatus.Confirmed),
    ).rejects.toThrow(BadRequestException);
  });

  it('allows lab rejection and releases schedule slot', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({
      id: 'lab-profile-1',
      onboarding_status: LabOnboardingStatus.Active,
    });
    prismaMock.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      status: BookingStatus.Pending,
      lab_profile_id: 'lab-profile-1',
      payment_method: PaymentMethod.Online,
      payment_status: PaymentStatus.Pending,
    });

    const tx = {
      booking: {
        update: jest.fn().mockResolvedValue({ id: 'booking-1' }),
        findUniqueOrThrow: jest
          .fn()
          .mockResolvedValue(bookingRecord({ status: BookingStatus.Rejected, schedule_slot: null })),
      },
      bookingStatusEvent: {
        create: jest.fn().mockResolvedValue({ id: 'evt-2' }),
      },
    };
    prismaMock.$transaction.mockImplementation(async (cb: any) => cb(tx));

    const result = await service.setLabBookingStatus(
      'lab-user-1',
      'booking-1',
      BookingStatus.Rejected,
    );

    expect(tx.booking.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ status: BookingStatus.Rejected, schedule_slot_id: null }),
      }),
    );
    expect(result.status).toBe(BookingStatus.Rejected);
  });

  describe('HomeTestKit bookings', () => {
    it('rejects HomeTestKit when lab does not have home_test_kit flag', async () => {
      prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-profile-1', address: 'Cairo' });
      prismaMock.labTest.findFirst.mockResolvedValue({
        id: 'test-1',
        price_egp: 450,
        lab_profile_id: 'lab-profile-1',
        lab_profile: { home_collection: false, home_test_kit: false },
      });

      await expect(
        service.createBooking('patient-1', {
          labId: 'lab-profile-1',
          testId: 'test-1',
          bookingType: BookingType.HomeTestKit,
          homeAddress: '45 Tahrir Square, Cairo',
          paymentMethod: PaymentMethod.CashOnDelivery,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('requires home address for HomeTestKit bookings', async () => {
      prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-profile-1', address: null });
      prismaMock.labTest.findFirst.mockResolvedValue({
        id: 'test-1',
        price_egp: 450,
        lab_profile_id: 'lab-profile-1',
        lab_profile: { home_collection: false, home_test_kit: true },
      });

      await expect(
        service.createBooking('patient-1', {
          labId: 'lab-profile-1',
          testId: 'test-1',
          bookingType: BookingType.HomeTestKit,
          paymentMethod: PaymentMethod.CashOnDelivery,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('creates HomeTestKit booking without a slot, adds 150 EGP fee, and starts at AwaitingShipment', async () => {
      prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-profile-1', address: 'Cairo' });
      prismaMock.labTest.findFirst.mockResolvedValue({
        id: 'test-1',
        price_egp: 450,
        lab_profile_id: 'lab-profile-1',
        lab_profile: { home_collection: false, home_test_kit: true },
      });

      const created = bookingRecord({
        booking_type: BookingType.HomeTestKit,
        total_price_egp: 600,
        kit_status: KitStatus.AwaitingShipment,
        home_address: '45 Tahrir Square, Cairo',
        payment_method: PaymentMethod.CashOnDelivery,
        schedule_slot: null,
      });

      const tx = {
        booking: {
          create: jest.fn().mockResolvedValue(created),
          findUniqueOrThrow: jest.fn().mockResolvedValue(created),
        },
        bookingStatusEvent: { create: jest.fn().mockResolvedValue({ id: 'evt-1' }) },
      };
      prismaMock.$transaction.mockImplementation(async (cb: any) => cb(tx));

      const result = await service.createBooking('patient-1', {
        labId: 'lab-profile-1',
        testId: 'test-1',
        bookingType: BookingType.HomeTestKit,
        homeAddress: '45 Tahrir Square, Cairo',
        paymentMethod: PaymentMethod.CashOnDelivery,
      });

      expect(tx.booking.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            booking_type: BookingType.HomeTestKit,
            total_price_egp: 600,
            kit_status: KitStatus.AwaitingShipment,
            schedule_slot_id: null,
          }),
        }),
      );
      expect(result.kitStatus).toBe(KitStatus.AwaitingShipment);
      expect(result.totalPriceEgp).toBe(600);
    });

    it('rejects CashOnDelivery for non-kit booking types', async () => {
      prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-profile-1', address: 'Cairo' });
      prismaMock.labTest.findFirst.mockResolvedValue({
        id: 'test-1',
        price_egp: 450,
        lab_profile_id: 'lab-profile-1',
        lab_profile: { home_collection: true, home_test_kit: false },
      });

      await expect(
        service.createBooking('patient-1', {
          labId: 'lab-profile-1',
          testId: 'test-1',
          slotId: 'slot-1',
          bookingType: BookingType.HomeCollection,
          homeAddress: '45 Tahrir Square, Cairo',
          paymentMethod: PaymentMethod.CashOnDelivery,
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('updateKitStatus', () => {
    it('advances kit status one stage at a time and stores tracking number', async () => {
      prismaMock.labProfile.findUnique.mockResolvedValue({
        id: 'lab-profile-1',
        onboarding_status: LabOnboardingStatus.Active,
      });
      prismaMock.booking.findUnique.mockResolvedValue({
        id: 'booking-1',
        lab_profile_id: 'lab-profile-1',
        booking_type: BookingType.HomeTestKit,
        kit_status: KitStatus.AwaitingShipment,
        status: BookingStatus.Confirmed,
      });

      const updated = bookingRecord({
        booking_type: BookingType.HomeTestKit,
        kit_status: KitStatus.Shipped,
        kit_tracking_number: 'TRACK-001',
        schedule_slot: null,
      });
      prismaMock.booking.update.mockResolvedValue(updated);

      const result = await service.updateKitStatus('lab-user-1', 'booking-1', {
        kitStatus: KitStatus.Shipped,
        trackingNumber: 'TRACK-001',
      });

      expect(prismaMock.booking.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            kit_status: KitStatus.Shipped,
            kit_tracking_number: 'TRACK-001',
          }),
        }),
      );
      expect(result.kitStatus).toBe(KitStatus.Shipped);
    });

    it('rejects skipping a stage (AwaitingShipment → Delivered)', async () => {
      prismaMock.labProfile.findUnique.mockResolvedValue({
        id: 'lab-profile-1',
        onboarding_status: LabOnboardingStatus.Active,
      });
      prismaMock.booking.findUnique.mockResolvedValue({
        id: 'booking-1',
        lab_profile_id: 'lab-profile-1',
        booking_type: BookingType.HomeTestKit,
        kit_status: KitStatus.AwaitingShipment,
        status: BookingStatus.Confirmed,
      });

      await expect(
        service.updateKitStatus('lab-user-1', 'booking-1', { kitStatus: KitStatus.Delivered }),
      ).rejects.toThrow(BadRequestException);
    });

    it('rejects kit status update for a booking belonging to another lab', async () => {
      prismaMock.labProfile.findUnique.mockResolvedValue({
        id: 'lab-profile-OTHER',
        onboarding_status: LabOnboardingStatus.Active,
      });
      prismaMock.booking.findUnique.mockResolvedValue({
        id: 'booking-1',
        lab_profile_id: 'lab-profile-1',
        booking_type: BookingType.HomeTestKit,
        kit_status: KitStatus.AwaitingShipment,
        status: BookingStatus.Confirmed,
      });

      await expect(
        service.updateKitStatus('other-lab-user', 'booking-1', { kitStatus: KitStatus.Shipped }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('rejects kit status update on a non-kit booking', async () => {
      prismaMock.labProfile.findUnique.mockResolvedValue({
        id: 'lab-profile-1',
        onboarding_status: LabOnboardingStatus.Active,
      });
      prismaMock.booking.findUnique.mockResolvedValue({
        id: 'booking-1',
        lab_profile_id: 'lab-profile-1',
        booking_type: BookingType.LabVisit,
        kit_status: null,
        status: BookingStatus.Confirmed,
      });

      await expect(
        service.updateKitStatus('lab-user-1', 'booking-1', { kitStatus: KitStatus.Shipped }),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
