import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsEmail, IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';

export class LabRegisterDto {
  @ApiProperty({
    example: 'lab@example.com',
    description: 'The email address of the lab account',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    example: 'password123',
    description: 'The password for the user',
  })
  @IsNotEmpty()
  @MinLength(8)
  password: string;

  @ApiProperty({ example: 'Alaf labs', description: 'Lab name (single branch in v1)' })
  @IsNotEmpty()
  @IsString()
  lab_name: string;

  @ApiProperty({ example: '12 Nile Corniche, Downtown Cairo', description: 'Lab location/address' })
  @IsNotEmpty()
  @IsString()
  address: string;

  @ApiProperty({ required: false, example: '+20 11 0000 0000' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({ required: false, example: true })
  @IsOptional()
  @IsBoolean()
  home_collection?: boolean;

  @ApiProperty({ required: false, example: 'NABL, CAP' })
  @IsOptional()
  @IsString()
  accreditation?: string;

  @ApiProperty({ required: false, example: '24 hours' })
  @IsOptional()
  @IsString()
  turnaround_time?: string;
}
