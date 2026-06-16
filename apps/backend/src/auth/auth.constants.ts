export const AUTH_COOKIE_NAME = 'access_token';

import type { CookieOptions } from 'express';

/**
 * Cookie attributes for the auth session cookie.
 *
 * In production the web frontend (e.g. Vercel) and backend (e.g. Railway) live on
 * different sites, so the cookie must be `SameSite=None; Secure` for the browser to
 * accept it and send it on cross-site XHRs. Locally we keep `Lax`/non-secure so the
 * cookie works over plain http://localhost.
 */
export function buildAuthCookieOptions(): CookieOptions {
  const isProduction = process.env.NODE_ENV === 'production';
  return {
    httpOnly: true,
    path: '/',
    sameSite: isProduction ? 'none' : 'lax',
    secure: isProduction,
  };
}
