import { IsIn } from 'class-validator';

export class DemoOnlinePaymentDto {
  @IsIn(['success', 'failure'])
  outcome!: 'success' | 'failure';
}
