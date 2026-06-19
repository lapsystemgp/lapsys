# TesTly — Infrastructure, Deployment, Security, Testing & Tooling

> Scope of this chapter. This document describes the *non-functional* engineering foundation of the
> TesTly platform: how the codebase is organised (the monorepo), how an engineer runs and builds it
> locally, how the three applications (backend API, web frontend, Flutter mobile app) are deployed to
> the cloud, how environment variables and secrets are managed, what security measures protect users
> and their medical data, and how the project is tested and kept to a quality bar. Every claim below is
> grounded in a real file in the repository; file paths are given relative to the repository root
> (`/Users/efraim/Desktop/my-fullstack-app`).

---

## (a) Repository & Tooling Overview

### The npm-workspaces monorepo

TesTly is a **single Git repository containing three applications**, wired together as an
[npm workspaces](https://docs.npmjs.com/cli/using-npm/workspaces) monorepo. The root `package.json`
declares the workspace membership:

```jsonc
// package.json (root)
{
  "name": "my-fullstack-app",
  "workspaces": ["apps/*"],
  "engines": { "node": "22.x" },
  "type": "commonjs"
}
```

The `apps/*` glob means every sub-directory of `apps/` is an independent npm package that shares one
hoisted `node_modules` at the root. The three members are:

| Workspace | Path | Technology | Role |
|---|---|---|---|
| **backend** | `apps/backend` | NestJS 11 + Prisma 5 + PostgreSQL | REST API, business logic, auth, data |
| **frontend** | `apps/frontend` | Next.js 16 (App Router) + React 19 + Tailwind 4 | Web application (patients, labs, admin) |
| **mobile** | `apps/mobile` | Flutter (Dart ≥ 3.5) | iOS / Android patient + lab app |

> **Why a monorepo?** A graduation project benefits from a single source of truth: one `git clone`
> gives a reviewer the API, the website, and the phone app, all version-locked together. The backend's
> API contract (DTOs, Prisma models) is the shared dependency that the web and mobile clients both
> consume, so keeping them side-by-side prevents the classic "the mobile app was built against last
> month's API" drift. The Flutter app is *not* an npm workspace member (it has its own `pubspec.yaml`
> and Dart toolchain) but lives in the same tree under `apps/mobile` for the same reason.

The `engines` field pins **Node 22.x**. This was added deliberately — commit `1ef4eac`
("build: pin Node 22 for Railway/Nixpacks") forced the cloud build platform to use the same Node
major version the project was developed on, eliminating "works on my machine" build failures.

### Root developer scripts

The root `package.json` exposes a small set of orchestration scripts that delegate into the workspaces
using `npm --prefix`:

```jsonc
"scripts": {
  "db:up":        "docker compose up -d db",
  "db:down":      "docker compose down",
  "db:seed":      "npm --prefix apps/backend run prisma:seed",
  "db:reset":     "npm --prefix apps/backend run prisma:reset && npm --prefix apps/backend run prisma:seed",
  "db:bootstrap": "npm run db:up && npm run db:reset",
  "dev":          "npx concurrently \"npm --prefix apps/backend run start:dev\" \"npm --prefix apps/frontend run dev\""
}
```

`npm run dev` is the everyday entry point: it uses `concurrently` to run the NestJS backend
(`nest start --watch`) and the Next.js dev server in one terminal. The `db:*` family wraps the Docker
Compose database and the Prisma migrate/seed commands so a contributor never has to remember the
underlying tool invocations.

### Code-quality tooling (ESLint + Prettier)

There are **two layers** of lint/format configuration:

- **Root** (`eslint.config.mjs`, `.prettierrc`) — a flat-config ESLint built on
  `@eslint/js` + `typescript-eslint` + `eslint-config-prettier`, with `@typescript-eslint/no-explicit-any`
  set to `warn`. The `.prettierrc` enforces single quotes, trailing commas everywhere, a 100-character
  print width, 2-space indentation, and semicolons. `.eslintignore`/`.prettierignore` exclude
  `node_modules`, `dist`, `build`, `.next`, and `coverage`.
- **Per-app** — the backend has a stricter `apps/backend/eslint.config.mjs` using
  `tseslint.configs.recommendedTypeChecked` (type-aware linting via `projectService`), with
  `no-floating-promises` and `no-unsafe-argument` as warnings. The frontend uses
  `eslint-config-next`. The Flutter app uses `flutter_lints` plus a `prefer_single_quotes` rule
  (`apps/mobile/analysis_options.yaml`).

