# Implementation Plan: RBAC Authentication

**Branch**: `002-rbac-auth` | **Date**: 2026-03-14 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-rbac-auth/spec.md`

## Summary

Implement Role-Based Access Control (RBAC) across the Monorepo for `Admin`, `Lab Staff`, and `Patient` roles. This involves NestJS custom decorators/guards for the backend, Next.js middleware for the frontend, and explicitly returning the user's role in the backend login response so client apps (Mobile/Web) can determine access.

## Technical Context

**Language/Version**: TypeScript (Next.js & NestJS)
**Primary Dependencies**: Next.js (App Router), NestJS, TailwindCSS
**Storage**: PostgreSQL (via Prisma or TypeORM)
**Testing**: Jest (Backend), Testing Library (Frontend) 
**Target Platform**: Web (Next.js) & Mobile (Ionic/React Native)
**Project Type**: Fullstack Monorepo
**Performance Goals**: <200ms API Response time
**Constraints**: Follow strict separation of concerns between `apps/frontend` and `apps/backend`
**Scale/Scope**: 3 explicit roles

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **General Architecture**: Monorepo structure respected. Frontend changes only in `apps/frontend`, Backend changes only in `apps/backend`. (Passes)
- **Database**: Using PostgreSQL with an ORM. UUIDs for primary keys. `role` attribute in `Users` table acknowledged. (Passes)
- **Frontend Rules**: Specific to Next.js App Router and TailwindCSS. Middleware fits perfectly in App Router structure. (Passes)
- **Backend Rules**: Proper DTOs and decorators will be used. (Passes)

## Project Structure

### Documentation (this feature)

```text
specs/002-rbac-auth/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
apps/
├── backend/
│   ├── src/
│   │   ├── auth/
│   │   │   ├── decorators/
│   │   │   │   └── roles.decorator.ts
│   │   │   ├── guards/
│   │   │   │   └── roles.guard.ts
│   │   │   └── auth.controller.ts
│   │   └── api/
│   │       ├── admin.controller.ts
│   │       ├── lab.controller.ts
│   │       └── patient.controller.ts
│   └── test/
└── frontend/
    ├── src/
    │   ├── middleware.ts
    │   ├── app/
    │   │   ├── admin/
    │   │   ├── lab/
    │   │   └── unauthorized/
    │   └── components/
    └── tailwind.config.ts
```

**Structure Decision**: Option 4 (Fullstack Monorepo) chosen in alignment with the platform constitution. Next.js App Router for frontend, NestJS for backend.
