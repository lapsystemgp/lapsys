---

description: "Task list for User Authentication feature"
---

# Tasks: User Authentication (Register & Login)

**Input**: Design documents from `/specs/001-user-auth/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Initialize the monorepo structure with `apps/frontend` and `apps/backend`
- [x] T002 [P] Initialize `apps/frontend` as a Next.js App Router project with TailwindCSS
- [x] T003 [P] Initialize `apps/backend` as a NestJS project
- [x] T004 [P] Setup ESLint/Prettier across the monorepo

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Setup PostgreSQL and initialize Prisma ORM in `apps/backend`
- [x] T006 [P] Configure global ValidationPipe in NestJS
- [x] T007 [P] Configure Swagger Module in NestJS
- [x] T008 [P] Setup JWT Module and `bcrypt` dependencies in `apps/backend`
- [x] T009 [P] Create base `ui` layout components and Tailwind configuration in `apps/frontend`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Secure Account Registration (Priority: P1) 🎯 MVP

**Goal**: A new user lands on the registration page, enters a valid email and strong password, and successfully creates an account to access the application.

**Independent Test**: Can be tested by visiting the `/register` page and submitting valid and invalid data to ensure proper validation and successful account creation.

### Implementation for User Story 1

- [x] T010 [P] [US1] Create `User` Prisma model with `id`, `email`, `password_hash`, and `created_at` fields in `apps/backend/prisma/schema.prisma`
- [x] T011 [US1] Run Prisma migrations to apply the `User` schema
- [x] T012 [P] [US1] Create `RegisterDto` with strict class-validator decorators in `apps/backend/src/auth/`
- [x] T013 [US1] Implement `AuthService.register()` encapsulating password hashing with `bcrypt` in `apps/backend/src/auth/`
- [x] T014 [US1] Implement POST `/auth/register` endpoint in `AuthController` with Swagger documentation
- [x] T015 [P] [US1] Build responsive, dark-themed `/register` page UI in `apps/frontend/src/app/(auth)/register/page.tsx`
- [x] T016 [US1] Connect frontend `/register` form to backend `/auth/register` endpoint handling success and API errors

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - User Login & Session Management (Priority: P1)

**Goal**: An existing user visits the login page, provides their credentials, and is authenticated into the application to start a secure session.

**Independent Test**: Can be tested by visiting the `/login` page with an existing account, verifying proper login behavior, and confirming the session token is securely acquired.

### Implementation for User Story 2

- [x] T017 [P] [US2] Create `LoginDto` with strict validation in `apps/backend/src/auth/`
- [x] T018 [US2] Implement `AuthService.validateUser()` and `AuthService.login()` generating a JWT token
- [x] T019 [US2] Implement POST `/auth/login` endpoint in `AuthController` returning HttpOnly cookie and Swagger docs
- [x] T020 [P] [US2] Build responsive, dark-themed `/login` page UI in `apps/frontend/src/app/(auth)/login/page.tsx`
- [x] T021 [US2] Connect frontend `/login` form to backend `/auth/login` endpoint
- [x] T022 [US2] Ensure a generic "Invalid credentials" error is shown on login failure

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T023 [P] Add unit tests for backend `AuthService`
- [ ] T024 [P] Verify `JwtAuthGuard` properly guards arbitrary protected routes
- [ ] T025 Run quickstart.md validation locally

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User Story 1 & 2 are largely distinct API interactions but share the `User` model dependency defined in Phase 3.
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start simultaneously with US1, but will logically depend on the db schema generated in US1 (T011) to be able to validate DB records.

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Frontend UI generation (T015, T020) runs concurrently with Backend API logic (T013, T018).

---

## Parallel Example: User Story 1

```bash
# Backend and frontend built simultaneously:
Task: "Build responsive, dark-themed `/register` page UI"
Task: "Implement `AuthService.register()` encapsulating password hashing"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
