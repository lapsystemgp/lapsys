import { Type } from 'class-transformer';
import { IsBoolean, IsDateString, IsInt, IsOptional, Min } from 'class-validator';

export class UpdateScheduleSlotDto {
  @IsOptional()
  @IsDateString()
  startsAt?: string;

  @IsOptional()
  @IsDateString()
  endsAt?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  capacity?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
