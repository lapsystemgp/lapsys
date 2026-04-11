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

export type HealthProfileGroupBy = 'analyte' | 'lab_test';

type TrendDirection = 'increasing' | 'decreasing' | 'stable' | 'insufficient_data';

type HealthPoint = {
  testDate: string;
  value: number;
  comparable: boolean;
  comparabilityNote: string | null;
  bookingId: string;
  labName: string;
  labTestName: string;
  refLow: number | null;
  refHigh: number | null;
  abnormal: boolean | null;
};

type HealthSeries = {
  canonicalCode: string;
  displayName: string;
  chartUnit: string;
  category: string | null;
  labTestName: string | null;
  trend: {
    direction: TrendDirection;
    narrative: string;
    qualitativeNote: string | null;
  };
  points: HealthPoint[];
};

function computeTrend(points: HealthPoint[]): {
  direction: TrendDirection;
  narrative: string;
  qualitativeNote: string | null;
} {
  const sorted = [...points].sort(
    (a, b) => new Date(a.testDate).getTime() - new Date(b.testDate).getTime(),
  );
  if (sorted.length < 2) {
    return {
      direction: 'insufficient_data',
      narrative: 'Not enough measurements in this period to describe a trend.',
      qualitativeNote: null,
    };
  }

  const first = sorted[0].value;
  const last = sorted[sorted.length - 1].value;
  const denom = Math.max(Math.abs(first), 1e-9);
  const rel = (last - first) / denom;
  let direction: Exclude<TrendDirection, 'insufficient_data'>;
  if (Math.abs(rel) < 0.02) {
    direction = 'stable';
  } else if (last > first) {
    direction = 'increasing';
  } else {
    direction = 'decreasing';
  }

  const narrative =
    direction === 'stable'
      ? 'Values are similar at the start and end of this period.'
      : direction === 'increasing'
        ? 'The latest value is higher than earlier in this period.'
        : 'The latest value is lower than earlier in this period.';

  const firstAb = sorted[0].abnormal;
  const lastAb = sorted[sorted.length - 1].abnormal;
  let qualitativeNote: string | null = null;
  if (firstAb === true && lastAb === false) {
    qualitativeNote =
      'The most recent point is within the reference limits copied from the lab report. This is informational only—not medical advice.';
  } else if (firstAb === false && lastAb === true) {
    qualitativeNote =
      'The most recent point is outside the reference limits copied from the lab report. Discuss with your clinician if you have concerns.';
  }

  return { direction, narrative, qualitativeNote };
}

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

  async getHealthProfile(
    userId: string,
    range: HealthProfileRange,
    groupBy: HealthProfileGroupBy = 'analyte',
  ) {
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
            id: true,
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
                lab_test: { select: { name: true } },
              },
            },
          },
        },
      },
      orderBy: [{ panel: { test_date: 'asc' } }, { raw_name: 'asc' }],
    });

    const seriesMap = new Map<string, HealthSeries>();

    for (const row of observations) {
      if (!row.canonical_marker || !row.value_in_canonical_unit) continue;
      const code = row.canonical_marker.code;
      const labTestName = row.panel.booking.lab_test.name;
      const mapKey =
        groupBy === 'lab_test' ? `${labTestName}::${code}` : code;

      const unit = row.comparable_unit ?? row.canonical_marker.default_unit ?? '';
      const refCanon = this.clinicalNormalization.referenceRangeToCanonical(
        row.canonical_marker,
        row.ref_low,
        row.ref_high,
        row.unit,
      );

      const valueNum = Number(row.value_in_canonical_unit.toString());
      let abnormal: boolean | null = null;
      if (refCanon.low !== null || refCanon.high !== null) {
        const below = refCanon.low !== null && valueNum < refCanon.low;
        const above = refCanon.high !== null && valueNum > refCanon.high;
        abnormal = below || above;
      }

      if (!seriesMap.has(mapKey)) {
        seriesMap.set(mapKey, {
          canonicalCode: code,
          displayName: row.canonical_marker.display_name,
          chartUnit: unit,
          category: row.canonical_marker.category ?? null,
          labTestName: groupBy === 'lab_test' ? labTestName : null,
          trend: {
            direction: 'insufficient_data',
            narrative: '',
            qualitativeNote: null,
          },
          points: [],
        });
      }
      const series = seriesMap.get(mapKey)!;
      series.points.push({
        testDate: row.panel.test_date.toISOString(),
        value: valueNum,
        comparable: row.is_comparable,
        comparabilityNote: row.comparability_note ?? null,
        bookingId: row.panel.booking.id,
        labName: row.panel.booking.lab_profile.lab_name,
        labTestName,
        refLow: refCanon.low,
        refHigh: refCanon.high,
        abnormal,
      });
    }

    const seriesList: HealthSeries[] = Array.from(seriesMap.values())
      .map((s) => ({
        ...s,
        trend: computeTrend(s.points),
      }))
      .sort((a, b) => {
        const byTest = (a.labTestName ?? '').localeCompare(b.labTestName ?? '');
        if (byTest !== 0) return byTest;
        return a.displayName.localeCompare(b.displayName);
      });

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

    const disclaimer =
      'Trends and reference bands are based on structured data entered from your reports. They are not a substitute for clinical interpretation.';

    if (groupBy === 'lab_test') {
      const byTest = new Map<string, HealthSeries[]>();
      for (const s of seriesList) {
        const name = s.labTestName ?? 'Other';
        if (!byTest.has(name)) byTest.set(name, []);
        byTest.get(name)!.push(s);
      }
      const labTestGroups = Array.from(byTest.entries())
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([labTestName, series]) => ({ labTestName, series }));

      return {
        range,
        groupBy,
        labTestGroups,
        series: [] as HealthSeries[],
        pdfOnlyBookings: pdfOnlyBookings.map((b) => ({
          bookingId: b.id,
          scheduledAt: b.scheduled_at.toISOString(),
          labName: b.lab_profile.lab_name,
          testName: b.lab_test.name,
        })),
        hasStructuredData: structuredInRange > 0,
        disclaimer,
      };
    }

    return {
      range,
      groupBy,
      series: seriesList,
      labTestGroups: [] as Array<{ labTestName: string; series: HealthSeries[] }>,
      pdfOnlyBookings: pdfOnlyBookings.map((b) => ({
        bookingId: b.id,
        scheduledAt: b.scheduled_at.toISOString(),
        labName: b.lab_profile.lab_name,
        testName: b.lab_test.name,
      })),
      hasStructuredData: structuredInRange > 0,
      disclaimer,
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
