import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  BookingStatus,
  LabHistorySharing,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

const SNIPPET_LEN = 220;
const MAX_BOOKINGS = 45;
const MAX_TREND_MARKERS = 8;
const MAX_POINTS_PER_MARKER = 4;

@Injectable()
export class LabPatientContextService {
  constructor(private readonly prisma: PrismaService) {}

  async getContext(
    labUserId: string,
    params: { bookingId?: string; patientProfileId?: string },
  ) {
    if (params.bookingId && params.patientProfileId) {
      throw new BadRequestException('Provide either bookingId or patientProfileId, not both');
    }
    if (!params.bookingId && !params.patientProfileId) {
      throw new BadRequestException('Provide bookingId or patientProfileId');
    }

    const labProfile = await this.prisma.labProfile.findUnique({
      where: { user_id: labUserId },
      select: { id: true, lab_name: true },
    });
    if (!labProfile) {
      throw new ForbiddenException('Only lab staff can access patient context');
    }

    let patientProfileId = params.patientProfileId ?? '';

    if (params.bookingId) {
      const booking = await this.prisma.booking.findUnique({
        where: { id: params.bookingId },
        select: { patient_profile_id: true, lab_profile_id: true },
      });
      if (!booking) throw new NotFoundException('Booking not found');
      if (booking.lab_profile_id !== labProfile.id) {
        throw new ForbiddenException('Booking does not belong to your lab');
      }
      patientProfileId = booking.patient_profile_id;
    } else {
      await this.assertLabPatientRelationship(labProfile.id, params.patientProfileId!);
      patientProfileId = params.patientProfileId!;
    }

    const patient = await this.prisma.patientProfile.findUnique({
      where: { id: patientProfileId },
      include: { user: { select: { email: true } } },
    });
    if (!patient) throw new NotFoundException('Patient not found');

    const fullHistory = patient.lab_history_sharing === LabHistorySharing.FULL_HISTORY_AUTHORIZED;

    const bookingWhere: Prisma.BookingWhereInput = fullHistory
      ? { patient_profile_id: patientProfileId }
      : { patient_profile_id: patientProfileId, lab_profile_id: labProfile.id };

    const bookings = await this.prisma.booking.findMany({
      where: bookingWhere,
      orderBy: { scheduled_at: 'desc' },
      take: MAX_BOOKINGS,
      include: {
        lab_profile: { select: { id: true, lab_name: true } },
        lab_test: { select: { id: true, name: true } },
        result_file: { select: { id: true, file_url: true, status: true, file_name: true } },
        result_summary: { select: { summary: true } },
        result_panels: {
          include: {
            observations: {
              include: {
                canonical_marker: {
                  select: { code: true, display_name: true, default_unit: true },
                },
              },
            },
          },
        },
      },
    });

    const priorBookings = bookings.map((b) => {
      const isThisLab = b.lab_profile_id === labProfile.id;
      const showSummary =
        fullHistory || isThisLab
          ? (b.result_summary?.summary ?? null)
          : null;
      const summaryPreview =
        showSummary && showSummary.length > SNIPPET_LEN
          ? `${showSummary.slice(0, SNIPPET_LEN)}…`
          : showSummary;

      const structuredSummary: Array<{
        displayName: string;
        code: string | null;
        value: string;
        unit: string | null;
        testDate: string;
      }> = [];

      if (fullHistory || isThisLab) {
        for (const panel of b.result_panels) {
          for (const obs of panel.observations) {
            const name = obs.canonical_marker?.display_name ?? obs.raw_name;
            const unit = obs.comparable_unit ?? obs.unit ?? obs.canonical_marker?.default_unit ?? null;
            let value: string;
            if (obs.value_in_canonical_unit != null && obs.is_comparable) {
              value = obs.value_in_canonical_unit.toString();
            } else if (obs.value_numeric != null) {
              value = obs.value_numeric.toString();
            } else if (obs.value_text) {
              value = obs.value_text;
            } else {
              value = '—';
            }
            structuredSummary.push({
              displayName: name,
              code: obs.canonical_marker?.code ?? null,
              value,
              unit,
              testDate: panel.test_date.toISOString(),
            });
          }
        }
      }

      const pdfAvailable = isThisLab && !!b.result_file && !!b.result_file.file_url;
      const pdfUrl = pdfAvailable ? b.result_file!.file_url : null;

      return {
        bookingId: b.id,
        scheduledAt: b.scheduled_at.toISOString(),
        status: b.status,
        testName: b.lab_test.name,
        labId: b.lab_profile.id,
        labName: b.lab_profile.lab_name,
        isThisLab,
        hasResult: !!(b.result_file || b.result_summary),
        summaryPreview,
        structuredSummary,
        pdfAvailable,
        pdfUrl,
      };
    });

    const testNameCounts = new Map<string, number>();
    for (const b of bookings) {
      if (
        b.status === BookingStatus.Completed ||
        b.result_file ||
        b.result_summary
      ) {
        const name = b.lab_test.name;
        testNameCounts.set(name, (testNameCounts.get(name) ?? 0) + 1);
      }
    }
    const recurringTestsSummary = [...testNameCounts.entries()]
      .filter(([, count]) => count >= 2)
      .map(([name, count]) => `${name}: ${count} recorded visits in this view`);

    const trendSummary = await this.buildTrendSummary(
      patientProfileId,
      labProfile.id,
      fullHistory,
    );

    const privacyNotice = fullHistory
      ? 'Patient authorized cross-lab history. Official PDFs are only available for your lab’s uploads; other labs’ documents are not exposed.'
      : 'Privacy mode: only bookings and results from your lab are shown. The patient can opt in to share broader history from their profile.';

    return {
      lab: { id: labProfile.id, name: labProfile.lab_name },
      patientProfileId: patient.id,
      demographics: {
        fullName: patient.full_name ?? '',
        phone: patient.phone ?? '',
        address: patient.address ?? '',
        email: patient.user.email,
      },
      patientSharing: patient.lab_history_sharing,
      effectiveScopeForThisLab: fullHistory ? 'full_history' : 'same_lab',
      privacyNotice,
      priorBookings,
      recurringTestsSummary,
      trendSummary,
    };
  }

