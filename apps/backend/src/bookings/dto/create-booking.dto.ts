import { BookingType } from '@prisma/client';
import { IsEnum, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class CreateBookingDto {
  @IsUUID()
  labId!: string;

  @IsUUID()
  testId!: string;

  @IsUUID()
  slotId!: string;

  @IsEnum(BookingType)
  bookingType!: BookingType;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  homeAddress?: string;
}
