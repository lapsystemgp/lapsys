# TesTly Monorepo (Backend + Frontend)

## Prerequisites
- Node.js + npm
- Docker (for Postgres)

## 1) Install dependencies
```bash
npm install
```

## 2) Start Postgres
```bash
npm run db:up
```

## 3) Configure backend environment variables
Prisma needs `DATABASE_URL` to connect to Postgres.

Create `apps/backend/.env` from the example:
```bash
cp apps/backend/.env.example apps/backend/.env
```
On Windows (PowerShell):
```powershell
Copy-Item apps\\backend\\.env.example apps\\backend\\.env
```

## 4) Create tables + seed demo data
```bash
npm run db:reset
```

## 5) Run the app (backend + frontend)
```bash
npm run dev
```

## URLs
- Frontend: `http://localhost:3000`
- Backend: `http://localhost:3001`
- Swagger: `http://localhost:3001/api`

## Demo accounts (password: `password123`)
- Patient: `patient@testly.com`
- Lab (Active): `alaflabs@testly.com`
- Lab (Pending review): `pendinglab@testly.com`

## Stop Postgres
```bash
npm run db:down
```

## (Optional) Frontend API base URL
By default the frontend uses `http://localhost:3001`. To override, create `apps/frontend/.env.local` using `apps/frontend/.env.local.example`.

## Phase 7 Guided Assistant + Production Readiness
- Guided FAQ assistant endpoints:
  - `GET /faq/intents`
  - `GET /faq/search`
  - `POST /faq/ask`
- Chatbot in frontend now calls the FAQ API (curated, non-LLM).
- Standardized backend error response payload is enabled globally.
- Audit logs are emitted for auth and booking/result status operations.

## Useful Commands
```bash
npm run db:seed
npm run db:bootstrap
```

## Docs
- Environment variables: `docs/ENVIRONMENT.md`
- Deployment checklist: `docs/DEPLOYMENT_CHECKLIST.md`
