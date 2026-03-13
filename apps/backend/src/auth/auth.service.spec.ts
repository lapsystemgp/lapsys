import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { ConflictException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  let prisma: PrismaService;
  let jwt: JwtService;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
  };

  const mockJwtService = {
    sign: jest.fn(() => 'test_token'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: JwtService, useValue: mockJwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prisma = module.get<PrismaService>(PrismaService);
    jwt = module.get<JwtService>(JwtService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('register', () => {
    it('should create a new user if email is unique', async () => {
      const dto = { email: 'test@example.com', password: 'password123' };
      mockPrismaService.user.findUnique.mockResolvedValue(null);
      mockPrismaService.user.create.mockResolvedValue({
        id: '1',
        email: dto.email,
        created_at: new Date(),
      });

      const result = await service.register(dto);
      expect(result.email).toEqual(dto.email);
      expect(mockPrismaService.user.create).toHaveBeenCalled();
    });

    it('should throw ConflictException if email exists', async () => {
      const dto = { email: 'exist@example.com', password: 'password123' };
      mockPrismaService.user.findUnique.mockResolvedValue({ email: dto.email });

      await expect(service.register(dto)).rejects.toThrow(ConflictException);
    });
  });

  describe('validateUser', () => {
    it('should return user object if password matches', async () => {
      const dto = { email: 'test@example.com', password: 'password123' };
      const password_hash = await bcrypt.hash(dto.password, 10);
      mockPrismaService.user.findUnique.mockResolvedValue({
        id: '1',
        email: dto.email,
        password_hash,
      });

      const result = await service.validateUser(dto);
      expect(result).not.toBeNull();
      if (result) {
        expect(result.email).toEqual(dto.email);
        // @ts-expect-error - testing that password_hash is indeed omitted
        expect(result.password_hash).toBeUndefined();
      }
    });

    it('should return null if password mismatch', async () => {
      const dto = { email: 'test@example.com', password: 'wrong' };
      const actual_password = 'correct';
      const password_hash = await bcrypt.hash(actual_password, 10);
      mockPrismaService.user.findUnique.mockResolvedValue({
        email: dto.email,
        password_hash,
      });

      const result = await service.validateUser(dto);
      expect(result).toBeNull();
    });
  });

  describe('login', () => {
    it('should return an access token', async () => {
      const user = { id: '1', email: 'test@example.com' };
      const result = await service.login(user);
      expect(result.access_token).toEqual('test_token');
      expect(result.user.email).toEqual(user.email);
    });
  });
});
