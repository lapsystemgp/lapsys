import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { PrismaService } from './prisma/prisma.service';

import { LabController } from './api/lab.controller';
import { PatientController } from './api/patient.controller';
import { PublicLabsController } from './public/public-labs.controller';
import { PublicTestsController } from './public/public-tests.controller';

@Module({
  imports: [AuthModule],
  controllers: [AppController, LabController, PatientController, PublicLabsController, PublicTestsController],
  providers: [AppService, PrismaService],
})
export class AppModule {}
