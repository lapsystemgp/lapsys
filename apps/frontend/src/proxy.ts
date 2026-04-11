import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { decodeJwt } from 'jose';

function toUnauthorizedReason(labStatus: unknown) {
  if (labStatus === 'Rejected') return 'rejected';
  if (labStatus === 'Suspended') return 'suspended';
  return 'pending_review';
}

export function proxy(request: NextRequest) {
  const token = request.cookies.get('access_token')?.value;

  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  try {
    const payload = decodeJwt(token);
    const role = payload.role;
    const labStatus = payload.lab_onboarding_status;

    if (request.nextUrl.pathname.startsWith('/lab') && role !== 'LabStaff') {
      return NextResponse.redirect(new URL('/unauthorized', request.url));
    }

    if (request.nextUrl.pathname.startsWith('/lab') && role === 'LabStaff' && labStatus !== 'Active') {
      return NextResponse.redirect(
        new URL(`/unauthorized?reason=${toUnauthorizedReason(labStatus)}`, request.url),
      );
    }

    if (request.nextUrl.pathname.startsWith('/patient') && role !== 'Patient') {
      return NextResponse.redirect(new URL('/unauthorized', request.url));
    }

    if (request.nextUrl.pathname.startsWith('/booking') && role !== 'Patient') {
      return NextResponse.redirect(new URL('/unauthorized', request.url));
    }

    if (request.nextUrl.pathname.startsWith('/admin') && role !== 'Admin') {
      return NextResponse.redirect(new URL('/unauthorized', request.url));
    }

    return NextResponse.next();
  } catch {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}

export const config = {
  matcher: ['/lab/:path*', '/patient/:path*', '/booking/:path*', '/admin/:path*'],
};
