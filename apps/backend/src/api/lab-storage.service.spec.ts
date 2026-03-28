import { S3Client } from '@aws-sdk/client-s3';
import { LabStorageService } from './lab-storage.service';

describe('LabStorageService', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.restoreAllMocks();
    process.env = { ...originalEnv };
    delete process.env.LAB_STORAGE_DRIVER;
    delete process.env.LAB_S3_BUCKET;
    delete process.env.LAB_S3_REGION;
    delete process.env.LAB_S3_ENDPOINT;
    delete process.env.LAB_S3_PUBLIC_BASE_URL;
    delete process.env.AWS_ACCESS_KEY_ID;
    delete process.env.AWS_SECRET_ACCESS_KEY;
    delete process.env.AWS_SESSION_TOKEN;
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  it('throws when S3 driver is enabled but required env is missing', () => {
    process.env.LAB_STORAGE_DRIVER = 's3';

    expect(() => new LabStorageService()).toThrow(
      'Missing required S3 storage environment variable: LAB_S3_BUCKET',
    );
  });

  it('uploads via S3 and returns URL using public base URL when provided', async () => {
    process.env.LAB_STORAGE_DRIVER = 's3';
    process.env.LAB_S3_BUCKET = 'test-results';
    process.env.LAB_S3_REGION = 'eu-central-1';
    process.env.LAB_S3_ENDPOINT = 'https://s3.example.com';
    process.env.LAB_S3_PUBLIC_BASE_URL = 'https://cdn.example.com/lab-results';
    process.env.AWS_ACCESS_KEY_ID = 'key';
    process.env.AWS_SECRET_ACCESS_KEY = 'secret';

    const sendSpy = jest.spyOn(S3Client.prototype, 'send').mockResolvedValue({} as never);

    const service = new LabStorageService();
    const stored = await service.saveResultFile({
      originalname: 'cbc report.pdf',
      mimetype: 'application/pdf',
      size: 512,
      buffer: Buffer.from('pdf-content'),
    });

    expect(sendSpy).toHaveBeenCalledTimes(1);
    expect(stored.fileName).toBe('cbc report.pdf');
    expect(stored.fileUrl.startsWith('https://cdn.example.com/lab-results/results/')).toBe(true);
    expect(stored.mimeType).toBe('application/pdf');
    expect(stored.sizeBytes).toBe(512);
  });
});
