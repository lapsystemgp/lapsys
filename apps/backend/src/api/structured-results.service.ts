import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { BookingStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ClinicalNormalizationService } from './clinical-normalization.service';
import { UpsertStructuredResultDto } from './dto/upsert-structured-result.dto';

export type HealthProfileRange = '3m' | '6m' | '12m' | 'all';

@Injectable()
export class StructuredResultsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clinicalNormalization: ClinicalNormalizationService,
  ) {}

  private rangeToFromDate(range: HealthProfileRange): Date | null {
    if (range === 'all') return null;
    const now = new Date();
    const days = range === '3m' ? 90 : range === '6m' ? 180 : 365;
    return new Date(now.getTime() - days * 24 * 60 * 60 * 1000);
  }

  async upsertStructuredResults(userId: string, bookingId: string, dto: UpsertStructuredResultDto) {
    const labProfileId = await this.getLabProfileId(userId);
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        lab_profile_id: true,
        status: true,
        result_file: { select: { id: true } },
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.lab_profile_id !== labProfileId) {
      throw new ForbiddenException('You can only add structured results for your own lab bookings');
    }
    if (booking.status === BookingStatus.Rejected || booking.status === BookingStatus.Cancelled) {
      throw new BadRequestException('Cannot add structured results for cancelled/rejected booking');
    }
    if (!booking.result_file) {
      throw new BadRequestException('Upload the official PDF result before adding structured data');
    }
    if (!dto.panels?.length) {
      throw new BadRequestException('At least one panel is required');
    }
    for (const panel of dto.panels) {
      if (!panel.observations?.length) {
        throw new BadRequestException('Each panel must include at least one observation');
      }
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.resultPanel.deleteMany({ where: { booking_id: booking.id } });

      let sortOrder = 0;
      for (const panel of dto.panels) {
        const testDate = new Date(panel.testDate);
        if (Number.isNaN(testDate.getTime())) {
          throw new BadRequestException(`Invalid testDate for panel "${panel.name ?? 'unnamed'}"`);
        }

        const createdPanel = await tx.resultPanel.create({
          data: {
            booking_id: booking.id,
            name: panel.name?.trim() || null,
            test_date: testDate,
            sort_order: sortOrder++,
          },
        });

        for (const obs of panel.observations) {
          const rawName = obs.name.trim();
          if (!rawName) {
            throw new BadRequestException('Each observation must include a name');
          }

          const canonical = await this.clinicalNormalization.resolveCanonicalMarker(
            obs.canonicalCode,
            rawName,
          );

          let valueNumeric: Prisma.Decimal | null = null;
          if (obs.value !== undefined && obs.value !== null) {
            valueNumeric = new Prisma.Decimal(obs.value);
          }

          let valueInCanonical: Prisma.Decimal | null = null;
          let comparableUnit: string | null = null;
          let isComparable = true;
          let comparabilityNote: string | null = null;

          if (canonical && valueNumeric !== null) {
            const converted = this.clinicalNormalization.toCanonicalValue(
              canonical,
              Number(valueNumeric.toString()),
              obs.unit,
            );
            valueInCanonical = converted.value;
            comparableUnit = converted.unit;
            isComparable = converted.comparable;
            comparabilityNote = converted.note;
          } else if (canonical && valueNumeric === null && obs.valueText) {
            isComparable = false;
            comparabilityNote = 'Non-numeric value; not shown on numeric trends.';
          } else if (!canonical && valueNumeric !== null) {
            isComparable = false;
            comparabilityNote = 'Unmapped test name; link aliases or provide canonicalCode.';
          }

          await tx.resultObservation.create({
            data: {
              panel_id: createdPanel.id,
              canonical_marker_id: canonical?.id ?? null,
              raw_name: rawName,
              value_numeric: valueNumeric,
              value_text: obs.valueText?.trim() || null,
              unit: obs.unit?.trim() || null,
              ref_low:
                obs.refLow !== undefined && obs.refLow !== null
                  ? new Prisma.Decimal(obs.refLow)
                  : null,
              ref_high:
                obs.refHigh !== undefined && obs.refHigh !== null
                  ? new Prisma.Decimal(obs.refHigh)
                  : null,
              ref_text: obs.refText?.trim() || null,
              value_in_canonical_unit: valueInCanonical,
              comparable_unit: comparableUnit,
              is_comparable: isComparable,
              comparability_note: comparabilityNote,
            },
          });
        }
      }
    });

    const observationCount = await this.prisma.resultObservation.count({
      where: { panel: { booking_id: booking.id } },
    });

    return {
      bookingId: booking.id,
      panelCount: dto.panels.length,
      observationCount,
    };
  }

  async getHealthProfile(userId: string, range: HealthProfileRange) {
    const patientProfile = await this.prisma.patientProfile.findUnique({
      where: { user_id: userId },
      select: { id: true },
    });

    if (!patientProfile) {
      throw new ForbiddenException('Only patients can access health profile');
    }

    const from = this.rangeToFromDate(range);

    const structuredInRange = await this.prisma.resultObservation.count({
      where: {
        panel: {
          booking: { patient_profile_id: patientProfile.id },
          ...(from ? { test_date: { gte: from } } : {}),
        },
      },
    });

    const observations = await this.prisma.resultObservation.findMany({
      where: {
        canonical_marker_id: { not: null },
        value_in_canonical_unit: { not: null },
        is_comparable: true,
        panel: {
          booking: { patient_profile_id: patientProfile.id },
          ...(from ? { test_date: { gte: from } } : {}),
        },
      },
      include: {
        canonical_marker: {
          select: {
            code: true,
            display_name: true,
            category: true,
            default_unit: true,
          },
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
      orderBy: [{ panel: { test_date: 'asc' } }, { raw_name: 'asc' }],
    });

    const seriesMap = new Map<
      string,
      {
        canonicalCode: string;
        displayName: string;
        chartUnit: string;
        category: string | null;
        points: Array<{
          testDate: string;
          value: number;
          comparable: boolean;
          comparabilityNote: string | null;
          bookingId: string;
          labName: string;
        }>;
      }
    >();

    for (const row of observations) {
      if (!row.canonical_marker || !row.value_in_canonical_unit) continue;
      const code = row.canonical_marker.code;
      const unit = row.comparable_unit ?? row.canonical_marker.default_unit ?? '';
      if (!seriesMap.has(code)) {
        seriesMap.set(code, {
          canonicalCode: code,
          displayName: row.canonical_marker.display_name,
          chartUnit: unit,
          category: row.canonical_marker.category ?? null,
          points: [],
        });
      }
      const series = seriesMap.get(code)!;
      series.points.push({
        testDate: row.panel.test_date.toISOString(),
        value: Number(row.value_in_canonical_unit.toString()),
        comparable: row.is_comparable,
        comparabilityNote: row.comparability_note ?? null,
        bookingId: row.panel.booking.id,
        labName: row.panel.booking.lab_profile.lab_name,
      });
    }

    const pdfOnlyBookings = await this.prisma.booking.findMany({
      where: {
        patient_profile_id: patientProfile.id,
        OR: [{ result_file: { isNot: null } }, { result_summary: { isNot: null } }],
        result_panels: { none: {} },
      },
      select: {
        id: true,
        scheduled_at: true,
        lab_profile: { select: { lab_name: true } },
        lab_test: { select: { name: true } },
      },
    });

    return {
      range,
      series: Array.from(seriesMap.values()).sort((a, b) =>
        a.displayName.localeCompare(b.displayName),
      ),
      pdfOnlyBookings: pdfOnlyBookings.map((b) => ({
        bookingId: b.id,
        scheduledAt: b.scheduled_at.toISOString(),
        labName: b.lab_profile.lab_name,
        testName: b.lab_test.name,
      })),
      hasStructuredData: structuredInRange > 0,
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
}
