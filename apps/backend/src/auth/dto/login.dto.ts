import { IsEmail, IsIn, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({
    example: 'user@example.com',
    description: 'The email address of the user',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    example: 'StrongPassword123!',
    description: 'The password of the user',
  })
  @IsNotEmpty()
  @MinLength(8)
  password: string;

  @ApiProperty({
    example: 'patient',
    description: 'The selected account type used during login',
    enum: ['patient', 'lab', 'admin'],
  })
  @IsIn(['patient', 'lab', 'admin'])
  selectedRole: 'patient' | 'lab' | 'admin';
}
