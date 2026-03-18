# API Contracts: RBAC Authentication

**Feature**: `002-rbac-auth`

These describe the behavior of the newly authorized endpoints and the modified login endpoint.

## 1. Login Endpoint (Modified)

- **Endpoint**: `POST /auth/login` (or similar existing login route)
- **Request Body**: `{ "email": "...", "password": "..." }`
- **Response Shape**:
  ```json
  {
    "access_token": "eyJhbG...",
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "role": "Patient" // or "Lab Staff" or "Admin"
    }
  }
  ```

## 2. Admin Test Endpoint

- **Endpoint**: `GET /api/admin/data`
- **Headers**: `Authorization: Bearer <jwt>`
- **Expected Behavior**:
  - `200 OK` (If JWT role is `Admin`)
  - `403 Forbidden` (If JWT role is `Patient` or `Lab Staff`)
  - `401 Unauthorized` (If JWT is missing or invalid)

## 3. Lab Test Endpoint

- **Endpoint**: `GET /api/lab/data`
- **Headers**: `Authorization: Bearer <jwt>`
- **Expected Behavior**:
  - `200 OK` (If JWT role is `Lab Staff`)
  - `403 Forbidden` (If JWT role is `Patient` or `Admin`)
  - `401 Unauthorized` (If JWT is missing or invalid)

## 4. Patient Test Endpoint

- **Endpoint**: `GET /api/patient/data`
- **Headers**: `Authorization: Bearer <jwt>`
- **Expected Behavior**:
  - `200 OK` (If JWT role is `Patient`)
  - `403 Forbidden` (If JWT role is `Lab Staff` or `Admin`)
  - `401 Unauthorized` (If JWT is missing or invalid)
