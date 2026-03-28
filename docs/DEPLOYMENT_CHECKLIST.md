# Deployment Checklist

## Pre-Deploy
- Verify `.env` and `.env.local` values for target environment.
- Run `npm install` in repo root.
- Run `npm run db:up` and ensure Postgres is reachable.
- Run `npm run db:reset` (or controlled migration flow in production).
- Verify Swagger at `/api` includes `auth`, `public`, `bookings`, `patient`, `lab`, `faq`.

## Validation
- Backend typecheck: `npm --prefix apps/backend run build` or `npx tsc --noEmit`.
- Frontend typecheck/build: `npm --prefix apps/frontend run build`.
- Run backend unit tests for critical workflows (auth, booking, patient, lab, faq).
- Verify guided chatbot responses from `/faq/ask` for common prompts.

## Smoke Flow
- Guest can browse `/labs` and `/labs/[labId]`.
- Patient can register/login, create booking, view result PDF, update profile, submit review.
- Lab can confirm/reject bookings, manage tests/schedule, upload result PDF, mark delivered.

## Operational
- Confirm audit log events are emitted for auth, booking status, result status changes.
- Confirm uploads directory is writable for `LAB_STORAGE_DRIVER=local`.
- Confirm pagination limits enforce bounded responses.

## Rollback
- Keep previous build artifact available.
- Maintain database backup/snapshot before migration steps.
