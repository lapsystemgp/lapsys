# TesTly Backend

NestJS + Prisma + PostgreSQL (Neon) API server.

## Setup

```bash
# from repo root
npm install
cp apps/backend/.env.example apps/backend/.env
# fill in DATABASE_URL and JWT_SECRET in .env
cd apps/backend && npx prisma migrate deploy
```

## Run

```bash
# from repo root — starts backend + frontend together
npm run dev

# backend only (port 3001)
cd apps/backend && npm run start:dev
```

Swagger UI: `http://localhost:3001/api`

## Key modules

| Module | Path | Description |
|---|---|---|
| Auth | `src/auth/` | JWT login, refresh tokens, Firebase auth |
| Public | `src/public/` | Unauthenticated lab/test search endpoints |
| FAQ | `src/faq/` | FAQ search and AI answer |
| Chat | `src/chat/` | Gemini-powered AI health assistant |
| Lab | `src/lab/` | Lab staff: catalog, bookings, schedule |
| Patient | `src/patient/` | Patient: bookings, results, reviews |
| Admin | `src/admin/` | Platform admin: onboarding, overview |

## Search

Fuzzy search is implemented across all public search endpoints using `pg_trgm` (PostgreSQL trigram similarity) and Levenshtein edit distance.

See [`docs/SEARCH.md`](../../docs/SEARCH.md) for full details.

Shared logic lives in [`src/common/utils/search.utils.ts`](src/common/utils/search.utils.ts).

## Database

- Provider: Neon (PostgreSQL)
- ORM: Prisma
- Schema: `prisma/schema.prisma`
- Migrations: `prisma/migrations/`

Run pending migrations:
```bash
npx prisma migrate deploy
```

Open Prisma Studio (visual DB browser):
```bash
npx prisma studio
```

## Environment variables

See [`docs/ENVIRONMENT.md`](../../docs/ENVIRONMENT.md) for the full list.
