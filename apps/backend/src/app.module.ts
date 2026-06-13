import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import * as Joi from 'joi';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { PrismaService } from './prisma/prisma.service';
import { NotificationsModule } from './notifications/notifications.module';
import { NotificationsService } from './notifications/notifications.service';

import { LabController } from './api/lab.controller';
import { PatientController } from './api/patient.controller';
import { PublicLabsController } from './public/public-labs.controller';
import { PublicTestsController } from './public/public-tests.controller';
import { BookingsController } from './bookings/bookings.controller';
import { BookingsService } from './bookings/bookings.service';
import { PatientService } from './api/patient.service';
import { LabService } from './api/lab.service';
import { LabStorageService } from './api/lab-storage.service';
import { FaqController } from './faq/faq.controller';
import { FaqService } from './faq/faq.service';
import { AuditLogService } from './common/services/audit-log.service';
import { AdminController } from './admin/admin.controller';
import { AdminService } from './admin/admin.service';
import { ClinicalNormalizationService } from './api/clinical-normalization.service';
import { StructuredResultsService } from './api/structured-results.service';
import { LabPatientContextService } from './api/lab-patient-context.service';
import { ResultsDownloadController } from './api/results-download.controller';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: Joi.object({
        NODE_ENV: Joi.string()
          .valid('development', 'production', 'test', 'provision')
          .default('development'),
        PORT: Joi.number().default(3001),
        DATABASE_URL: Joi.string().required(),
        JWT_SECRET: Joi.string().required(),
        LAB_STORAGE_DRIVER: Joi.string().valid('local', 's3').default('local'),
        CORS_ORIGIN: Joi.string().default('http://localhost:3000'),
        FCM_SERVICE_ACCOUNT_JSON: Joi.string().optional(),
      }),
    }),
    AuthModule,
    NotificationsModule,
  ],
  controllers: [
    AppController,
    LabController,
    PatientController,
    PublicLabsController,
    PublicTestsController,
    BookingsController,
    FaqController,
    AdminController,
    ResultsDownloadController,
  ],
  providers: [
    AppService,
    PrismaService,
    NotificationsService,
    BookingsService,
    PatientService,
    LabService,
    { provide: LabStorageService, useFactory: () => new LabStorageService() },
    FaqService,
    AuditLogService,
    AdminService,
    ClinicalNormalizationService,
    StructuredResultsService,
    LabPatientContextService,
  ],
})
export class AppModule {}
