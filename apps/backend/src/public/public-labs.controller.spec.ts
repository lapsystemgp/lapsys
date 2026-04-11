import { Test, TestingModule } from '@nestjs/testing';
import { PublicLabsController } from './public-labs.controller';
import { PrismaService } from '../prisma/prisma.service';
import { NotFoundException } from '@nestjs/common';
import { LabOnboardingStatus } from '@prisma/client';

describe('PublicLabsController', () => {
  let controller: PublicLabsController;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PublicLabsController],
      providers: [
        {
          provide: PrismaService,
          useValue: {
            labProfile: {
              findMany: jest.fn().mockResolvedValue([]),
              findFirst: jest.fn().mockResolvedValue(null),
            },
            labTest: {
              groupBy: jest.fn().mockResolvedValue([]),
              count: jest.fn().mockResolvedValue(0),
              findMany: jest.fn().mockResolvedValue([]),
            },
          },
        },
      ],
    }).compile();

    controller = module.get<PublicLabsController>(PublicLabsController);
    prisma = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('listLabs should return empty items when no labs found', async () => {
    const result = await controller.listLabs({});
    expect(result.items).toEqual([]);
    expect(result.pagination.totalCount).toBe(0);
  });

  it('listLabs should search via labName', async () => {
    const mockLabs = [{ id: '1', lab_name: 'Test Lab', address: '123 Test St', onboarding_status: LabOnboardingStatus.Active }];
    (prisma.labProfile.findMany as jest.Mock).mockResolvedValue(mockLabs);
    (prisma.labTest.groupBy as jest.Mock).mockResolvedValue([{ lab_profile_id: '1', _min: { price_egp: 100 }, _count: { _all: 5 } }]);
    
    const result = await controller.listLabs({ labName: 'Test' });
    expect(result.items.length).toBe(1);
    expect(result.items[0].name).toBe('Test Lab');
  });

  it('getLabDetail should throw NotFoundException if lab does not exist', async () => {
    await expect(controller.getLabDetail('invalid', {})).rejects.toThrowError(NotFoundException);
  });
});
