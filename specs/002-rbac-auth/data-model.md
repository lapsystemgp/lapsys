# Data Model: RBAC Authentication

**Feature**: `002-rbac-auth`

## Entities

### `User` (Updated)

The `Users` table already includes a `role` attribute, but we formally define its expected values for the RBAC system.

**Attributes**:
- `id` (UUID, Primary Key)
- `name` (String)
- `email` (String)
- `password` (String, Hashed)
- `role` (Enum): The user's role in the system.

**Allowed Validation Rules for `role`**:
- `Patient`: Can access mobile app and patient-specific web routes.
- `Lab Staff`: Can access `/lab/*` web routes and `/api/lab/*` backend endpoints.
- `Admin`: Can access `/admin/*` web routes and `/api/admin/*` backend endpoints.

### `AuthPayload` (New/Updated shape for Login Response)

**Attributes**:
- `access_token` (String, JWT): Contains `sub` (userId), `email`, and `role`.
- `user` (Object):
  - `id` (UUID)
  - `role` (Enum: `Patient` | `Lab Staff` | `Admin`)

## State Transitions
- **Login Request** -> Validates Credentials -> Mints JWT matching the `role` found in the database -> Returns `AuthPayload`.
