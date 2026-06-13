import { IsIn, IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDeviceDto {
  @ApiProperty({ description: 'FCM registration token from the mobile app' })
  @IsString()
  @IsNotEmpty()
  fcm_token: string;

  @ApiProperty({ enum: ['ios', 'android'], description: 'Device platform' })
  @IsIn(['ios', 'android'])
  platform: 'ios' | 'android';
}
