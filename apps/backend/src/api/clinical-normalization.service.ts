import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

export type CanonicalMarkerRow = {
  id: string;
  code: string;
  display_name: string;
  default_unit: string | null;
};

@Injectable()
export class ClinicalNormalizationService {
  constructor(private readonly prisma: PrismaService) {}

  normalizeKey(name: string): string {
    return name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, ' ')
      .trim()
      .replace(/\s+/g, ' ');
  }

  async resolveCanonicalMarker(
    canonicalCode: string | undefined,
    rawName: string,
  ): Promise<CanonicalMarkerRow | null> {
    const trimmedCode = canonicalCode?.trim();
    if (trimmedCode) {
      const byCode = await this.prisma.canonicalMarker.findUnique({
        where: { code: trimmedCode.toUpperCase() },
      });
      if (byCode) return byCode;
    }

    const key = this.normalizeKey(rawName);
    const alias = await this.prisma.markerAlias.findUnique({
      where: { alias_normalized: key },
      include: { canonical_marker: true },
    });
    if (alias) return alias.canonical_marker;

    const markers = await this.prisma.canonicalMarker.findMany({
      select: { id: true, code: true, display_name: true, default_unit: true },
    });
    for (const marker of markers) {
      if (this.normalizeKey(marker.display_name) === key) {
        return marker;
      }
    }

    return null;
  }

  toCanonicalValue(
    marker: CanonicalMarkerRow,
    value: number,
    unit: string | null | undefined,
  ): {
    value: Prisma.Decimal;
    unit: string;
    comparable: boolean;
    note: string | null;
  } {
    const u = (unit ?? '').trim().toLowerCase();
    const code = marker.code;

    if (code === 'GLUCOSE_FASTING' || code === 'GLUCOSE_RANDOM') {
      if (!u || u === 'mg/dl') {
        return { value: new Prisma.Decimal(value), unit: 'mg/dL', comparable: true, note: null };
      }
      if (u === 'mmol/l') {
        return {
          value: new Prisma.Decimal(value).mul(new Prisma.Decimal(18)),
          unit: 'mg/dL',
          comparable: true,
          note: 'Converted from mmol/L to mg/dL.',
        };
      }
      return {
        value: new Prisma.Decimal(value),
        unit: unit ?? '',
        comparable: false,
        note: 'Glucose unit not recognized; values may not be comparable across labs.',
      };
    }

    if (code === 'HBA1C') {
      if (!u || u === '%' || u === 'percent') {
        return { value: new Prisma.Decimal(value), unit: '%', comparable: true, note: null };
      }
      if (u === 'mmol/mol' || u === 'ifcc') {
        const ngsp = (value + 23.5) / 10.93;
        return {
          value: new Prisma.Decimal(Math.round(ngsp * 100) / 100),
          unit: '%',
          comparable: true,
          note: 'Converted from IFCC (mmol/mol) to NGSP (%).',
        };
      }
      return {
        value: new Prisma.Decimal(value),
        unit: unit ?? '',
        comparable: false,
        note: 'HbA1c unit not recognized for cross-lab comparison.',
      };
    }

    if (code === 'TSH') {
      const ok =
        !u ||
        u === 'miu/l' ||
        u === 'µiu/ml' ||
        u === 'uiu/ml' ||
        u === 'mu/l' ||
        u.includes('miu');
      if (ok) {
        return { value: new Prisma.Decimal(value), unit: 'mIU/L', comparable: true, note: null };
      }
      return {
        value: new Prisma.Decimal(value),
        unit: unit ?? '',
        comparable: false,
        note: 'TSH unit not mapped for trending.',
      };
    }

    if (code === 'FT4' || code === 'FT3') {
      const outUnit = marker.default_unit ?? unit ?? '';
      return {
        value: new Prisma.Decimal(value),
        unit: outUnit,
        comparable: true,
        note: null,
      };
    }

    if (code === 'CREATININE') {
      if (!u || u === 'mg/dl') {
        return { value: new Prisma.Decimal(value), unit: 'mg/dL', comparable: true, note: null };
      }
      if (u === 'µmol/l' || u === 'umol/l') {
        return {
          value: new Prisma.Decimal(value).div(new Prisma.Decimal(88.4)),
          unit: 'mg/dL',
          comparable: true,
          note: 'Converted from µmol/L to mg/dL.',
        };
      }
      return {
        value: new Prisma.Decimal(value),
        unit: unit ?? '',
        comparable: false,
        note: 'Creatinine unit not converted.',
      };
    }

    const fallbackUnit = marker.default_unit ?? unit ?? '';
    return {
      value: new Prisma.Decimal(value),
      unit: fallbackUnit,
      comparable: true,
      note: null,
    };
  }

  /** Convert reported reference bounds using the same unit rules as {@link toCanonicalValue}. */
  referenceRangeToCanonical(
    marker: CanonicalMarkerRow,
    refLow: Prisma.Decimal | null,
    refHigh: Prisma.Decimal | null,
    unit: string | null | undefined,
  ): { low: number | null; high: number | null } {
    let low: number | null = null;
    let high: number | null = null;
    if (refLow !== null) {
      low = Number(this.toCanonicalValue(marker, Number(refLow.toString()), unit).value.toString());
    }
    if (refHigh !== null) {
      high = Number(this.toCanonicalValue(marker, Number(refHigh.toString()), unit).value.toString());
    }
    if (low !== null && high !== null && low > high) {
      return { low: high, high: low };
    }
    return { low, high };
  }
}
