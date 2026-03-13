# Research: User Authentication

## Unknowns Resolved

### Decision 1: ORM Selection (Prisma vs TypeORM)
- **Decision**: Prisma
- **Rationale**: Prisma is highly integrated with NestJS, provides excellent TypeScript type safety out of the box, and simplifies database migrations for PostgreSQL. It aligns perfectly with modern fullstack Next.js/NestJS monorepo paradigms.
- **Alternatives considered**: TypeORM (also excellent for NestJS, but Prisma often offers a superior developer experience for rapid schema iteration).

### Decision 2: Password Hashing Strategy
- **Decision**: bcrypt
- **Rationale**: Industry standard for secure password hashing. Has native Node.js libraries (`bcrypt` / `bcryptjs`) that are easy to integrate into NestJS auth workflows.
- **Alternatives considered**: Argon2 (slightly more secure, but bcrypt is completely sufficient and widely understood).

### Decision 3: JWT Storage strategy on Frontend
- **Decision**: HttpOnly Cookies
- **Rationale**: Storing JWTs in HttpOnly cookies prevents Cross-Site Scripting (XSS) attacks from accessing the token. The NestJS backend will set the cookie upon successful login.
- **Alternatives considered**: `localStorage` (vulnerable to XSS).
