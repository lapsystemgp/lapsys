import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateLabProfileDto {
  @IsOptional()
  @IsBoolean()
  homeTestKit?: boolean;

  @IsOptional()
  @IsBoolean()
  homeCollection?: boolean;
}