The backend TypeScript config (`apps/backend/tsconfig.json`) is notably strict for a student project:
`strictNullChecks`, `noImplicitAny`, `noFallthroughCasesInSwitch`, and `forceConsistentCasingInFileNames`
are all enabled, while `experimentalDecorators` + `emitDecoratorMetadata` support NestJS's decorator
style. The target is `ES2023` with CommonJS modules.

---

## (b) Run / Build / Deploy Guide

### Running locally

The canonical local workflow is documented in the root `README.md` and works as follows:

1. **Install** — `npm install` at the root hoists dependencies for all npm workspaces.
2. **Configure backend env** — `cp apps/backend/.env.example apps/backend/.env`, then set `DATABASE_URL`
   and `JWT_SECRET`.
3. **Start the database** — `npm run db:up` brings up a local PostgreSQL container (see below). Note
   that the project can run against *either* the local Docker Postgres *or* a hosted Neon database,
   depending on the `DATABASE_URL`.
4. **Apply schema** — `cd apps/backend && npx prisma migrate deploy` (or `prisma db push` for a fresh
   DB with no migration history).
5. **Seed demo data** — `npm run db:seed` populates the rich demo dataset (1 admin, 21 active labs,
   pending/rejected lab accounts, several patients with historical results) used for QA. All demo
   accounts share the password `password123`.
6. **Run both apps** — `npm run dev`. Defaults: frontend on `http://localhost:3000`, backend on
   `http://localhost:3001`, Swagger UI on `http://localhost:3001/api`.

`npm run db:bootstrap` is a one-shot convenience that starts the DB, resets the schema, and seeds —
useful when a contributor wants a clean, known-good environment.

### The local database (Docker Compose)

`docker-compose.yml` defines a single service:

```yaml
services:
  db:
    image: postgres:16
    container_name: testly_db
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: testly_db
    ports: ["5432:5432"]
    volumes: ["testly_postgres_data:/var/lib/postgresql/data"]
```

PostgreSQL 16 runs in a container with a named volume (`testly_postgres_data`) so data survives
container restarts. The matching local `DATABASE_URL` in `.env.example` is
`postgresql://postgres:postgres@localhost:5432/testly_db?schema=public`.

### Building each app

- **Backend** — `npm run build` runs `nest build` (Nest CLI → SWC/tsc), emitting to `apps/backend/dist`.
  `nest-cli.json` sets `deleteOutDir: true` for clean builds. Production is started with
  `npm run start:prod` → `node dist/main`.
- **Frontend** — `npm run build` runs `next build --webpack`. The `--webpack` flag is significant: it
  forces the classic Webpack bundler (rather than Turbopack), which is what the deploy targets are
  configured to use (`apps/frontend/vercel.json`).
- **Mobile** — standard Flutter: `flutter pub get`, then `flutter run`/`flutter build`. App icons are
  generated with `flutter_launcher_icons` from `assets/icon/app_icon.png`.

### Deployment targets

The platform is set up for a **three-host split deployment**: the backend API, the web frontend, and
the database each live on a different managed service. Two interchangeable backend hosting options are
checked in.

**1. Backend → Railway (primary)** — `railway.json`:

```jsonc
{
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "cd apps/backend && npm install --include=dev && npx prisma generate && npm run build && npx prisma migrate deploy"
  },
  "deploy": {
    "startCommand": "cd apps/backend && NODE_ENV=production npm run start:prod",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

Railway uses Nixpacks to auto-detect and build the Node app. Several hard-won build details are encoded
here: `npm install --include=dev` (commit `4ad76a7`) ensures the NestJS CLI and TypeScript — which are
`devDependencies` — are present at build time; `prisma generate` runs *before* `nest build` so the
generated Prisma client exists when TypeScript compiles (commit `0514c24`); and `prisma migrate deploy`
applies pending migrations on every deploy so the live schema is always up to date. The
`NODE_ENV=production` in the start command (commit `bc8ccb1`) is load-bearing — it activates the
production branch of the security-cookie logic (see section (d)). The restart policy retries a crashed
process up to 10 times.

The live backend URL is `https://testly-backend-production-c28a.up.railway.app`
(referenced in `apps/frontend/vercel.json` and `apps/mobile/lib/core/config`).

