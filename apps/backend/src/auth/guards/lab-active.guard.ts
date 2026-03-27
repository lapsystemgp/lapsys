import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { LabOnboardingStatus, Role } from '@prisma/client';

@Injectable()
export class LabActiveGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest();
    const user = req.user as
      | { role?: Role; lab_onboarding_status?: LabOnboardingStatus | null }
      | undefined;

    if (user?.role !== Role.LabStaff) {
      return true;
    }

    if (user.lab_onboarding_status !== LabOnboardingStatus.Active) {
      throw new ForbiddenException('Lab account is not active');
    }

    return true;
  }
}
