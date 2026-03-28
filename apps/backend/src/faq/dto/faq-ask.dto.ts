import { IsString, MaxLength } from 'class-validator';

export class FaqAskDto {
  @IsString()
  @MaxLength(300)
  question!: string;
}
