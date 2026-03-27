import { IsEmail, IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class PatientRegisterDto {
  @ApiProperty({
    example: 'patient@example.com',
    description: 'The email address of the patient',
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

  @ApiProperty({ required: false, example: 'Mazen Amir' })
  @IsOptional()
  @IsString()
  full_name?: string;

  @ApiProperty({ required: false, example: '+20 10 1234 5678' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({ required: false, example: '12 Nile Corniche, Downtown Cairo' })
  @IsOptional()
  @IsString()
  address?: string;
}
