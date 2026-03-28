import { Injectable } from '@nestjs/common';
import * as fs from 'node:fs/promises';
import * as path from 'node:path';

export type StoredLabFile = {
  fileName: string;
  fileUrl: string;
  mimeType: string;
  sizeBytes: number;
};

export type UploadedLabFile = {
  originalname: string;
  mimetype: string;
  size: number;
  buffer: Buffer;
};

export interface LabFileStorageAdapter {
  saveResultFile(file: UploadedLabFile): Promise<StoredLabFile>;
}

class LocalDiskLabStorageAdapter implements LabFileStorageAdapter {
  private readonly baseDir = path.resolve(process.cwd(), 'uploads', 'results');

  async saveResultFile(file: UploadedLabFile): Promise<StoredLabFile> {
    const ext = path.extname(file.originalname || '').toLowerCase() || '.pdf';
    const safeName = `${Date.now()}-${Math.random().toString(36).slice(2, 10)}${ext}`;
    await fs.mkdir(this.baseDir, { recursive: true });

    const fullPath = path.join(this.baseDir, safeName);
    await fs.writeFile(fullPath, file.buffer);

    return {
      fileName: file.originalname || safeName,
      fileUrl: `/uploads/results/${safeName}`,
      mimeType: file.mimetype || 'application/pdf',
      sizeBytes: file.size,
    };
  }
}

class S3CompatibleLabStorageAdapter implements LabFileStorageAdapter {
  async saveResultFile(file: UploadedLabFile): Promise<StoredLabFile> {
    // Placeholder adapter for production integration wiring. Local adapter is used by default.
    throw new Error(
      `S3 adapter not configured for file ${file.originalname}. Set LAB_STORAGE_DRIVER=local for development.`,
    );
  }
}

@Injectable()
export class LabStorageService {
  private readonly adapter: LabFileStorageAdapter;

  constructor() {
    this.adapter =
      process.env.LAB_STORAGE_DRIVER === 's3'
        ? new S3CompatibleLabStorageAdapter()
        : new LocalDiskLabStorageAdapter();
  }

  async saveResultFile(file: UploadedLabFile) {
    return await this.adapter.saveResultFile(file);
  }
}
