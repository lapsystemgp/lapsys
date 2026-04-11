import { Test, TestingModule } from '@nestjs/testing';
import { LabController } from './lab.controller';
import { LabService } from './lab.service';
import { StructuredResultsService } from './structured-results.service';
import { LabPatientContextService } from './lab-patient-context.service';

describe('LabController', () => {
  let controller: LabController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [LabController],
      providers: [
        {
          provide: LabService,
          useValue: {
            getWorkspace: jest.fn(),
            createLabTest: jest.fn(),
            updateLabTest: jest.fn(),
            deleteLabTest: jest.fn(),
            createScheduleSlot: jest.fn(),
            updateScheduleSlot: jest.fn(),
            deactivateScheduleSlot: jest.fn(),
            uploadResult: jest.fn(),
            setResultStatus: jest.fn(),
          },
        },
        {
          provide: StructuredResultsService,
          useValue: {
            upsertStructuredResults: jest.fn(),
          },
        },
        {
          provide: LabPatientContextService,
          useValue: {
            getPatientContext: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<LabController>(LabController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
