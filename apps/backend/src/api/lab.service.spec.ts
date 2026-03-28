import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { BookingStatus, ResultStatus } from '@prisma/client';
import { BookingsService } from '../bookings/bookings.service';
import { LabService } from './lab.service';
import { LabStorageService } from './lab-storage.service';
import { UploadedLabFile } from './lab-storage.service';
import { AuditLogService } from '../common/services/audit-log.service';

describe('LabService', () => {
  const prismaMock = {
    labProfile: {
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    booking: {
      findUnique: jest.fn(),
      count: jest.fn(),
      findMany: jest.fn(),
      groupBy: jest.fn(),
    },
    labTest: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    labScheduleSlot: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      count: jest.fn(),
    },
    resultFile: {
      findUnique: jest.fn(),
    },
    $transaction: jest.fn(),
  } as any;

  const bookingsServiceMock = {
    listLabBookings: jest.fn(),
  } as unknown as BookingsService;

  const storageMock = {
    saveResultFile: jest.fn(),
  } as unknown as LabStorageService;

  let service: LabService;
  const auditMock = { log: jest.fn() } as unknown as AuditLogService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new LabService(prismaMock, bookingsServiceMock, storageMock, auditMock);
  });

  it('rejects schedule slot with invalid range', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({ id: 'lab-1' });

    await expect(
      service.createScheduleSlot('lab-user', {
        startsAt: '2099-01-02T10:00:00.000Z',
        endsAt: '2099-01-02T09:00:00.000Z',
      }),
    ).rejects.toThrow(BadRequestException);
  });

  it('rejects non-pdf uploads', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({ id: 'lab-1' });

    await expect(
      service.uploadResult(
        'lab-user',
        'booking-1',
        {
          mimetype: 'image/png',
          originalname: 'test.png',
          size: 123,
          buffer: Buffer.from('x'),
        } as UploadedLabFile,
        { summary: 'summary' },
      ),
    ).rejects.toThrow(BadRequestException);
  });

  it('rejects upload for booking outside current lab', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({ id: 'lab-1' });
    prismaMock.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      lab_profile_id: 'lab-other',
      status: BookingStatus.Confirmed,
    });

    await expect(
      service.uploadResult(
        'lab-user',
        'booking-1',
        {
          mimetype: 'application/pdf',
          originalname: 'result.pdf',
          size: 123,
          buffer: Buffer.from('x'),
        } as UploadedLabFile,
        { summary: 'summary' },
      ),
    ).rejects.toThrow(ForbiddenException);
  });

  it('uploads result and creates summary', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({ id: 'lab-1' });
    prismaMock.booking.findUnique.mockResolvedValue({
      id: 'booking-1',
      lab_profile_id: 'lab-1',
      status: BookingStatus.Confirmed,
    });
    (storageMock.saveResultFile as jest.Mock).mockResolvedValue({
      fileName: 'result.pdf',
      fileUrl: '/uploads/results/result.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 100,
    });

    const tx = {
      resultFile: {
        upsert: jest.fn().mockResolvedValue({
          status: ResultStatus.Uploaded,
          file_name: 'result.pdf',
          file_url: '/uploads/results/result.pdf',
        }),
      },
      resultSummary: {
        upsert: jest.fn().mockResolvedValue({ id: 'summary-1' }),
      },
      bookingStatusEvent: {
        create: jest.fn().mockResolvedValue({ id: 'event-1' }),
      },
    };

    prismaMock.$transaction.mockImplementation(async (cb: any) => cb(tx));

    const result = await service.uploadResult(
      'lab-user',
      'booking-1',
      {
        mimetype: 'application/pdf',
        originalname: 'result.pdf',
        size: 123,
        buffer: Buffer.from('x'),
      } as UploadedLabFile,
      { summary: 'All good', highlights: '{"h":1}' },
    );

    expect(tx.resultFile.upsert).toHaveBeenCalled();
    expect(tx.resultSummary.upsert).toHaveBeenCalled();
    expect(result.resultStatus).toBe(ResultStatus.Uploaded);
  });

  it('marks delivered status and completes booking', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({ id: 'lab-1' });
    prismaMock.booking.findUnique.mockResolvedValue({ id: 'booking-1', lab_profile_id: 'lab-1' });
    prismaMock.resultFile.findUnique.mockResolvedValue({ id: 'result-1' });

    const tx = {
      resultFile: {
        update: jest.fn().mockResolvedValue({ status: ResultStatus.Delivered }),
      },
      booking: {
        update: jest.fn().mockResolvedValue({ id: 'booking-1' }),
      },
      bookingStatusEvent: {
        create: jest.fn().mockResolvedValue({ id: 'event-1' }),
      },
    };

    prismaMock.$transaction.mockImplementation(async (cb: any) => cb(tx));

    const result = await service.setResultStatus('lab-user', 'booking-1', {
      status: ResultStatus.Delivered,
    });

    expect(tx.booking.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: { status: BookingStatus.Completed },
      }),
    );
    expect(result.resultStatus).toBe(ResultStatus.Delivered);
  });

  it('deletes test when it has no linked bookings', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({ id: 'lab-1' });
    prismaMock.labTest.findUnique.mockResolvedValue({ id: 'test-1', lab_profile_id: 'lab-1' });
    prismaMock.booking.count.mockResolvedValue(0);
    prismaMock.labTest.delete.mockResolvedValue({ id: 'test-1' });

    const result = await service.deleteLabTest('lab-user', 'test-1');

    expect(prismaMock.labTest.delete).toHaveBeenCalledWith({ where: { id: 'test-1' } });
    expect(result).toEqual({ success: true });
  });

  it('rejects deleting test with existing bookings', async () => {
    prismaMock.labProfile.findUnique.mockResolvedValue({ id: 'lab-1' });
    prismaMock.labTest.findUnique.mockResolvedValue({ id: 'test-1', lab_profile_id: 'lab-1' });
    prismaMock.booking.count.mockResolvedValue(2);

    await expect(service.deleteLabTest('lab-user', 'test-1')).rejects.toThrow(BadRequestException);
  });
});
