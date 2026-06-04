import {
  Controller,
  ForbiddenException,
  Get,
  NotFoundException,
  Param,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import { createReadStream } from 'node:fs';
import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import type { Response } from 'express';
import { ResultStatus } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';

type RequestWithUser = {
  user?: { id?: string; role?: string };
};

@Controller('results')
export class ResultsDownloadController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('files/:filename')
  @UseGuards(JwtAuthGuard)
  async downloadResultFile(
    @Param('filename') filename: string,
    @Req() req: RequestWithUser,
    @Res() res: Response,
  ) {
    const userId = req.user?.id ?? '';
    const safeName = path.basename(filename);

    const resultFile = await this.prisma.resultFile.findFirst({
      where: { file_url: `/results/files/${safeName}` },
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

    const filePath = path.resolve(process.cwd(), 'uploads', 'results', safeName);

    try {
      await fs.access(filePath);
    } catch {
      throw new NotFoundException('File not found on disk');
    }

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="${resultFile.file_name.replace(/"/g, '')}"`,
    );
    createReadStream(filePath).pipe(res);
  }
}
