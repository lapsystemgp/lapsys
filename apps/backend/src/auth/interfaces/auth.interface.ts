import { Role } from '@prisma/client';

export interface AuthPayload {
  access_token: string;
  user: {
    id: string;
    role: Role;
  };
}
