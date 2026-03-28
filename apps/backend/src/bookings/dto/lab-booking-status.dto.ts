import { BookingStatus } from '@prisma/client';
import { IsEnum } from 'class-validator';

export class LabBookingStatusDto {
  @IsEnum(BookingStatus)
  status!: BookingStatus;
}
