import { Injectable } from '@nestjs/common';
import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import { randomUUID } from 'node:crypto';
import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3';

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
  private readonly s3Client: S3Client;
  private readonly bucket: string;
  private readonly region: string;
  private readonly endpoint: string | undefined;
  private readonly publicBaseUrl: string | undefined;

  constructor() {
    this.bucket = this.readRequiredEnv('LAB_S3_BUCKET');
    this.region = this.readRequiredEnv('LAB_S3_REGION');
    this.endpoint = process.env.LAB_S3_ENDPOINT?.trim() || undefined;
    this.publicBaseUrl = process.env.LAB_S3_PUBLIC_BASE_URL?.trim() || undefined;

    const accessKeyId = this.readRequiredEnv('AWS_ACCESS_KEY_ID');
    const secretAccessKey = this.readRequiredEnv('AWS_SECRET_ACCESS_KEY');
    const sessionToken = process.env.AWS_SESSION_TOKEN?.trim() || undefined;

    this.s3Client = new S3Client({
      region: this.region,
      endpoint: this.endpoint,
      forcePathStyle: !!this.endpoint,
      credentials: {
        accessKeyId,
        secretAccessKey,
        ...(sessionToken ? { sessionToken } : {}),
      },
    });
  }

  async saveResultFile(file: UploadedLabFile): Promise<StoredLabFile> {
    const ext = path.extname(file.originalname || '').toLowerCase() || '.pdf';
    const safeBaseName = this.sanitizeBaseName(path.basename(file.originalname || 'result', ext));
    const objectKey = `results/${new Date().toISOString().slice(0, 10)}/${Date.now()}-${randomUUID()}-${safeBaseName}${ext}`;

    await this.s3Client.send(
      new PutObjectCommand({
        Bucket: this.bucket,
        Key: objectKey,
        Body: file.buffer,
        ContentType: file.mimetype || 'application/pdf',
      }),
    );

    return {
      fileName: file.originalname || path.basename(objectKey),
      fileUrl: this.resolveFileUrl(objectKey),
      mimeType: file.mimetype || 'application/pdf',
      sizeBytes: file.size,
    };
  }

  private sanitizeBaseName(value: string) {
    const cleaned = value.replace(/[^a-zA-Z0-9-_]/g, '-').replace(/-+/g, '-');
    return cleaned.length > 0 ? cleaned : 'result';
  }

  private resolveFileUrl(objectKey: string) {
    if (this.publicBaseUrl) {
      const normalized = this.publicBaseUrl.replace(/\/+$/, '');
      return `${normalized}/${objectKey}`;
    }

    if (this.endpoint) {
      const normalized = this.endpoint.replace(/\/+$/, '');
      return `${normalized}/${this.bucket}/${objectKey}`;
    }

    return `https://${this.bucket}.s3.${this.region}.amazonaws.com/${objectKey}`;
  }

  private readRequiredEnv(name: string) {
    const value = process.env[name]?.trim();
    if (!value) {
      throw new Error(`Missing required S3 storage environment variable: ${name}`);
    }
    return value;
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
