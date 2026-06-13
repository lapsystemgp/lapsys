import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { Request } from 'express';
import { PrismaService } from '../../prisma/prisma.service';
import { AUTH_COOKIE_NAME } from '../auth.constants';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private prisma: PrismaService) {
    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) throw new Error('JWT_SECRET environment variable is not set');

    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        // Web: JWT in HTTP-only cookie
        (request: Request) => request?.cookies?.[AUTH_COOKIE_NAME] ?? null,
        // Mobile: JWT as Bearer token in Authorization header
        ExtractJwt.fromAuthHeaderAsBearerToken(),
      ]),
      ignoreExpiration: false,
      secretOrKey: jwtSecret,
    });
  }

  async validate(payload: any) {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: {
        id: true,
        email: true,
        role: true,
        lab_profile: { select: { onboarding_status: true } },
      },
    });

    if (!user) {
      throw new UnauthorizedException();
    }

    return {
      id: user.id,
      email: user.email,
      role: user.role,
      lab_onboarding_status: user.lab_profile?.onboarding_status ?? null,
    };
  }
}
