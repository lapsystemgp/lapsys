# Data Model: User Authentication

This document details the exact entity structures as required by the feature specification.

## Entities

### `User`

Represents a registered individual in the application.

**Fields**:
- `id` (String/UUID, Primary Key, Auto-generated)
- `email` (String, Unique)
- `password_hash` (String)
- `created_at` (DateTime, Default: `now()`)

**Validation Rules**:
- `email`: Must be a valid email format, cannot conflict with existing users (checked at API boundary and DB level constraints).
- `password_hash`: Cannot be null/empty. Derived from a plaintext password that must be at least 8 characters long, containing uppercase, lowercase, numbers, and symbols (validated at API boundary before hashing).

**Relationships**:
*(No relationships defined in this initial authentication phase.)*