**2. Backend → Render (alternative)** — `render.yaml`:

```yaml
services:
  - type: web
    name: testly-backend
    runtime: node
    rootDir: apps/backend
    buildCommand: npm install && npm run build && npx prisma generate && npx prisma migrate deploy
    startCommand: npm run start:prod
    envVars:
      - key: NODE_ENV          {value: production}
      - key: DATABASE_URL      {sync: false}   # set in dashboard, not committed
      - key: JWT_SECRET        {sync: false}
      - key: FCM_SERVICE_ACCOUNT_JSON {sync: false}
      - key: CORS_ORIGIN       {sync: false}
      - key: LAB_STORAGE_DRIVER {value: local}
```

Render's blueprint declares the same build/start flow scoped to `rootDir: apps/backend`. Secrets are
marked `sync: false`, meaning Render will *not* read them from the repo — they must be entered in the
Render dashboard, keeping them out of version control.

**3. Frontend → Vercel** — `apps/frontend/vercel.json`:

```jsonc
{
  "framework": "nextjs",
  "buildCommand": "next build --webpack",
  "installCommand": "npm install",
  "env": {
    "NEXT_PUBLIC_API_BASE_URL": "/api",
    "NEXT_PUBLIC_SHOW_DEMO_CREDENTIALS": "false"
  },
  "rewrites": [
    { "source": "/api/:path*", "destination": "https://testly-backend-production-c28a.up.railway.app/:path*" }
  ]
}
```

The Vercel deployment introduces the **same-origin `/api` rewrite proxy** — one of the most important
infrastructure decisions in the project, explained in full in section (d) because it is fundamentally a
security/cookie fix. In short: the browser talks only to the Vercel domain at `/api/*`, and Vercel
transparently rewrites those requests to the Railway backend, so the auth cookie is a *first-party*
cookie rather than a blocked third-party one.

**4. Mobile → device/store** — the Flutter app reads its API base URL from a compile-time
`--dart-define=API_BASE_URL`, defaulting (in `apps/mobile/lib/core/config`) to the deployed Railway
backend so a release build "just works", while local development overrides it to `http://localhost:3001`
(iOS simulator) or `http://10.0.2.2:3001` (Android emulator).

### CI/CD

There are **no first-party GitHub Actions workflows**. The `.github/` directory contains only a
vendored "modernize / java-upgrade" tooling helper, not a CI pipeline (the workflow YAMLs found
elsewhere in the tree all live under `apps/mobile/build/ios/SourcePackages/checkouts/…`, which are
third-party Firebase/Google SDK checkouts pulled in by the iOS build and excluded from analysis).

Instead, **CI/CD is delegated to the deploy platforms' native Git integrations**: pushing to the
default branch triggers Railway/Render (backend) and Vercel (frontend) to run the build commands
declared in `railway.json` / `render.yaml` / `vercel.json`. Each build runs Prisma migrations
automatically. The development process is visibly PR-driven — recent history shows merged pull requests
(`Merge pull request #3 …`, `#2`, `#1`) for the cookie and proxy fixes. Quality gates (typecheck, unit
tests) are run manually per the `docs/DEPLOYMENT_CHECKLIST.md` rather than enforced by an automated
pipeline.

---

## (c) Environment & Configuration

### Backend configuration and validation

The backend is the only service with substantial configuration. Crucially, it does **not** trust
environment variables blindly — `apps/backend/src/app.module.ts` wires `@nestjs/config`'s `ConfigModule`
with a **Joi validation schema** that runs at boot:

```ts
ConfigModule.forRoot({
  isGlobal: true,
  validationSchema: Joi.object({
    NODE_ENV: Joi.string().valid('development','production','test','provision').default('development'),
    PORT: Joi.number().default(3001),
    DATABASE_URL: Joi.string().required(),
    JWT_SECRET: Joi.string().required(),
    LAB_STORAGE_DRIVER: Joi.string().valid('local','s3').default('local'),
    CORS_ORIGIN: Joi.string().default('http://localhost:3000'),
    FCM_SERVICE_ACCOUNT_JSON: Joi.string().optional(),
    GEMINI_API_KEY: Joi.string().optional(),
  }),
});
```

