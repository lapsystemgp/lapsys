import { ApiProperty } from '@nestjs/swagger';
import { LabOnboardingStatus } from '@prisma/client';
import { IsEnum } from 'class-validator';

export class SetLabOnboardingStatusDto {
  @ApiProperty({
    enum: LabOnboardingStatus,
    example: LabOnboardingStatus.Active,
  })
  @IsEnum(LabOnboardingStatus)
  status: LabOnboardingStatus;
}
