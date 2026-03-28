import { BadRequestException, ConflictException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { BookingStatus, BookingType, LabOnboardingStatus } from '@prisma/client';
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
    },
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
    });

    await expect(
      service.setLabBookingStatus('lab-user-1', 'booking-1', BookingStatus.Rejected),
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
});
