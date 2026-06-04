import {
  Controller,
  ForbiddenException,
  Get,
  InternalServerErrorException,
  NotFoundException,
  Param,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import type { Response } from 'express';
import { ResultStatus } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { LabStorageService } from './lab-storage.service';

type RequestWithUser = {
  user?: { id?: string; role?: string };
};

@Controller('results')
export class ResultsDownloadController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly labStorage: LabStorageService,
  ) {}

  @Get('files/:id')
  @UseGuards(JwtAuthGuard)
  async downloadResultFile(
    @Param('id') id: string,
    @Req() req: RequestWithUser,
    @Res() res: Response,
  ) {
    const userId = req.user?.id ?? '';

    const resultFile = await this.prisma.resultFile.findUnique({
      where: { id },
      include: {
        booking: {
          include: {
            patient_profile: { select: { user_id: true } },
            lab_profile: { select: { user_id: true } },
          },
        },
      },
    });

    if (!resultFile) throw new NotFoundException('File not found');

    const isAdmin = req.user?.role === 'Admin';
    const isPatient = resultFile.booking.patient_profile.user_id === userId;
    const isLabStaff = resultFile.booking.lab_profile.user_id === userId;

    if (!isAdmin && !isPatient && !isLabStaff) {
      throw new ForbiddenException('Access denied');
    }

    if (isPatient && !isAdmin && !isLabStaff) {
      const { status } = resultFile;
      if (status !== ResultStatus.Uploaded && status !== ResultStatus.Delivered) {
        throw new ForbiddenException('Result is not yet available');
      }
    }

    let stream: NodeJS.ReadableStream;
    try {
      stream = await this.labStorage.streamFile(resultFile.file_url);
    } catch {
      throw new NotFoundException('File not found in storage');
    }

    res.setHeader('Content-Type', resultFile.mime_type || 'application/pdf');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="${resultFile.file_name.replace(/"/g, '')}"`,
    );

    stream.on('error', () => {
      if (!res.headersSent) {
        throw new InternalServerErrorException('Stream error');
      }
    });

    (stream as NodeJS.ReadableStream & { pipe: (dest: Response) => void }).pipe(res);
  }
}
