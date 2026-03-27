# Quickstart: RBAC Authentication Testing

**Feature**: `002-rbac-auth`

## Prerequisites

1. PostgreSQL Database running locally or via Docker.
2. Backend (NestJS) and Frontend (Next.js) servers up and running.
3. At least one seeded user for each product role:
   - Lab Staff (`role: 'LabStaff'`) with `lab_profile.onboarding_status = 'Active'`
   - Lab Staff pending review (`role: 'LabStaff'`) with `lab_profile.onboarding_status = 'PendingReview'`
   - Patient (`role: 'Patient'`)

## Validating Backend Routes (cURL/Postman)

1. Login as the Patient and store the session cookie:
   ```bash
   curl -i -c patient.txt -X POST http://localhost:3001/auth/login \
     -H 'Content-Type: application/json' \
     -d '{"email":"patient@testly.com","password":"password123"}'
   ```
   *Expected Response:* `Set-Cookie: access_token=...` and `user.role: "Patient"`.

2. Patient should access patient route:
   ```bash
   curl -b patient.txt -X GET http://localhost:3001/api/patient/data
   ```
   *Expected Response:* `200 OK`

3. Patient should NOT access lab route:
   ```bash
   curl -b patient.txt -X GET http://localhost:3001/api/lab/data
   ```
   *Expected Response:* `403 Forbidden`

4. Login as active Lab Staff and store the session cookie:
   ```bash
   curl -i -c lab.txt -X POST http://localhost:3001/auth/login \
     -H 'Content-Type: application/json' \
     -d '{"email":"alaflabs@testly.com","password":"password123"}'
   ```

5. Lab Staff should access lab route:
   ```bash
   curl -b lab.txt -X GET http://localhost:3001/api/lab/data
   ```
   *Expected Response:* `200 OK`

6. Pending-review lab should be blocked:
   ```bash
   curl -i -c pending.txt -X POST http://localhost:3001/auth/login \
     -H 'Content-Type: application/json' \
     -d '{"email":"pendinglab@testly.com","password":"password123"}'
   curl -b pending.txt -X GET http://localhost:3001/api/lab/data
   ```
   *Expected Response:* `403 Forbidden` (pending review)

## Validating Frontend Routes (Browser)

1. Run the frontend `npm run dev` in `apps/frontend`.
2. Login as the Lab Staff.
3. Navigate to `http://localhost:3000/lab/dashboard`.
   *Expected Behavior:* Page loads successfully.
4. Login as the pending-review lab and navigate to `http://localhost:3000/lab/dashboard`.
   *Expected Behavior:* Directed to `/unauthorized` or `/login`.
