import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { ResultStatus, ReviewStatus } from '@prisma/client';
import { PatientService } from './patient.service';

describe('PatientService', () => {
  const prismaMock = {
    patientProfile: {
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    booking: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
    review: {
      aggregate: jest.fn(),
    },
    labProfile: {
      update: jest.fn(),
    },
    $transaction: jest.fn(),
  } as any;

  let service: PatientService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new PatientService(prismaMock);
  });

  it('throws when non-patient updates profile', async () => {
    prismaMock.patientProfile.findUnique.mockResolvedValue(null);

    await expect(
      service.updateProfile('user-1', { fullName: 'Name' }),
    ).rejects.toThrow(ForbiddenException);
  });

  it('updates profile fields with trimming', async () => {
    prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-1' });
    prismaMock.patientProfile.update.mockResolvedValue({
      full_name: 'Mazen',
      phone: '+20 10 1234 5678',
      address: 'Cairo',
    });

    const result = await service.updateProfile('user-1', {
      fullName: '  Mazen  ',
      phone: '  +20 10 1234 5678  ',
      address: ' Cairo ',
    });

    expect(prismaMock.patientProfile.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: { full_name: 'Mazen', phone: '+20 10 1234 5678', address: 'Cairo' },
      }),
    );
    expect(result.fullName).toBe('Mazen');
  });

  it('rejects review when no result file exists', async () => {
    prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-1' });
    prismaMock.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      patient_profile_id: 'patient-1',
      lab_profile_id: 'lab-1',
      result_file: null,
      review: null,
    });

    await expect(
      service.createReview('user-1', { bookingId: 'booking-1', rating: 5 }),
    ).rejects.toThrow(BadRequestException);
  });

  it('rejects review when already submitted', async () => {
    prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-1' });
    prismaMock.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      patient_profile_id: 'patient-1',
      lab_profile_id: 'lab-1',
      result_file: { status: ResultStatus.Uploaded },
      review: { id: 'review-1' },
    });

    await expect(
      service.createReview('user-1', { bookingId: 'booking-1', rating: 4 }),
    ).rejects.toThrow(BadRequestException);
  });

  it('creates review and refreshes lab aggregate values', async () => {
    prismaMock.patientProfile.findUnique.mockResolvedValue({ id: 'patient-1' });
    prismaMock.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      patient_profile_id: 'patient-1',
      lab_profile_id: 'lab-1',
      result_file: { status: ResultStatus.Delivered },
      review: null,
    });

    const tx = {
      review: {
        create: jest.fn().mockResolvedValue({
          id: 'review-1',
          rating: 5,
          comment: 'Great',
          status: ReviewStatus.Published,
          created_at: new Date('2026-03-28T10:00:00.000Z'),
          lab_profile_id: 'lab-1',
        }),
        aggregate: jest.fn().mockResolvedValue({
          _count: { _all: 3 },
          _avg: { rating: 4.67 },
        }),
      },
      labProfile: {
        update: jest.fn().mockResolvedValue({ id: 'lab-1' }),
      },
    };

    prismaMock.$transaction.mockImplementation(async (cb: any) => cb(tx));

    const result = await service.createReview('user-1', {
      bookingId: 'booking-1',
      rating: 5,
      comment: '  Great  ',
    });

    expect(tx.review.create).toHaveBeenCalled();
    expect(tx.labProfile.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: { review_count: 3, rating_average: 4.67 },
      }),
    );
    expect(result.status).toBe(ReviewStatus.Published);
  });
});