import { IsOptional, IsString, MaxLength } from 'class-validator';

export class UploadResultDto {
  @IsString()
  @MaxLength(1000)
  summary!: string;

  @IsOptional()
  @IsString()
  highlights?: string;
}
