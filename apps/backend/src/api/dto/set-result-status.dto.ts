import { ResultStatus } from '@prisma/client';
import { IsEnum } from 'class-validator';

export class SetResultStatusDto {
  @IsEnum(ResultStatus)
  status!: ResultStatus;
}
