import { KitStatus } from '@prisma/client';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateKitStatusDto {
  @IsEnum(KitStatus)
  kitStatus!: KitStatus;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  trackingNumber?: string;
}
