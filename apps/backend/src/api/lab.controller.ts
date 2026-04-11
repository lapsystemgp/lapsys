import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '@prisma/client';
import { LabActiveGuard } from '../auth/guards/lab-active.guard';
import { LabService } from './lab.service';
import { CreateLabTestDto } from './dto/create-lab-test.dto';
import { UpdateLabTestDto } from './dto/update-lab-test.dto';
import { CreateScheduleSlotDto } from './dto/create-schedule-slot.dto';
import { UpdateScheduleSlotDto } from './dto/update-schedule-slot.dto';
import { UploadResultDto } from './dto/upload-result.dto';
import { SetResultStatusDto } from './dto/set-result-status.dto';
import { UpsertStructuredResultDto } from './dto/upsert-structured-result.dto';
import { UploadedLabFile } from './lab-storage.service';
import { StructuredResultsService } from './structured-results.service';

type RequestWithUser = {
  user?: { id?: string };
};

@Controller('lab')
@UseGuards(JwtAuthGuard, RolesGuard, LabActiveGuard)
export class LabController {
  constructor(
    private readonly labService: LabService,
    private readonly structuredResultsService: StructuredResultsService,
  ) {}

  @Get('workspace')
  @Roles(Role.LabStaff)
  getWorkspace(@Req() req: RequestWithUser) {
    return this.labService.getWorkspace(req.user?.id ?? '');
  }

  @Post('tests')
  @Roles(Role.LabStaff)
  createTest(@Req() req: RequestWithUser, @Body() dto: CreateLabTestDto) {
    return this.labService.createLabTest(req.user?.id ?? '', dto);
  }

  @Patch('tests/:testId')
  @Roles(Role.LabStaff)
  updateTest(
    @Req() req: RequestWithUser,
    @Param('testId') testId: string,
    @Body() dto: UpdateLabTestDto,
  ) {
    return this.labService.updateLabTest(req.user?.id ?? '', testId, dto);
  }

  @Delete('tests/:testId')
  @Roles(Role.LabStaff)
  deleteTest(@Req() req: RequestWithUser, @Param('testId') testId: string) {
    return this.labService.deleteLabTest(req.user?.id ?? '', testId);
  }

  @Post('schedule')
  @Roles(Role.LabStaff)
  createScheduleSlot(@Req() req: RequestWithUser, @Body() dto: CreateScheduleSlotDto) {
    return this.labService.createScheduleSlot(req.user?.id ?? '', dto);
  }

  @Patch('schedule/:slotId')
  @Roles(Role.LabStaff)
  updateScheduleSlot(
    @Req() req: RequestWithUser,
    @Param('slotId') slotId: string,
    @Body() dto: UpdateScheduleSlotDto,
  ) {
    return this.labService.updateScheduleSlot(req.user?.id ?? '', slotId, dto);
  }

  @Delete('schedule/:slotId')
  @Roles(Role.LabStaff)
  deactivateScheduleSlot(@Req() req: RequestWithUser, @Param('slotId') slotId: string) {
    return this.labService.deactivateScheduleSlot(req.user?.id ?? '', slotId);
  }

  @Post('results/:bookingId/upload')
  @UseInterceptors(FileInterceptor('file'))
  @Roles(Role.LabStaff)
  uploadResult(
    @Req() req: RequestWithUser,
    @Param('bookingId') bookingId: string,
    @UploadedFile() file: UploadedLabFile | undefined,
    @Body() dto: UploadResultDto,
  ) {
    return this.labService.uploadResult(req.user?.id ?? '', bookingId, file, dto);
  }

  @Patch('results/:bookingId/status')
  @Roles(Role.LabStaff)
  setResultStatus(
    @Req() req: RequestWithUser,
    @Param('bookingId') bookingId: string,
    @Body() dto: SetResultStatusDto,
  ) {
    return this.labService.setResultStatus(req.user?.id ?? '', bookingId, dto);
  }

  @Put('results/:bookingId/structured')
  @Roles(Role.LabStaff)
  upsertStructuredResults(
    @Req() req: RequestWithUser,
    @Param('bookingId') bookingId: string,
    @Body() dto: UpsertStructuredResultDto,
  ) {
    return this.structuredResultsService.upsertStructuredResults(req.user?.id ?? '', bookingId, dto);
  }
}
