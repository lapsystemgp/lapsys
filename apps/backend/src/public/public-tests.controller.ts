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

    const where: Prisma.LabTestWhereInput = {
      is_active: true,
      lab_profile: { onboarding_status: LabOnboardingStatus.Active },
      ...(q.length > 0
        ? {
            OR: [
              { name: { contains: q, mode: 'insensitive' } },
              { category: { contains: q, mode: 'insensitive' } },
              { description: { contains: q, mode: 'insensitive' } },
            ],
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
          select: { id: true, lab_name: true, address: true, home_collection: true, accreditation: true, turnaround_time: true },
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
        accreditation: test.lab_profile.accreditation ?? null,
        turnaroundTime: test.lab_profile.turnaround_time ?? null,
      },
    };
  }
}

