# Quickstart: RBAC Authentication Testing

**Feature**: `002-rbac-auth`

## Prerequisites

1. PostgreSQL Database running locally or via Docker.
2. Backend (NestJS) and Frontend (Next.js) servers up and running.
3. At least one user account seeded into the `Users` table for each role:
   - User Admin (`role: 'Admin'`)
   - User Lab Staff (`role: 'Lab Staff'`)
   - User Patient (`role: 'Patient'`)

## Validating Backend Routes (cURL/Postman)

1. Obtain a token by logging in as the Admin:
   ```bash
   curl -X POST http://localhost:3000/auth/login \
     -H 'Content-Type: application/json' \
     -d '{"email":"admin@example.com","password":"password123"}'
   ```
   *Expected Response:* Contains `access_token` and `user.role: "Admin"`.

2. Test the Admin route with the token:
   ```bash
   curl -X GET http://localhost:3000/api/admin/data \
     -H 'Authorization: Bearer <ADMIN_TOKEN>'
   ```
   *Expected Response:* `200 OK` (Admin data)

3. Test the Lab route with the Admin token:
   ```bash
   curl -X GET http://localhost:3000/api/lab/data \
     -H 'Authorization: Bearer <ADMIN_TOKEN>'
   ```
   *Expected Response:* `403 Forbidden`

## Validating Frontend Routes (Browser)

1. Run the frontend `npm run dev` in `apps/frontend`.
2. Login as the Lab Staff.
3. Navigate to `http://localhost:3001/lab/dashboard`.
   *Expected Behavior:* Page loads successfully.
4. Navigate to `http://localhost:3001/admin/dashboard`.
   *Expected Behavior:* Directed to `/unauthorized` or `/login`.
