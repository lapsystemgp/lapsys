# Tasks: RBAC Authentication

**Input**: Design documents from `/specs/002-rbac-auth/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/api.md

> Note: The product delivery plan excludes Admin UI/routes for v1; only `Patient` and `LabStaff` role routing is treated as in-scope.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Setup Prisma enums for `Role` if they don't already exist in `apps/backend/prisma/schema.prisma`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 Update `AuthPayload` type/interface to include the `role` attribute in `apps/backend/src/auth/interfaces/auth.interface.ts` (or similar location)
- [x] T003 Update backend login service to inject the `role` into the signed JWT payload in `apps/backend/src/auth/auth.service.ts`
- [x] T004 Build custom NestJS `@Roles()` decorator in `apps/backend/src/auth/decorators/roles.decorator.ts`
- [x] T005 Build NestJS `RolesGuard` to parse JWT and enforce role matching in `apps/backend/src/auth/guards/roles.guard.ts`
- [x] T006 Implement Next.js `middleware.ts` to decode JWT (via jose or similar edge-compatible library) and enforce route protection logic in `apps/frontend/src/middleware.ts`
- [x] T007 Build generic frontend unauthorized/login redirect page in `apps/frontend/src/app/unauthorized/page.tsx`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Admin Access Control (Priority: P1) 🎯 MVP

**Goal**: Admins have exclusive access to administrative endpoints and pages so they can manage the system securely.

**Independent Test**: Only an Admin token can access `/api/admin/data` and `/admin/*` routes.

### Implementation for User Story 1

- [x] T008 [P] [US1] Create dummy Admin protected endpoint in `apps/backend/src/api/admin.controller.ts` using `@Roles(Role.Admin)`
- [x] T009 [P] [US1] Create dummy Admin dashboard frontend page in `apps/frontend/src/app/admin/dashboard/page.tsx`
- [x] T010 [US1] Update `middleware.ts` to explicitly map `/admin/*` paths to the `Admin` role requirement

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Lab Staff Access Control (Priority: P1)

**Goal**: Lab Staff have access to lab-specific endpoints and pages.

**Independent Test**: Only a Lab Staff token can access `/api/lab/data` and `/lab/*` routes.

### Implementation for User Story 2

- [x] T011 [P] [US2] Create dummy Lab protected endpoint in `apps/backend/src/api/lab.controller.ts` using `@Roles(Role.LabStaff)`
- [x] T012 [P] [US2] Create dummy Lab dashboard frontend page in `apps/frontend/src/app/lab/dashboard/page.tsx`
- [x] T013 [US2] Update `middleware.ts` to explicitly map `/lab/*` paths to the `Lab Staff` role requirement

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Patient App Routing (Priority: P2)

**Goal**: Mobile App user is properly routed to the Patient experience upon login based on the returned role.

**Independent Test**: Only a Patient token can access `/api/patient/data`. The mobile app parses the login JSON response explicitly to route users.

### Implementation for User Story 3

- [x] T014 [US3] Create dummy Patient protected endpoint in `apps/backend/src/api/patient.controller.ts` using `@Roles(Role.Patient)`
- [x] T015 [US3] Ensure the login controller explicitly returns `user: { id: ..., role: ... }` alongside the `access_token` in `apps/backend/src/auth/auth.controller.ts`

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T016 Run quickstart.md local validations using cURL and frontend browser checks for each role.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2)
- **User Story 2 (P1)**: Can start after Foundational (Phase 2)
- **User Story 3 (P2)**: Can start after Foundational (Phase 2)

### Parallel Opportunities

- Controllers and Pages (T008, T009, T011, T012) can be built completely in parallel.
- Middleware logic can be fleshed out progressively or all at once by different members.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: User Story 1 (Admin Route Protection)
4. **STOP and VALIDATE**: Test Admin protections independently.

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready.
2. Add Admin Access (US1) → Test independently.
3. Add Lab Staff Access (US2) → Test independently.
4. Add Patient Routes (US3) → Test independently.
