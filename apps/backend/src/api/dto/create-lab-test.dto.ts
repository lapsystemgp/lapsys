import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

export class CreateLabTestDto {
  @IsString()
  @MaxLength(150)
  name!: string;

  @IsString()
  @MaxLength(120)
  category!: string;

  @Type(() => Number)
  @IsInt()
  @Min(0)
  priceEgp!: number;

  @IsOptional()
  @IsString()
  @MaxLength(400)
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(300)
  preparation?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  turnaroundTime?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  parametersCount?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