  private async assertLabPatientRelationship(labProfileId: string, patientProfileId: string) {
    const count = await this.prisma.booking.count({
      where: {
        lab_profile_id: labProfileId,
        patient_profile_id: patientProfileId,
      },
    });
    if (count === 0) {
      throw new ForbiddenException(
        'No booking relationship with this patient — patient context is unavailable',
      );
    }
  }

  private async buildTrendSummary(
    patientProfileId: string,
    labProfileId: string,
    fullHistory: boolean,
  ) {
    const twelveMonthsAgo = new Date(Date.now() - 365 * 24 * 60 * 60 * 1000);

    const bookingFilter: Prisma.BookingWhereInput = {
      patient_profile_id: patientProfileId,
      scheduled_at: { gte: twelveMonthsAgo },
      ...(fullHistory ? {} : { lab_profile_id: labProfileId }),
    };

    const ids = (
      await this.prisma.booking.findMany({
        where: bookingFilter,
        select: { id: true },
      })
    ).map((row) => row.id);

    if (ids.length === 0) return [];

    const observations = await this.prisma.resultObservation.findMany({
      where: {
        canonical_marker_id: { not: null },
        value_in_canonical_unit: { not: null },
        is_comparable: true,
        panel: { booking_id: { in: ids } },
      },
      include: {
        canonical_marker: {
          select: { code: true, display_name: true, category: true, default_unit: true },
        },
        panel: {
          select: {
            test_date: true,
            booking: {
              select: {
                id: true,
                lab_profile: { select: { lab_name: true } },
              },
            },
          },
        },
      },
    });

    const byCode = new Map<
      string,
      {
        canonicalCode: string;
        displayName: string;
        chartUnit: string;
        category: string | null;
        points: Array<{
          testDate: string;
          value: number;
          bookingId: string;
          labName: string;
        }>;
      }
    >();

    for (const row of observations) {
      if (!row.canonical_marker || !row.value_in_canonical_unit) continue;
      const code = row.canonical_marker.code;
      if (!byCode.has(code)) {
        byCode.set(code, {
          canonicalCode: code,
          displayName: row.canonical_marker.display_name,
          chartUnit: row.comparable_unit ?? row.canonical_marker.default_unit ?? '',
          category: row.canonical_marker.category ?? null,
          points: [],
        });
      }
      const series = byCode.get(code)!;
      series.points.push({
        testDate: row.panel.test_date.toISOString(),
        value: Number(row.value_in_canonical_unit.toString()),
        bookingId: row.panel.booking.id,
        labName: row.panel.booking.lab_profile.lab_name,
      });
    }

    for (const series of byCode.values()) {
      series.points.sort(
        (a, b) => new Date(a.testDate).getTime() - new Date(b.testDate).getTime(),
      );
      if (series.points.length > MAX_POINTS_PER_MARKER) {
        series.points = series.points.slice(-MAX_POINTS_PER_MARKER);
      }
    }

    return Array.from(byCode.values())
      .sort((a, b) => a.displayName.localeCompare(b.displayName))
      .slice(0, MAX_TREND_MARKERS);
  }
}
