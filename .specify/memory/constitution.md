<!-- 
Sync Impact Report:
- Version change: 1.0.0 -> 1.1.0
- Added sections: Architecture & Stack Rules
- Removed sections: Placeholder sections
- Templates requiring updates: plan-template.md, spec-template.md, tasks-template.md (pending)
- Follow-up TODOs: Define core principles if needed beyond the architecture rules.
-->
# my-fullstack-app Constitution

## Core Principles

### TODO(PRINCIPLE_1): Define Principle 1
TODO(DESCRIPTION): Add principle 1 description

## Architecture & Stack Rules

1. **General Architecture (Monorepo):** 
   - The project is a Monorepo. 
   - Frontend code MUST strictly reside in `apps/frontend` (using Next.js). 
   - Backend code MUST strictly reside in `apps/backend` (using NestJS). 
   - Never mix their configurations, dependencies, or codebases.

2. **Database:** 
   - We are using PostgreSQL. 
   - All database interactions in the backend must be handled through an ORM (use Prisma or TypeORM - ask me for confirmation if needed before setting it up).

3. **Frontend Rules (`apps/frontend`):**
   - Strictly use the Next.js App Router (do not use the Pages router).
   - Use TailwindCSS for all styling and UI design.

4. **Backend Rules (`apps/backend`):**
   - Every new API Endpoint MUST have proper DTOs (Data Transfer Objects) and strict input validation.
   - All APIs must be fully documented using Swagger (OpenAPI module in NestJS).

## Governance

Amendments require documentation, approval, and a migration plan. All PRs/reviews must verify compliance.

**Version**: 1.1.0 | **Ratified**: TODO(DATE) | **Last Amended**: 2026-03-13
