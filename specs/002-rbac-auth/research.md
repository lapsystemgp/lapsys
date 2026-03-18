# Research Notes: RBAC Authentication

**Feature Branch**: `002-rbac-auth`

## Phase 0: Unknowns & Clarifications

1. **NestJS custom decorators and guards for RBAC**
   - **Decision**: Implement a custom `@Roles(...roles: Role[])` decorator using NestJS `@SetMetadata()`. Implement a `RolesGuard` that implements `CanActivate`, reading the roles from the execution context via `Reflector`, and matching them against `request.user.role` (which comes from the JWT payload).
   - **Rationale**: This is the standard, idiomatic way to implement RBAC in NestJS.
   - **Alternatives considered**: Checking roles manually inside every controller method (discarded due to code duplication and violating DRY principle).

2. **Next.js Middleware routing for Role protection**
   - **Decision**: Use `middleware.ts` in the Next.js root. The middleware will read the JWT from cookies, decode it (without verifying signature if it's purely for routing, or preferably verify if a shared secret is available, but typically the backend is the source of truth, so decoding is sufficient for UI routing), check the `role` claim, and redirect if the user attempts to access an unauthorized path (e.g. `role: 'Patient'` trying to access `/admin/*`).
   - **Rationale**: Middleware runs before a request completes, making it the perfect place to enforce route protections efficiently on the Edge.
   - **Alternatives considered**: Client-side `useEffect` redirects (discarded because it causes a flash of unauthorized content and is less secure).

3. **Backend Authentication Response Payload**
   - **Decision**: The login endpoint (e.g., `/auth/login`) will return `{ access_token: string, user: { id: string, role: string } }`.
   - **Rationale**: This explicitly fulfills the requirement for the Mobile App to determine the role cleanly so it can route the user to the Patient experience or show an error.
   - **Alternatives considered**: Making the mobile app decode the JWT to find the role (discarded because returning it explicitly in the JSON response is cleaner and easier for the mobile client).
