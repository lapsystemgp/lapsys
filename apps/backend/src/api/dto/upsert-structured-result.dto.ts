import { Type } from 'class-transformer';
import {
  IsArray,
  IsDateString,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';

export class StructuredObservationDto {
  @IsString()
  name!: string;

  @IsOptional()
  @IsString()
  canonicalCode?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  value?: number;

  @IsOptional()
  @IsString()
  valueText?: string;

  @IsOptional()
  @IsString()
  unit?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  refLow?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  refHigh?: number;

  @IsOptional()
  @IsString()
  refText?: string;
}

export class StructuredPanelDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsDateString()
  testDate!: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => StructuredObservationDto)
  observations!: StructuredObservationDto[];
}

export class UpsertStructuredResultDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => StructuredPanelDto)
  panels!: StructuredPanelDto[];
}
