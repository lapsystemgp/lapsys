import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { decodeJwt } from 'jose';

export function middleware(request: NextRequest) {
  // Use edge computing logic (jose's minimal functions that work in edge runtime)
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
      return NextResponse.redirect(new URL('/unauthorized?reason=pending_review', request.url));
    }

    if (request.nextUrl.pathname.startsWith('/patient') && role !== 'Patient') {
      return NextResponse.redirect(new URL('/unauthorized', request.url));
    }

    return NextResponse.next();
  } catch (error) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}

// Config to specify which paths the middleware should run on.
export const config = {
  matcher: ['/lab/:path*', '/patient/:path*'],
};
