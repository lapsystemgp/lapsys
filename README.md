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

## 3) Create tables + seed demo data
```bash
npm run db:reset
```

## 4) Run the app (backend + frontend)
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