This is a defensive, fail-fast design: if `DATABASE_URL` or `JWT_SECRET` is missing, the app refuses to
start rather than crashing later with a confusing runtime error. Optional features degrade gracefully —
`FCM_SERVICE_ACCOUNT_JSON` (push) and `GEMINI_API_KEY` (AI assistant) are optional, and the code
explicitly handles their absence (see section (d) for FCM; the chat endpoint returns `503` until the
key is set).

The full backend variable set (`apps/backend/.env.example`, `docs/ENVIRONMENT.md`):

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string (local Docker, or **Neon** pooled URL in prod) |
| `JWT_SECRET` | Signing key for access-token JWTs |
| `LAB_STORAGE_DRIVER` | `local` (disk) or `s3` — selects the file-storage adapter |
| `LAB_S3_BUCKET` / `LAB_S3_REGION` / `LAB_S3_ENDPOINT` / `LAB_S3_PUBLIC_BASE_URL` | S3 target (when driver = `s3`) |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN` | S3 credentials |
| `CORS_ORIGIN` | Comma-separated allow-list of web origins |
| `FCM_SERVICE_ACCOUNT_JSON` | Firebase service-account JSON (single line) for push; blank disables push |
| `GEMINI_API_KEY` | Google Gemini key for the AI Health Assistant; blank disables it |

### The database: Neon Postgres (prod) vs Docker (local)

Production uses **Neon** — a serverless, branchable PostgreSQL platform. The README instructs
developers to use the **pooled** Neon connection string (`?sslmode=require`). The same `DATABASE_URL`
abstraction means local development can point at the Docker Postgres 16 container instead, with no code
changes. Prisma (`apps/backend/prisma/schema.prisma`) is the single source of truth for the schema;
there are **10 committed migrations** under `apps/backend/prisma/migrations/`, from
`20260326120000_init_full_schema` through `20260615120000_add_chat_message_metadata`, with the provider
locked to `postgresql` in `migration_lock.toml`.

### Frontend configuration

The frontend has a tiny but **validated** config surface. `apps/frontend/src/env.mjs` parses
`process.env` with a Zod schema and *throws at build/start* on invalid values:

```ts
NEXT_PUBLIC_API_BASE_URL: z.string()
  .refine(v => v.startsWith('/') || /^https?:\/\//.test(v), { message: '…' })
  .default('http://localhost:3001'),
NEXT_PUBLIC_SHOW_DEMO_CREDENTIALS: z.enum(['true','false']).optional().default('true'),
```

The refinement deliberately accepts *either* an absolute URL (`http://localhost:3001` for local) *or* a
relative path (`/api` for the production same-origin proxy). `next.config.ts` imports this module
(`import "./src/env.mjs"`) purely for its side-effect of validating env at config-load time. The
`NEXT_PUBLIC_SHOW_DEMO_CREDENTIALS` flag is set to `false` in production so the QA demo-account hints do
not appear on the live login screen.

### Secrets management — and a finding worth noting

Secrets are kept out of Git via `.gitignore` (`.env*` is ignored, except `!.env.example` and
`!.env.local.example`), and on the deploy side via `sync: false` in `render.yaml` and the Railway/Vercel
dashboards. The committed `*.env.example` files contain only placeholders.

> **Security finding (for the thesis's "lessons learned" section).** The working file
> `apps/backend/.env` is present in the working tree and contains **real, live secrets** — a Neon
> database password, a complete Firebase service-account private key, and a Google Gemini API key. While
> `.gitignore` should keep it out of commits, having real production credentials sitting in a developer
> tree is a risk: these should be rotated and the file treated as sensitive. (The values are not
> reproduced here.) This is a realistic example of the gap between *intended* secret hygiene — which the
> repo's tooling supports well — and *actual* practice.

---

## (d) Security Measures

TesTly handles medical data, so its security posture is the most safety-critical part of the
infrastructure. The design layers several mechanisms.

### Authentication: JWT access tokens + rotating refresh tokens

Authentication lives in `apps/backend/src/auth/`. The flow (`auth.service.ts`, `auth.controller.ts`):

- **Login** validates the email/password and issues two credentials: a short-lived **access-token JWT**
  (signed with `JWT_SECRET`, `expiresIn: '8h'` per `auth.module.ts`) carrying `{ email, sub, role,
  lab_onboarding_status? }`, and an opaque **refresh token** (30-day TTL).
- The login response also enforces *role selection*: `validateUser` compares the selected role
  (`patient`/`lab`/`admin`) against the stored role and returns a distinct "wrong account type" error
  rather than a generic "invalid credentials", so a lab user who picks "Patient" gets a clear message.
- **Refresh-token rotation** (`refreshAccessToken`) is the strongest single auth feature. Refresh
  tokens are **never stored in plaintext** — `createRefreshToken` generates 64 random bytes
  (`crypto.randomBytes(64)`) and persists only their **SHA-256 hash** (`hashToken`) in the
  `RefreshToken` table. On refresh, the presented token is hashed, looked up, checked for
  `revoked`/expiry, then **the old token is revoked and a brand-new pair is issued** (rotation). This
  limits the blast radius of a leaked refresh token. `revokeAllRefreshTokensForUser` supports
  global logout.

### Password hashing: bcrypt

Passwords are hashed with **bcrypt** (`auth.service.ts`): `bcrypt.genSalt(10)` then `bcrypt.hash(...)`
on registration, and `bcrypt.compare(...)` on login. Plaintext passwords are never stored; the
`password_hash` column is explicitly stripped from any object returned to the client
(`const { password_hash, ...result } = user`). Emails are normalised (trim + lowercase) to prevent
duplicate accounts.

### Token transport: httpOnly cookie (web) + Bearer header (mobile)

A single backend serves two very different clients, and the JWT strategy
(`apps/backend/src/auth/strategies/jwt.strategy.ts`) accepts the token from **two extractors**:

```ts
jwtFromRequest: ExtractJwt.fromExtractors([
  (req) => req?.cookies?.[AUTH_COOKIE_NAME] ?? null,  // Web: httpOnly cookie
  ExtractJwt.fromAuthHeaderAsBearerToken(),           // Mobile: Authorization: Bearer
]),
```

- **Web** uses an **httpOnly cookie** named `access_token`, set on login. Because it is `httpOnly`,
  JavaScript (and therefore an XSS payload) cannot read it.
- **Mobile** uses the token from the JSON response body, stored on-device in the OS secure enclave —
  `flutter_secure_storage` (Keychain on iOS, Keystore on Android), per
  `apps/mobile/lib/core/storage/secure_token_store.dart` — and sent as a `Bearer` header. This is why
  the login response returns *both* a cookie and `access_token`/`refresh_token` in the body.

### The cross-site cookie fix: SameSite=None; Secure

The cookie attributes are centralised in `apps/backend/src/auth/auth.constants.ts` so login and logout
stay in sync:

```ts
export function buildAuthCookieOptions(): CookieOptions {
  const isProduction = process.env.NODE_ENV === 'production';
  return {
    httpOnly: true,
    path: '/',
    sameSite: isProduction ? 'none' : 'lax',
    secure:   isProduction,
  };
}
```

**Why this exists (commit `bc8ccb1`).** In production the web frontend (Vercel) and the backend
(Railway) are on *different sites*. A default `SameSite=Lax` cookie is not sent on cross-site XHRs, so
the browser silently rejected the auth cookie and users were stuck on `/login`. The fix sets
`SameSite=None; Secure` in production (which requires HTTPS — hence `secure: true`) while keeping
`Lax`/non-secure locally so it still works over plain `http://localhost`. This is also exactly why
`railway.json` pins `NODE_ENV=production` in its start command — without it, the production branch never
activates. Logout uses the *same* `buildAuthCookieOptions()` so the browser reliably clears the
cross-site cookie.

### The same-origin /api rewrite proxy

The `SameSite=None` fix made the cookie *acceptable*, but a deeper problem remained: a cookie set by
`railway.app` is a **third-party cookie** on the Vercel domain. Modern browsers' third-party-cookie
protection blocks it, and — critically — the Next.js middleware (which reads the cookie on the *Vercel*
domain) could never see it. Users stayed logged-out.

The solution (commit `8eb39c4`, `apps/frontend/vercel.json`) is a **same-origin reverse-proxy rewrite**:
`NEXT_PUBLIC_API_BASE_URL` is set to the relative path `/api`, and Vercel rewrites `/api/:path*` to
`https://…railway.app/:path*`. From the browser's perspective every API call and the auth cookie are
**first-party** on the Vercel origin. Both the browser *and* the Edge middleware can now read the
cookie. The frontend API client (`apps/frontend/src/lib/api.ts`) sends `credentials: 'include'` on every
`fetch`, so the cookie rides along. This is a textbook example of solving a cross-origin auth problem at
the *infrastructure* layer rather than weakening security in code.

### Authorization: guards and role-based access control

Authorization is enforced server-side with NestJS guards (`apps/backend/src/auth/guards/`):

- **`JwtAuthGuard`** — wraps the Passport JWT strategy; protects any route requiring a logged-in user.
- **`RolesGuard`** + `@Roles(...)` decorator — checks the user's `role` against the roles a handler
  requires (`Patient` / `LabStaff` / `Admin`). E.g. every method in `lab.controller.ts` is decorated
  `@Roles(Role.LabStaff)`.
- **`LabActiveGuard`** — a domain-specific guard: a `LabStaff` user whose `lab_onboarding_status` is not
  `Active` (i.e. still `PendingReview`, `Rejected`, or `Suspended`) is rejected with `403`. This
  enforces the lab-onboarding lifecycle at the API boundary. `lab.controller.ts` stacks all three:
  `@UseGuards(JwtAuthGuard, RolesGuard, LabActiveGuard)`.

On the web, **`apps/frontend/src/middleware.ts`** adds a second, defence-in-depth layer at the edge: it
reads the `access_token` cookie, decodes the JWT with `jose`, checks expiry, and redirects based on
`role`/`lab_onboarding_status` for the protected route groups `/lab`, `/patient`, `/booking`, `/admin`
(see its `matcher`). This stops unauthorised users from even loading a protected page shell. (Note: this
is UX/route protection — the *data* is always protected by the backend guards regardless.)

### Input validation and error hygiene

- A **global `ValidationPipe`** (`apps/backend/src/main.ts`) runs with `whitelist: true`,
  `forbidNonWhitelisted: true`, and `transform: true`. Combined with `class-validator` DTOs, this means
  unknown request fields are **rejected**, not silently ignored, and payloads are coerced to typed DTOs.
- A **global `HttpExceptionFilter`** (`apps/backend/src/common/filters/http-exception.filter.ts`)
  standardises *every* error response to `{ statusCode, message, timestamp, path }`. Unhandled
  (non-HTTP) exceptions are logged with their stack but returned to the client as a generic
  `500 Internal server error`, so internal details never leak to the caller.

### CORS

`apps/backend/src/main.ts` configures CORS from a **comma-separated `CORS_ORIGIN` allow-list** with a
custom origin callback: requests with *no* `Origin` header (native mobile apps) are always allowed;
requests whose origin is on the list are allowed; everything else is rejected with an explicit error.
`credentials: true` permits the cookie. Supporting multiple origins lets the same backend serve the
production web app plus, e.g., a dev tunnel for mobile testing.

### Secure file handling for medical results

Lab result PDFs are the most sensitive artefacts in the system, and they are protected in depth
(`apps/backend/src/api/results-download.controller.ts`, `lab.service.ts`, `lab-storage.service.ts`):

- **Authenticated, ownership-checked downloads.** Result files are *not* served as static assets.
  `GET /results/files/:id` is behind `JwtAuthGuard` and explicitly verifies the caller is the **owning
  patient**, the **issuing lab**, or an **admin** — anyone else gets `403`. A patient additionally can
  only download once the result status is `Uploaded`/`Delivered`. The response sets
  `X-Content-Type-Options: nosniff` and a safe `Content-Disposition` filename.
- **Upload validation.** The upload route uses `FileInterceptor('file', { limits: { fileSize: 10 MB } })`
  (a hard size cap), and `lab.service.ts` validates not just the client-supplied MIME type but the
  file's **magic bytes** — `file.buffer.subarray(0,4).toString('ascii') !== '%PDF'` rejects anything
  that is not a genuine PDF, defeating MIME spoofing.

### Pluggable storage: local disk and S3

`apps/backend/src/api/lab-storage.service.ts` implements a `LabFileStorageAdapter` interface with two
implementations chosen by `LAB_STORAGE_DRIVER`:

- **`LocalDiskLabStorageAdapter`** (default) writes to `uploads/results/` with randomised filenames.
- **`S3CompatibleLabStorageAdapter`** uses `@aws-sdk/client-s3` and supports AWS S3 *and* S3-compatible
  endpoints (via `LAB_S3_ENDPOINT` + path-style addressing), with object keys namespaced by date and a
  UUID. Both adapters expose `saveResultFile`/`streamFile`, so the rest of the app is storage-agnostic
  and files are always streamed back through the authenticated controller — never via a public URL.

### Push notifications (FCM / Firebase Admin)

`apps/backend/src/notifications/notifications.service.ts` initialises the **Firebase Admin SDK** from
`FCM_SERVICE_ACCOUNT_JSON`. The design is fault-tolerant: if the variable is absent or unparseable, the
service logs a warning and **silently no-ops** all pushes — the rest of the app keeps working. Device
tokens are stored per-user in the `DeviceToken` table (upserted on register); `sendToUser` multicasts
to all of a user's devices and **automatically prunes** tokens Firebase reports as unregistered/invalid.
On mobile, FCM is wired via `firebase_messaging` (`apps/mobile/pubspec.yaml`).

### Audit logging

`apps/backend/src/common/services/audit-log.service.ts` provides a structured audit trail: it emits
JSON log lines `{ event, details, timestamp }` for security-relevant actions. The auth controller logs
`auth.register.patient`, `auth.register.lab`, `auth.login`, and `auth.logout`; per the README and
`DEPLOYMENT_CHECKLIST.md`, booking- and result-status changes are audited too. This is a lightweight but
real accountability mechanism appropriate to the project's scale.

### The remediation history (a security-maturity narrative)

`docs/REMEDIATION_PLAN.md` is a candid, deep code-audit document that catalogued earlier security and
correctness problems and prescribed fixes. Reading the *current* code against it shows the issues were
genuinely closed — a strong "before/after" story for the thesis:

| Audit finding (Phase) | Status in current code |
|---|---|
| Result PDFs served publicly via `express.static`, guessable names (CRITICAL) | **Fixed** — authenticated, ownership-checked `ResultsDownloadController`; no static mount in `main.ts` |
| No upload size limit; MIME type trusted (HIGH) | **Fixed** — 10 MB `FileInterceptor` limit + `%PDF` magic-byte check |
| Route-protection middleware never ran (file was `proxy.ts`) | **Fixed** — now a real `middleware.ts` with a matcher |
| 1-hour token, no refresh, silent logout | **Fixed** — 8 h access JWT + 30-day rotating refresh tokens |
| Hardcoded `\|\| 'super_secret'` JWT fallback | **Fixed** — `JWT_SECRET` is required (Joi) and throws if missing |
| Confusing "invalid credentials" for wrong role | **Fixed** — distinct "wrong account type" error |

---

## (e) Testing Strategy & Quality

TesTly applies a **per-layer testing strategy**, with each of the three apps using the idiomatic
framework for its stack.

### Backend — Jest unit + e2e

- **Unit/integration tests** use **Jest** with `ts-jest`, configured inline in
  `apps/backend/package.json` (`testRegex: .*\.spec\.ts$`, `rootDir: src`, `testEnvironment: node`).
  There are **18 `.spec.ts` files** colocated with the source, giving broad coverage of the critical
  surface: `auth.service`/`auth.controller`, `bookings.service`/`controller`, `patient.service`/
  `controller`, `lab.service`/`controller`, `lab-storage.service`, `admin.service`/`controller`,
  `public-labs.controller`, `faq.service`/`controller`, `notifications.service`/`controller`, and
  `prisma.service`. Scripts: `npm test`, `test:watch`, `test:cov` (coverage), `test:debug`.
- **End-to-end tests** use **Jest + Supertest** against a booted Nest application, configured separately
  via `test/jest-e2e.json` (`testRegex: .e2e-spec.ts$`) and run with `npm run test:e2e`. The current
  e2e suite (`test/app.e2e-spec.ts`) bootstraps the full `AppModule` and asserts the root endpoint —
  a smoke test proving the whole DI graph wires up and the HTTP server responds.

The `collectCoverageFrom: ["**/*.(t|j)s"]` configuration outputs coverage to `../coverage`.

### Frontend — Playwright e2e (user journeys)

The web app is tested at the **end-to-end** level with **Playwright**
(`apps/frontend/playwright.config.ts`), structured around the three user roles — there are exactly three
spec files: `tests/patient-journey.spec.ts`, `tests/lab-journey.spec.ts`, and
`tests/admin-journey.spec.ts`. The config is production-aware: it runs Chromium, auto-starts the dev
server (`webServer: npm run dev`, reusing an existing one locally), and under CI sets
`forbidOnly`, `retries: 2`, `workers: 1`, and `trace: 'on-first-retry'` for debuggability. The patient
journey, for example, exercises guest search → login → viewing seeded results
(`tests/patient-journey.spec.ts`), validating that the app works against the seeded demo data. Run with
`npm run test:e2e`.

### Mobile — flutter test (the deepest suite)

The Flutter app has the **most extensive automated test suite** in the project: roughly **20 Dart test
files** under `apps/mobile/test/`, organised to mirror the feature-first `lib/` architecture. Coverage
spans the networking layer (`core/network/api_exception_test.dart`), secure token storage
(`core/storage/secure_token_store_test.dart`), notifications (service + repository), and — most
thoroughly — the patient feature set: auth (models, repository, `session_notifier`, login screen),
labs, booking (flow notifier, repository, models), workspace, and health-profile trends. Tests use
`flutter_test` with **`mocktail`** for mocking. Run with `flutter test`. The static-analysis bar is set
by `flutter_lints` plus a `prefer_single_quotes` rule (`analysis_options.yaml`), with generated
`*.g.dart`/`*.freezed.dart` files excluded.

### Quality process & the deployment checklist

Quality is governed by `docs/DEPLOYMENT_CHECKLIST.md`, which prescribes a manual gate before each
release: verify env values, run `npm install`, bring up the DB, run migrations/seed, **typecheck both
apps** (`npm --prefix apps/backend run build` / `npx tsc --noEmit`, and
`npm --prefix apps/frontend run build`), run the backend unit tests for the critical workflows, then
walk a **smoke flow** for each role (guest browse, patient register→book→view PDF→review,
lab confirm→upload→deliver). Operational checks confirm audit events are emitted, the uploads directory
is writable (local driver), and pagination limits bound responses. A rollback plan (keep the previous
build artefact, snapshot the DB before migrations) closes the loop.

### Quality assessment

The testing strategy is **layer-appropriate and reasonably mature for a graduation project**: the
backend has dense unit coverage of services and controllers plus an e2e smoke harness; the web app is
covered by role-based Playwright journeys; and the mobile app — built last and most carefully — has the
broadest unit coverage of all three. The honest gap, worth stating in the thesis, is the **absence of an
automated CI pipeline**: tests exist and are runnable, but nothing forces them to pass before a deploy —
the `DEPLOYMENT_CHECKLIST.md` is a human process, not a machine gate. Wiring these existing suites into a
GitHub Actions workflow would be the single highest-leverage next step for engineering rigour.

---

## Summary

TesTly is structured as an **npm-workspaces monorepo** (`apps/backend` NestJS, `apps/frontend` Next.js,
`apps/mobile` Flutter) pinned to Node 22, with a Docker-Compose Postgres for local development and
**Neon Postgres** in production. It deploys as a **three-host split** — backend on **Railway** (with a
**Render** blueprint as an alternative), frontend on **Vercel**, database on Neon — with all build,
migration, and start logic declared in `railway.json` / `render.yaml` / `vercel.json`; there is no
GitHub Actions CI, deployment being driven by each platform's native Git integration. Security is
layered and genuinely thought-through: **bcrypt** password hashing, **8-hour access JWTs** plus
**SHA-256-hashed, 30-day rotating refresh tokens**, an **httpOnly cookie for web / secure-storage Bearer
token for mobile**, the **`SameSite=None; Secure` + same-origin `/api` rewrite** combination that makes
cross-site auth work, NestJS **role/lab-active guards** with edge-middleware route protection, a global
validation pipe and standardised error filter, **ownership-checked authenticated PDF downloads** with
magic-byte upload validation, pluggable **local/S3** storage, fault-tolerant **FCM push**, and
**structured audit logging**. Configuration is **fail-fast validated** (Joi on the backend, Zod on the
frontend) and secrets are kept out of Git — though a live `.env` with real credentials in the working
tree is a real-world hygiene lesson. Testing is per-layer and substantial — **Jest unit + Supertest e2e**
on the backend (18 spec files), **Playwright** role journeys on the web, and the most extensive suite of
all, **~20 `flutter test` files**, on mobile — governed by a manual deployment checklist whose main gap
is the lack of an automated CI gate.
