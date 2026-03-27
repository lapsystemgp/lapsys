import { LabOnboardingStatus, Role } from '@prisma/client';

export interface AuthPayload {
  access_token: string;
  user: {
    id: string;
    email: string;
    role: Role;
    lab_onboarding_status?: LabOnboardingStatus | null;
  };
}
