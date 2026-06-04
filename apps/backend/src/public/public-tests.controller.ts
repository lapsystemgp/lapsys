import { Controller, Get, NotFoundException, Param, Query } from '@nestjs/common';
import { LabOnboardingStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { clampInt } from './public-utils';

@Controller('public/tests')
export class PublicTestsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async listTests(@Query() query: Record<string, string | undefined>) {
    const q = (query.q ?? '').trim();
    const page = clampInt(query.page, { min: 1, max: 500, defaultValue: 1 });
    const pageSize = clampInt(query.pageSize, { min: 1, max: 50, defaultValue: 12 });

    const stopwords = new Set(['test', 'tests']);
    const rawTokens = q.split(/\s+/).filter(Boolean);
    const filteredTokens = rawTokens.filter((t) => !stopwords.has(t.toLowerCase()));
    const tokens = filteredTokens.length > 0 ? filteredTokens : rawTokens;

    const where: Prisma.LabTestWhereInput = {
      is_active: true,
      lab_profile: { onboarding_status: LabOnboardingStatus.Active },
      ...(tokens.length > 0
        ? {
            AND: tokens.map((t) => ({
              OR: [
                { name: { contains: t, mode: 'insensitive' } },
                { category: { contains: t, mode: 'insensitive' } },
                { description: { contains: t, mode: 'insensitive' } },
              ],
            })),
          }
        : {}),
    };

    const grouped = await this.prisma.labTest.groupBy({
      by: ['name', 'category'],
      where,
      _min: { price_egp: true },
      _count: { _all: true },
      orderBy: [{ name: 'asc' }],
    });

    const totalCount = grouped.length;
    const start = (page - 1) * pageSize;
    const items = grouped.slice(start, start + pageSize).map((row) => ({
      name: row.name,
      category: row.category,
      minPriceEgp: row._min.price_egp ?? null,
      labCount: row._count._all ?? 0,
    }));

    return { items, pagination: { page, pageSize, totalCount } };
  }

  @Get('by-name')
  async getTestByName(@Query() query: Record<string, string>) {
    const name = (query.name ?? '').trim();
    const category = (query.category ?? '').trim();

    if (!name) throw new NotFoundException('name param required');
    if (!category) throw new NotFoundException('category param required');

    const tests = await this.prisma.labTest.findMany({
      where: {
        name: { equals: name, mode: 'insensitive' },
        category: { equals: category, mode: 'insensitive' },
        is_active: true,
        lab_profile: { onboarding_status: LabOnboardingStatus.Active },
      },
      select: {
        id: true,
        name: true,
        category: true,
        price_egp: true,
        description: true,
        preparation: true,
        turnaround_time: true,
        parameters_count: true,
        lab_profile: {
          select: {
            id: true,
            lab_name: true,
            address: true,
            rating_average: true,
            review_count: true,
            home_collection: true,
            home_test_kit: true,
            accreditation: true,
            turnaround_time: true,
            latitude: true,
            longitude: true,
          },
        },
      },
      orderBy: { price_egp: 'asc' },
    });

    if (!tests.length) throw new NotFoundException('Test not found');

    const ref = tests[0];
    return {
      name: ref.name,
      category: ref.category,
      description: ref.description ?? null,
      preparation: ref.preparation ?? null,
      turnaroundTime: ref.turnaround_time ?? null,
      parametersCount: ref.parameters_count ?? null,
      labs: tests.map((t) => ({
        labTestId: t.id,
        labId: t.lab_profile.id,
        labName: t.lab_profile.lab_name,
        address: t.lab_profile.address,
        priceEgp: t.price_egp,
        rating: t.lab_profile.rating_average ?? null,
        reviews: t.lab_profile.review_count,
        homeCollection: t.lab_profile.home_collection,
        homeTestKit: t.lab_profile.home_test_kit,
        accreditation: t.lab_profile.accreditation ?? null,
        turnaroundTime: t.lab_profile.turnaround_time ?? null,
        latitude: t.lab_profile.latitude ?? null,
        longitude: t.lab_profile.longitude ?? null,
      })),
    };
  }

  @Get(':labTestId')
  async getTest(@Param('labTestId') labTestId: string) {
    const test = await this.prisma.labTest.findFirst({
      where: { id: labTestId, is_active: true, lab_profile: { onboarding_status: LabOnboardingStatus.Active } },
      select: {
        id: true,
        name: true,
        category: true,
        price_egp: true,
        description: true,
        preparation: true,
        turnaround_time: true,
        parameters_count: true,
        lab_profile: {
          select: { id: true, lab_name: true, address: true, home_collection: true, home_test_kit: true, accreditation: true, turnaround_time: true },
        },
      },
    });

    if (!test) throw new NotFoundException('Test not found');

    return {
      id: test.id,
      name: test.name,
      category: test.category,
      priceEgp: test.price_egp,
      description: test.description ?? null,
      preparation: test.preparation ?? null,
      turnaroundTime: test.turnaround_time ?? null,
      parametersCount: test.parameters_count ?? null,
      lab: {
        id: test.lab_profile.id,
        name: test.lab_profile.lab_name,
        address: test.lab_profile.address,
        homeCollection: test.lab_profile.home_collection,
        homeTestKit: test.lab_profile.home_test_kit,
        accreditation: test.lab_profile.accreditation ?? null,
        turnaroundTime: test.lab_profile.turnaround_time ?? null,
      },
    };
  }
}

