import { Controller, Get, NotFoundException, Param, Query } from '@nestjs/common';
import { LabOnboardingStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { clampFloat, clampInt, parseBoolean, parseCsv, placeholderDistanceKm } from './public-utils';

type PublicLabCard = {
  id: string;
  name: string;
  address: string;
  accreditation: string | null;
  turnaroundTime: string | null;
  homeCollection: boolean;
  rating: number | null;
  reviews: number;
  distanceKm: number;
  testsAvailable: number;
  startingFromEgp: number | null;
  priceForQueryEgp: number | null;
  imageEmoji: string;
};

type PublicLabDetail = {
  lab: PublicLabCard;
  tests: Array<{
    id: string;
    name: string;
    category: string;
    priceEgp: number;
    description: string | null;
    preparation: string | null;
    turnaroundTime: string | null;
    parametersCount: number | null;
  }>;
  pagination: { page: number; pageSize: number; totalCount: number };
};

function normalizeContains(input: string) {
  return input.trim();
}

function pickEmoji(stableId: string) {
  const emojis = ['🧪', '🏥', '🔬', '🩺', '🧬', '⚕️'];
  const index = (stableId.charCodeAt(0) + stableId.charCodeAt(stableId.length - 1)) % emojis.length;
  return emojis[index] ?? '🧪';
}

@Controller('public/labs')
export class PublicLabsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async listLabs(@Query() query: Record<string, string | undefined>) {
    const q = (query.q ?? '').trim();
    const labName = (query.labName ?? '').trim();

    const page = clampInt(query.page, { min: 1, max: 500, defaultValue: 1 });
    const pageSize = clampInt(query.pageSize, { min: 1, max: 50, defaultValue: 12 });

    const sort = (query.sort ?? 'price').toLowerCase();
    const minRating = clampFloat(query.minRating, { min: 0, max: 5, defaultValue: 0 });
    const maxDistanceKm = clampFloat(query.maxDistanceKm, { min: 0.5, max: 50, defaultValue: 50 });
    const maxPriceEgp = clampInt(query.maxPriceEgp, { min: 0, max: 100_000, defaultValue: 100_000 });

    const homeCollection = parseBoolean(query.homeCollection);
    const accreditations = parseCsv(query.accreditations).map((a) => a.toLowerCase());

    const baseLabWhere: Prisma.LabProfileWhereInput = {
      onboarding_status: LabOnboardingStatus.Active,
      ...(homeCollection === undefined ? {} : { home_collection: homeCollection }),
      ...(minRating > 0 ? { rating_average: { gte: minRating } } : {}),
      ...(labName.length > 0 ? { lab_name: { contains: normalizeContains(labName), mode: 'insensitive' } } : {}),
      ...(accreditations.length > 0
        ? {
            OR: accreditations.map((token) => ({
              accreditation: { contains: token, mode: 'insensitive' },
            })),
          }
        : {}),
    };

    const baseLabs = await this.prisma.labProfile.findMany({
      where: baseLabWhere,
      select: { id: true, lab_name: true, address: true, accreditation: true, turnaround_time: true, home_collection: true, rating_average: true, review_count: true },
    });

    if (baseLabs.length === 0) {
      return { items: [], pagination: { page, pageSize, totalCount: 0 } };
    }

    const baseLabIds = baseLabs.map((lab) => lab.id);

    const qToken = q.length > 0 ? normalizeContains(q) : '';

    // If q is present, show labs matching either lab name OR test catalog.
    let allowedLabIds = new Set<string>(baseLabIds);
    let minPriceForQueryByLab = new Map<string, number>();

    if (qToken.length > 0) {
      const nameMatchLabIds = new Set(
        baseLabs
          .filter((lab) => lab.lab_name.toLowerCase().includes(qToken.toLowerCase()))
          .map((lab) => lab.id),
      );

      const byTest = await this.prisma.labTest.groupBy({
        by: ['lab_profile_id'],
        where: {
          lab_profile_id: { in: baseLabIds },
          is_active: true,
          OR: [
            { name: { contains: qToken, mode: 'insensitive' } },
            { category: { contains: qToken, mode: 'insensitive' } },
            { description: { contains: qToken, mode: 'insensitive' } },
          ],
        },
        _min: { price_egp: true },
      });

      const testMatchLabIds = new Set(byTest.map((row) => row.lab_profile_id));
      allowedLabIds = new Set([...nameMatchLabIds, ...testMatchLabIds]);

      for (const row of byTest) {
        if (typeof row._min.price_egp === 'number') {
          minPriceForQueryByLab.set(row.lab_profile_id, row._min.price_egp);
        }
      }
    }

    const allowedLabs = baseLabs.filter((lab) => allowedLabIds.has(lab.id));

    if (allowedLabs.length === 0) {
      return { items: [], pagination: { page, pageSize, totalCount: 0 } };
    }

    const startingFromByLab = await this.prisma.labTest.groupBy({
      by: ['lab_profile_id'],
      where: { lab_profile_id: { in: allowedLabs.map((l) => l.id) }, is_active: true },
      _min: { price_egp: true },
      _count: { _all: true },
    });

    const startingMinPrice = new Map<string, { minPrice: number | null; testsCount: number }>();
    for (const row of startingFromByLab) {
      startingMinPrice.set(row.lab_profile_id, {
        minPrice: typeof row._min.price_egp === 'number' ? row._min.price_egp : null,
        testsCount: row._count._all ?? 0,
      });
    }

    const cards: PublicLabCard[] = allowedLabs
      .map((lab) => {
        const distanceKm = placeholderDistanceKm(lab.id);
        const starting = startingMinPrice.get(lab.id);
        const startingFromEgp = starting?.minPrice ?? null;
        const testsAvailable = starting?.testsCount ?? 0;
        const priceForQueryEgp = qToken.length > 0 ? (minPriceForQueryByLab.get(lab.id) ?? null) : null;

        return {
          id: lab.id,
          name: lab.lab_name,
          address: lab.address,
          accreditation: lab.accreditation ?? null,
          turnaroundTime: lab.turnaround_time ?? null,
          homeCollection: lab.home_collection,
          rating: lab.rating_average ?? null,
          reviews: lab.review_count ?? 0,
          distanceKm,
          testsAvailable,
          startingFromEgp,
          priceForQueryEgp,
          imageEmoji: pickEmoji(lab.id),
        };
      })
      .filter((card) => card.distanceKm <= maxDistanceKm)
      .filter((card) => {
        const effectivePrice = qToken.length > 0 ? card.priceForQueryEgp ?? card.startingFromEgp : card.startingFromEgp;
        if (effectivePrice === null) return false;
        return effectivePrice <= maxPriceEgp;
      });

    cards.sort((a, b) => {
      if (sort === 'rating') {
        const ar = a.rating ?? -1;
        const br = b.rating ?? -1;
        return br - ar;
      }
      if (sort === 'distance') {
        return a.distanceKm - b.distanceKm;
      }

      const ap = qToken.length > 0 ? a.priceForQueryEgp ?? a.startingFromEgp : a.startingFromEgp;
      const bp = qToken.length > 0 ? b.priceForQueryEgp ?? b.startingFromEgp : b.startingFromEgp;
      return (ap ?? Number.MAX_SAFE_INTEGER) - (bp ?? Number.MAX_SAFE_INTEGER);
    });

    const totalCount = cards.length;
    const start = (page - 1) * pageSize;
    const items = cards.slice(start, start + pageSize);

    return { items, pagination: { page, pageSize, totalCount } };
  }

  @Get(':labProfileId')
  async getLabDetail(
    @Param('labProfileId') labProfileId: string,
    @Query() query: Record<string, string | undefined>,
  ): Promise<PublicLabDetail> {
    const page = clampInt(query.page, { min: 1, max: 1000, defaultValue: 1 });
    const pageSize = clampInt(query.pageSize, { min: 1, max: 100, defaultValue: 20 });
    const q = (query.q ?? '').trim();
    const category = (query.category ?? '').trim();
    const sort = (query.sort ?? 'price').toLowerCase();

    const lab = await this.prisma.labProfile.findFirst({
      where: { id: labProfileId, onboarding_status: LabOnboardingStatus.Active },
      select: {
        id: true,
        lab_name: true,
        address: true,
        accreditation: true,
        turnaround_time: true,
        home_collection: true,
        rating_average: true,
        review_count: true,
      },
    });

    if (!lab) throw new NotFoundException('Lab not found');

    const testsWhere: Prisma.LabTestWhereInput = {
      lab_profile_id: lab.id,
      is_active: true,
      ...(q.length > 0
        ? {
            OR: [
              { name: { contains: q, mode: 'insensitive' } },
              { category: { contains: q, mode: 'insensitive' } },
              { description: { contains: q, mode: 'insensitive' } },
            ],
          }
        : {}),
      ...(category.length > 0 && category !== 'all' ? { category } : {}),
    };

    const totalCount = await this.prisma.labTest.count({ where: testsWhere });

    const tests = await this.prisma.labTest.findMany({
      where: testsWhere,
      orderBy:
        sort === 'name'
          ? { name: 'asc' }
          : sort === 'price_desc'
            ? { price_egp: 'desc' }
            : { price_egp: 'asc' },
      skip: (page - 1) * pageSize,
      take: pageSize,
      select: {
        id: true,
        name: true,
        category: true,
        price_egp: true,
        description: true,
        preparation: true,
        turnaround_time: true,
        parameters_count: true,
      },
    });

    const card: PublicLabCard = {
      id: lab.id,
      name: lab.lab_name,
      address: lab.address,
      accreditation: lab.accreditation ?? null,
      turnaroundTime: lab.turnaround_time ?? null,
      homeCollection: lab.home_collection,
      rating: lab.rating_average ?? null,
      reviews: lab.review_count ?? 0,
      distanceKm: placeholderDistanceKm(lab.id),
      testsAvailable: totalCount,
      startingFromEgp: null,
      priceForQueryEgp: null,
      imageEmoji: pickEmoji(lab.id),
    };

    return {
      lab: card,
      tests: tests.map((test) => ({
        id: test.id,
        name: test.name,
        category: test.category,
        priceEgp: test.price_egp,
        description: test.description ?? null,
        preparation: test.preparation ?? null,
        turnaroundTime: test.turnaround_time ?? null,
        parametersCount: test.parameters_count ?? null,
      })),
      pagination: { page, pageSize, totalCount },
    };
  }
}

