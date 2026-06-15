import { IsOptional, IsString, IsUUID, MaxLength, MinLength } from 'class-validator';

export class SendMessageDto {
  /** Omit to start a new conversation; pass an existing id to continue one. */
  @IsOptional()
  @IsUUID()
  conversationId?: string;

  @IsString()
  @MinLength(1)
  @MaxLength(4000)
  text!: string;
}
