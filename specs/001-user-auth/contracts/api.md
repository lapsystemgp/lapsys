# Authentication API Contracts

## POST `/auth/register`

Creates a new user account.

**Request Body (JSON)**:
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123!"
}
```
**Validation**:
- `email`: Must be valid email.
- `password`: Min 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character.

**Response (201 Created)**:
```json
{
  "id": "uuid-1234",
  "email": "user@example.com",
  "created_at": "2026-03-13T12:00:00Z"
}
```
*(No session cookie is set on register. The user must subsequently login.)*

**Response (400 Bad Request)**:
Returned if DTO validation fails (e.g., weak password) or if the email is already registered.

---

## POST `/auth/login`

Authenticates a user and starts a session.

**Request Body (JSON)**:
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123!"
}
```

**Response (200 OK)**:
```json
{
  "message": "Login successful",
  "user": {
    "id": "uuid-1234",
    "email": "user@example.com"
  }
}
```
**Headers Set**:
`Set-Cookie: Authentication=ey...; HttpOnly; Path=/; Max-Age=3600; SameSite=Strict`

**Response (401 Unauthorized)**:
Returned if the email/password combination is incorrect.
