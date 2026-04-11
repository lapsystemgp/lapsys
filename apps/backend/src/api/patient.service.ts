import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ResultStatus, ReviewStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { UpdatePatientProfileDto } from './dto/update-patient-profile.dto';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class PatientService {
  constructor(private readonly prisma: PrismaService) {}

  async getWorkspace(userId: string) {
    const patientProfile = await this.prisma.patientProfile.findUnique({
      where: { user_id: userId },
      include: { user: { select: { email: true } } },
    });

    if (!patientProfile) {
      throw new ForbiddenException('Only patients can access workspace');
    }

    const now = new Date();

    const bookings = await this.prisma.booking.findMany({
      where: { patient_profile_id: patientProfile.id },
      orderBy: { scheduled_at: 'desc' },
      include: {
        lab_profile: { select: { id: true, lab_name: true, address: true } },
        lab_test: { select: { id: true, name: true, price_egp: true } },
        status_events: {
          orderBy: { created_at: 'asc' },
          select: { id: true, status: true, note: true, created_at: true },
        },
        result_file: {
          select: {
            id: true,
            status: true,
            file_name: true,
            file_url: true,
            mime_type: true,
            size_bytes: true,
            uploaded_at: true,
          },
        },
        result_summary: {
          select: { summary: true, highlights: true },
        },
        result_panels: {
          select: {
            _count: { select: { observations: true } },
          },
        },
        review: {
          select: { id: true, rating: true, comment: true, status: true, created_at: true },
        },
      },
    });

    const mappedBookings = bookings.map((booking) => ({
      id: booking.id,
      status: booking.status,
      bookingType: booking.booking_type,
      scheduledAt: booking.scheduled_at.toISOString(),
      totalPriceEgp: booking.total_price_egp,
      homeAddress: booking.home_address ?? null,
      paymentMethod: booking.payment_method,
      paymentStatus: booking.payment_status,
      paymentReference: booking.payment_reference ?? null,
      paymentPaidAt: booking.payment_paid_at ? booking.payment_paid_at.toISOString() : null,
      paymentFailedAt: booking.payment_failed_at ? booking.payment_failed_at.toISOString() : null,
      paymentFailureReason: booking.payment_failure_reason ?? null,
      lab: {
        id: booking.lab_profile.id,
        name: booking.lab_profile.lab_name,
        address: booking.lab_profile.address,
      },
      test: {
        id: booking.lab_test.id,
        name: booking.lab_test.name,
        priceEgp: booking.lab_test.price_egp,
      },
      timeline: booking.status_events.map((event) => ({
        id: event.id,
        status: event.status,
        note: event.note ?? null,
        createdAt: event.created_at.toISOString(),
      })),
    }));

    const results = bookings
      .filter((booking) => !!booking.result_file || !!booking.result_summary)
      .map((booking) => {
        const structuredObservationCount = booking.result_panels.reduce(
          (sum, panel) => sum + panel._count.observations,
          0,
        );
        const hasStructuredData = structuredObservationCount > 0;

        return {
        bookingId: booking.id,
        bookingStatus: booking.status,
        scheduledAt: booking.scheduled_at.toISOString(),
        labName: booking.lab_profile.lab_name,
        testName: booking.lab_test.name,
        resultStatus: booking.result_file?.status ?? ResultStatus.Pending,
        hasStructuredData,
        structuredObservationCount,
        file: booking.result_file
          ? {
              id: booking.result_file.id,
              fileName: booking.result_file.file_name,
              fileUrl: booking.result_file.file_url,
              mimeType: booking.result_file.mime_type,
              sizeBytes: booking.result_file.size_bytes,
              uploadedAt: booking.result_file.uploaded_at.toISOString(),
            }
          : null,
        summary: booking.result_summary
          ? {
              summary: booking.result_summary.summary,
              highlights: booking.result_summary.highlights ?? null,
            }
          : null,
        review: booking.review
          ? {
              id: booking.review.id,
              rating: booking.review.rating,
              comment: booking.review.comment ?? null,
              status: booking.review.status,
              createdAt: booking.review.created_at.toISOString(),
            }
          : null,
        canReview: !booking.review && !!booking.result_file,
      };
      });

    return {
      profile: {
        fullName: patientProfile.full_name ?? '',
        phone: patientProfile.phone ?? '',
        address: patientProfile.address ?? '',
        email: patientProfile.user.email,
      },
      bookings: {
        upcoming: mappedBookings.filter((booking) => new Date(booking.scheduledAt).getTime() >= now.getTime()),
        past: mappedBookings.filter((booking) => new Date(booking.scheduledAt).getTime() < now.getTime()),
      },
      results,
    };
  }

  async updateProfile(userId: string, dto: UpdatePatientProfileDto) {
    const patientProfile = await this.prisma.patientProfile.findUnique({
      where: { user_id: userId },
      select: { id: true },
    });

    if (!patientProfile) {
      throw new ForbiddenException('Only patients can update profile');
    }

    const updated = await this.prisma.patientProfile.update({
      where: { id: patientProfile.id },
      data: {
        ...(dto.fullName !== undefined ? { full_name: dto.fullName.trim() } : {}),
        ...(dto.phone !== undefined ? { phone: dto.phone.trim() } : {}),
        ...(dto.address !== undefined ? { address: dto.address.trim() } : {}),
      },
      select: { full_name: true, phone: true, address: true },
    });

    return {
      fullName: updated.full_name ?? '',
      phone: updated.phone ?? '',
      address: updated.address ?? '',
    };
  }

  async createReview(userId: string, dto: CreateReviewDto) {
    const patientProfile = await this.prisma.patientProfile.findUnique({
      where: { user_id: userId },
      select: { id: true },
    });

    if (!patientProfile) {
      throw new ForbiddenException('Only patients can create reviews');
    }

    const booking = await this.prisma.booking.findUnique({
      where: { id: dto.bookingId },
      include: {
        result_file: { select: { status: true } },
        review: { select: { id: true } },
      },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.patient_profile_id !== patientProfile.id) {
      throw new ForbiddenException('You can only review your own bookings');
    }

    if (!booking.result_file) {
      throw new BadRequestException('Review is allowed only after result upload');
    }

    if (
      booking.result_file.status !== ResultStatus.Uploaded &&
      booking.result_file.status !== ResultStatus.Delivered
    ) {
      throw new BadRequestException('Review is allowed only after result delivery');
    }

    if (booking.review) {
      throw new BadRequestException('Review already submitted for this booking');
    }

    const comment = dto.comment?.trim();

    const review = await this.prisma.$transaction(async (tx: any) => {
      const createdReview = await tx.review.create({
        data: {
          booking_id: booking.id,
          patient_profile_id: booking.patient_profile_id,
          lab_profile_id: booking.lab_profile_id,
          rating: dto.rating,
          comment: comment?.length ? comment : null,
          status: ReviewStatus.Published,
        },
        select: {
          id: true,
          rating: true,
          comment: true,
          status: true,
          created_at: true,
          lab_profile_id: true,
        },
      });

      const aggregate = await tx.review.aggregate({
        where: {
          lab_profile_id: booking.lab_profile_id,
          status: ReviewStatus.Published,
        },
        _count: { _all: true },
        _avg: { rating: true },
      });

      await tx.labProfile.update({
        where: { id: booking.lab_profile_id },
        data: {
          review_count: aggregate._count._all ?? 0,
          rating_average: aggregate._avg.rating ?? null,
        },
      });

      return createdReview;
    });

    return {
      id: review.id,
      rating: review.rating,
      comment: review.comment ?? null,
      status: review.status,
      createdAt: review.created_at.toISOString(),
    };
  }
}
