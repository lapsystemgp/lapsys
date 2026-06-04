import { Controller, Get, NotFoundException, Param, Query } from '@nestjs/common';
import { LabOnboardingStatus, Prisma, ReviewStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { clampFloat, clampInt, haversineKm, parseBoolean, parseCsv } from './public-utils';

type PublicLabCard = {
  id: string;
  name: string;
  address: string;
  city: string | null;
  phone: string | null;
  contactEmail: string | null;
  accreditation: string | null;
  turnaroundTime: string | null;
  homeCollection: boolean;
  homeTestKit: boolean;
  rating: number | null;
  reviews: number;
  distanceKm: number | null;
  testsAvailable: number;
  startingFromEgp: number | null;
  priceForQueryEgp: number | null;
  imageEmoji: string | null;
};

type PublicReview = {
  id: string;
  rating: number;
  comment: string | null;
  createdAt: string;
  patientName: string;
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
  reviewItems: PublicReview[];
};

function normalizeContains(input: string) {
  return input.trim();
}

@Controller('public/labs')
export class PublicLabsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async listLabs(@Query() query: Record<string, string | undefined>) {
    const q = (query.q ?? '').trim();
    const labName = (query.labName ?? '').trim();
    const city = (query.city ?? '').trim();

    const page = clampInt(query.page, { min: 1, max: 500, defaultValue: 1 });
    const pageSize = clampInt(query.pageSize, { min: 1, max: 50, defaultValue: 12 });

    const sort = (query.sort ?? 'price').toLowerCase();
    const minRating = clampFloat(query.minRating, { min: 0, max: 5, defaultValue: 0 });
    // Only apply distance filter when explicitly provided; otherwise show all labs
    const maxDistanceKm = query.maxDistanceKm
      ? clampFloat(query.maxDistanceKm, { min: 0.5, max: 500, defaultValue: 500 })
      : Infinity;
    const userLat = clampFloat(query.userLat, { min: -90, max: 90, defaultValue: NaN });
    const userLng = clampFloat(query.userLng, { min: -180, max: 180, defaultValue: NaN });
    const hasUserLocation = Number.isFinite(userLat) && Number.isFinite(userLng);
    const hasPriceFilter = query.maxPriceEgp !== undefined;
    const maxPriceEgp = clampInt(query.maxPriceEgp, { min: 0, max: 100_000, defaultValue: 100_000 });

    const homeCollection = parseBoolean(query.homeCollection);
    const accreditations = parseCsv(query.accreditations).map((a) => a.toLowerCase());

    const baseLabWhere: Prisma.LabProfileWhereInput = {
      onboarding_status: LabOnboardingStatus.Active,
      ...(homeCollection === undefined ? {} : { home_collection: homeCollection }),
      ...(minRating > 0 ? { rating_average: { gte: minRating } } : {}),
      ...(labName.length > 0 ? { lab_name: { contains: normalizeContains(labName), mode: 'insensitive' } } : {}),
      ...(city.length > 0 ? { city: { contains: city, mode: 'insensitive' } } : {}),
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
      select: { id: true, lab_name: true, address: true, city: true, phone: true, accreditation: true, turnaround_time: true, home_collection: true, home_test_kit: true, rating_average: true, review_count: true, latitude: true, longitude: true },
    });

    if (baseLabs.length === 0) {
      return { items: [], pagination: { page, pageSize, totalCount: 0 } };
    }

    const baseLabIds = baseLabs.map((lab) => lab.id);

    const stopwords = new Set(['test', 'tests']);
    const rawTokens = q.split(/\s+/).filter(Boolean);
    const filteredTokens = rawTokens.filter((t) => !stopwords.has(t.toLowerCase()));
    const tokens = filteredTokens.length > 0 ? filteredTokens : rawTokens;

    // If q is present, show labs matching either lab name/address OR test catalog.
    let allowedLabIds = new Set<string>(baseLabIds);
    let minPriceForQueryByLab = new Map<string, number>();

    if (tokens.length > 0) {
      const nameAndAddressMatchLabIds = new Set(
        baseLabs
          .filter((lab) =>
            tokens.every((t) => {
              const lower = t.toLowerCase();
              return lab.lab_name.toLowerCase().includes(lower) || lab.address.toLowerCase().includes(lower);
            }),
          )
          .map((lab) => lab.id),
      );

      const byTest = await this.prisma.labTest.groupBy({
        by: ['lab_profile_id'],
        where: {
          lab_profile_id: { in: baseLabIds },
          is_active: true,
          AND: tokens.map((t) => ({
            OR: [
              { name: { contains: t, mode: 'insensitive' } },
              { category: { contains: t, mode: 'insensitive' } },
              { description: { contains: t, mode: 'insensitive' } },
            ],
          })),
        },
        _min: { price_egp: true },
      });

      const testMatchLabIds = new Set(byTest.map((row) => row.lab_profile_id));
      allowedLabIds = new Set([...nameAndAddressMatchLabIds, ...testMatchLabIds]);

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
        const distanceKm =
          hasUserLocation && lab.latitude != null && lab.longitude != null
            ? haversineKm(userLat, userLng, lab.latitude, lab.longitude)
            : null;
        const starting = startingMinPrice.get(lab.id);
        const startingFromEgp = starting?.minPrice ?? null;
        const testsAvailable = starting?.testsCount ?? 0;
        const priceForQueryEgp = tokens.length > 0 ? (minPriceForQueryByLab.get(lab.id) ?? null) : null;

        return {
          id: lab.id,
          name: lab.lab_name,
          address: lab.address,
          city: lab.city ?? null,
          phone: lab.phone ?? null,
          contactEmail: null,
          accreditation: lab.accreditation ?? null,
          turnaroundTime: lab.turnaround_time ?? null,
          homeCollection: lab.home_collection,
          homeTestKit: lab.home_test_kit,
          rating: lab.rating_average ?? null,
          reviews: lab.review_count ?? 0,
          distanceKm,
          testsAvailable,
          startingFromEgp,
          priceForQueryEgp,
          imageEmoji: null,
        };
      })
      .filter((card) => {
        if (card.distanceKm === null) return maxDistanceKm === Infinity; // exclude un-geocoded labs when an explicit radius was supplied
        return card.distanceKm <= maxDistanceKm;
      })
      .filter((card) => {
        const effectivePrice = tokens.length > 0 ? card.priceForQueryEgp ?? card.startingFromEgp : card.startingFromEgp;
        if (effectivePrice === null) return !hasPriceFilter; // only drop null-price labs when a price filter was actually supplied
        return effectivePrice <= maxPriceEgp;
      });

    cards.sort((a, b) => {
      if (sort === 'rating') {
        const ar = a.rating ?? -1;
        const br = b.rating ?? -1;
        return br - ar;
      }
      if (sort === 'distance') {
        return (a.distanceKm ?? Number.MAX_SAFE_INTEGER) - (b.distanceKm ?? Number.MAX_SAFE_INTEGER);
      }

      const ap = tokens.length > 0 ? a.priceForQueryEgp ?? a.startingFromEgp : a.startingFromEgp;
      const bp = tokens.length > 0 ? b.priceForQueryEgp ?? b.startingFromEgp : b.startingFromEgp;
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
        city: true,
        phone: true,
        accreditation: true,
        turnaround_time: true,
        home_collection: true,
        home_test_kit: true,
        rating_average: true,
        review_count: true,
        user: { select: { email: true } },
      },
    });

    if (!lab) throw new NotFoundException('Lab not found');

    const rawReviews = await this.prisma.review.findMany({
      where: { lab_profile_id: labProfileId, status: ReviewStatus.Published },
      orderBy: { created_at: 'desc' },
      take: 50,
      select: {
        id: true,
        rating: true,
        comment: true,
        created_at: true,
        patient_profile: { select: { full_name: true } },
      },
    });

    const reviewItems: PublicReview[] = rawReviews.map((r) => {
      const fullName = r.patient_profile.full_name?.trim() ?? '';
      const parts = fullName.split(/\s+/).filter(Boolean);
      const patientName =
        parts.length === 0
          ? 'Anonymous'
          : parts.length === 1
            ? parts[0]
            : `${parts[0]} ${parts[1][0]}.`;
      return {
        id: r.id,
        rating: r.rating,
        comment: r.comment ?? null,
        createdAt: r.created_at.toISOString(),
        patientName,
      };
    });

    const detailStopwords = new Set(['test', 'tests']);
    const detailRawTokens = q.split(/\s+/).filter(Boolean);
    const detailFiltered = detailRawTokens.filter((t) => !detailStopwords.has(t.toLowerCase()));
    const detailTokens = detailFiltered.length > 0 ? detailFiltered : detailRawTokens;

    const testsWhere: Prisma.LabTestWhereInput = {
      lab_profile_id: lab.id,
      is_active: true,
      ...(detailTokens.length > 0
        ? {
            AND: detailTokens.map((t) => ({
              OR: [
                { name: { contains: t, mode: 'insensitive' } },
                { category: { contains: t, mode: 'insensitive' } },
                { description: { contains: t, mode: 'insensitive' } },
              ],
            })),
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
      city: lab.city ?? null,
      phone: lab.phone ?? null,
      contactEmail: lab.user?.email ?? null,
      accreditation: lab.accreditation ?? null,
      turnaroundTime: lab.turnaround_time ?? null,
      homeCollection: lab.home_collection,
      homeTestKit: lab.home_test_kit,
      rating: lab.rating_average ?? null,
      reviews: lab.review_count ?? 0,
      distanceKm: null,
      testsAvailable: totalCount,
      startingFromEgp: null,
      priceForQueryEgp: null,
      imageEmoji: null,
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
      reviewItems,
    };
  }
}
