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

## Demo Accounts & QA Scenarios (Password: `password123`)

After running `npm run db:reset`, your database will be seeded with comprehensive demo data to test different user journeys. 

### 1. Admin Flow
- **Login**: `admin@testly.com`
- **What to test**:
  - Navigate to `/admin` to view the Admin Workspace overview.
  - Review the pending labs list. You will see `Pending Lab (Demo)` (`pendinglab@testly.com`). You can click to **Approve** or **Reject** the onboarding application.
  - Review recent platform transactions, including cash and online payments.

### 2. Lab Administration Flow
- **Active Lab Login**: `alaflabs@testly.com`
  - Navigate to `/lab` (Dashboard). Experience the schedule view where there is an existing booking assigned to "Mazen Amir".
  - You can manage test catalogs, update pricing, and upload PDF results for upcoming patient visits.
- **Pending Lab Login**: `pendinglab@testly.com`
  - Login to witness the restricted pending-review state.
- **Rejected Lab Login**: `rejectedlab@testly.com`
  - Login to witness the rejected application state (useful for QAing restricted access).

### 3. Patient Flow
- **Login**: `patient@testly.com` (Profile name: Mazen Amir)
- **What to test**:
  - **Search & Book**: Go to `/` and search for "Blood" to filter active labs. Proceed to book a home collection or a clinic visit.
  - **Result History**: Navigate to `/patient` (Patient Dashboard) then click on **My Results**. The system is seeded with a historical structured CBC exam snippet comparing past vs current glucose values.
  - **Payment Handling**: The patient history includes a simulated failed/cancelled booking due to a failed PayMob online payment, which you can observe in the bookings list.

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
