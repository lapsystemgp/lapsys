# How to Run & Validate User Authentication

This document outlines the steps needed to quickly start the application and test the User Authentication feature once implemented.

## Prerequisites
- PostgreSQL running locally (e.g., via Docker). From repo root you can run `npm run db:up`.
- Node.js (v20+) and `pnpm`/`npm` installed.

## Setup Steps

1. **Database Setup**:
   Change into the backend directory and run the Prisma migrations to set up the `User` table.
   ```bash
   cd apps/backend
   npx prisma migrate dev --name init_full_schema
   npx prisma db seed
   ```

2. **Environment Variables**:
   Create a `.env` file in `apps/backend`:
   ```env
   DATABASE_URL="postgresql://postgres:password@localhost:5432/my_db?schema=public"
   JWT_SECRET="your-super-secure-jwt-secret-key"
   ```

3. **Running the Application**:
   Start both the backend and frontend in parallel from the monorepo root:
   ```bash
   npm run dev
   ```
   - **Frontend**: Available at `http://localhost:3000`
   - **Backend**: Available at `http://localhost:3001`
   - **Swagger Docs**: Available at `http://localhost:3001/api`

## Verification

1. **API Validation (Swagger)**:
   Navigate to `http://localhost:3001/api`.
   - Test `POST /auth/register` with valid/invalid inputs.
   - Test `POST /auth/login` and verify a `Set-Cookie` header is returned with the JWT.

2. **Frontend UI**:
   Navigate to `http://localhost:3000/register`.
   - Fill out the dark-themed form and submit to create an account.
   - Navigate to `http://localhost:3000/login`, enter the credentials, and ensure you successfully log in.
