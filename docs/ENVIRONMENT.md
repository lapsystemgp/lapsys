# Environment Guide

## Backend (`apps/backend/.env`)
- `DATABASE_URL`: Postgres connection string.
- `JWT_SECRET`: signing key for auth cookies/JWT payloads.
- `LAB_STORAGE_DRIVER`: `local` (default) or `s3`.

Example:
```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/testly_db?schema=public"
JWT_SECRET="replace-with-long-random-secret"
LAB_STORAGE_DRIVER="local"
```

## Frontend (`apps/frontend/.env.local`)
- `NEXT_PUBLIC_API_BASE_URL`: backend base URL.

Example:
```env
NEXT_PUBLIC_API_BASE_URL="http://localhost:3001"
```
