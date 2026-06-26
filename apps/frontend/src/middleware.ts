import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { decodeJwt } from 'jose';

function toUnauthorizedReason(labStatus: unknown) {
  if (labStatus === 'Rejected') return 'rejected';
  if (labStatus === 'Suspended') return 'suspended';
  return 'pending_review';
}

function dashboardForRole(role: unknown): string {
  if (role === 'LabStaff') return '/lab/dashboard';
  if (role === 'Admin') return '/admin/dashboard';
  return '/patient/dashboard';
}

export function middleware(request: NextRequest) {
  const token = request.cookies.get('access_token')?.value;

  if (!token) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('reason', 'expired');
    return NextResponse.redirect(loginUrl);
  }

  try {
    const payload = decodeJwt(token);

    const exp = payload.exp;
    if (exp && Math.floor(Date.now() / 1000) > exp) {
      const loginUrl = new URL('/login', request.url);
      loginUrl.searchParams.set('reason', 'expired');
      return NextResponse.redirect(loginUrl);
    }

    const role = payload.role;
    const labStatus = payload.lab_onboarding_status;

    // Lab onboarding gate (before role checks so the message is accurate)
    if (request.nextUrl.pathname.startsWith('/lab') && role === 'LabStaff' && labStatus !== 'Active') {
      return NextResponse.redirect(
        new URL(`/unauthorized?reason=${toUnauthorizedReason(labStatus)}`, request.url),
      );
    }

    // Role mismatch → redirect to the user's own dashboard instead of a dead-end error page
    if (request.nextUrl.pathname.startsWith('/lab') && role !== 'LabStaff') {
      return NextResponse.redirect(new URL(dashboardForRole(role), request.url));
    }

    if (
      (request.nextUrl.pathname.startsWith('/patient') ||
        request.nextUrl.pathname.startsWith('/booking')) &&
      role !== 'Patient'
    ) {
      return NextResponse.redirect(new URL(dashboardForRole(role), request.url));
    }

    if (request.nextUrl.pathname.startsWith('/admin') && role !== 'Admin') {
      return NextResponse.redirect(new URL(dashboardForRole(role), request.url));
    }

    return NextResponse.next();
  } catch {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('reason', 'expired');
    return NextResponse.redirect(loginUrl);
  }
}

export const config = {
  matcher: ['/lab/:path*', '/patient/:path*', '/booking/:path*', '/admin/dashboard/:path*', '/admin/dashboard'],
};
