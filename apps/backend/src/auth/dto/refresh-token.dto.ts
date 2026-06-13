import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RefreshTokenDto {
  @ApiProperty({ description: 'Opaque refresh token issued at login' })
  @IsString()
  @IsNotEmpty()
  refresh_token: string;
}
