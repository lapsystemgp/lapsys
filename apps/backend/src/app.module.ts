import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { PrismaService } from './prisma/prisma.service';

import { AdminController } from './api/admin.controller';
import { LabController } from './api/lab.controller';
import { PatientController } from './api/patient.controller';

@Module({
  imports: [AuthModule],
  controllers: [AppController, AdminController, LabController, PatientController],
  providers: [AppService, PrismaService],
})
export class AppModule {}
