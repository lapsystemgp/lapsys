import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { PrismaService } from './prisma/prisma.service';

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

@Module({
  imports: [AuthModule],
  controllers: [
    AppController,
    LabController,
    PatientController,
    PublicLabsController,
    PublicTestsController,
    BookingsController,
    FaqController,
    AdminController,
  ],
  providers: [
    AppService,
    PrismaService,
    BookingsService,
    PatientService,
    LabService,
    LabStorageService,
    FaqService,
    AuditLogService,
    AdminService,
  ],
})
export class AppModule {}
