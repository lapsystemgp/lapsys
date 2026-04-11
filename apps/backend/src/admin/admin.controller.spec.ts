import { Test, TestingModule } from '@nestjs/testing';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Role } from '@prisma/client';
import { LabOnboardingStatus } from '@prisma/client';

describe('AdminController', () => {
  let controller: AdminController;
  let service: AdminService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AdminController],
      providers: [
        {
          provide: AdminService,
          useValue: {
            getWorkspace: jest.fn().mockResolvedValue({ stats: 'stats' }),
            setLabOnboardingStatus: jest.fn().mockResolvedValue({ id: 'lab1', onboardingStatus: LabOnboardingStatus.Active }),
            listRecentPayments: jest.fn().mockResolvedValue([]),
          },
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({ canActivate: () => true })
      .overrideGuard(RolesGuard)
      .useValue({ canActivate: () => true })
      .compile();

    controller = module.get<AdminController>(AdminController);
    service = module.get<AdminService>(AdminService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('getWorkspace should return workspace data', async () => {
    const result = await controller.getWorkspace({ user: { id: 'admin1' } });
    expect(service.getWorkspace).toHaveBeenCalledWith('admin1');
    expect(result).toEqual({ stats: 'stats' });
  });

  it('setLabOnboardingStatus should update and return lab profile', async () => {
    const req = { user: { id: 'admin1' } };
    const dto = { status: LabOnboardingStatus.Active };
    const result = await controller.setLabOnboardingStatus(req, 'lab1', dto);
    expect(service.setLabOnboardingStatus).toHaveBeenCalledWith('admin1', 'lab1', dto);
    expect(result.onboardingStatus).toBe(LabOnboardingStatus.Active);
  });

  it('listRecentPayments should return payments', async () => {
    const result = await controller.listRecentPayments({ user: { id: 'admin1' } });
    expect(service.listRecentPayments).toHaveBeenCalledWith('admin1');
    expect(result).toEqual([]);
  });
});
