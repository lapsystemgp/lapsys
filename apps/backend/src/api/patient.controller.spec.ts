import { Test, TestingModule } from '@nestjs/testing';
import { PatientController } from './patient.controller';
import { PatientService } from './patient.service';
import { StructuredResultsService } from './structured-results.service';

describe('PatientController', () => {
  let controller: PatientController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PatientController],
      providers: [
        {
          provide: PatientService,
          useValue: {
            getWorkspace: jest.fn(),
            updateProfile: jest.fn(),
            createReview: jest.fn(),
          },
        },
        {
          provide: StructuredResultsService,
          useValue: {
            getHealthProfile: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<PatientController>(PatientController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});