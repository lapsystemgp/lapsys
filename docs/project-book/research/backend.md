# TesTly Backend — NestJS 11 + Prisma 5

This chapter documents the server-side application of **TesTly**, a medical lab-testing marketplace for Egypt. The backend lives in `apps/backend` and is built on **NestJS 11** (a TypeScript, decorator-driven Node.js framework) with **Prisma 5** as the ORM over a **PostgreSQL** database. The code is organised into feature modules under `apps/backend/src/`. The purpose of this chapter is to explain, for each module: what it is, how it works, and why it was designed that way, so that a reader can understand the system end-to-end.

The application serves three actors, modelled by the `Role` enum (`apps/backend/prisma/schema.prisma`): **Patient**, **LabStaff**, and **Admin**. Patients browse a public marketplace, book tests, pay, receive results, and chat with an AI assistant; lab staff manage their catalog, schedule, bookings, and results; admins onboard and govern labs.

---

## 1. Technology Stack and Dependencies

The exact runtime dependencies are declared in `apps/backend/package.json`. The notable ones, and the role each plays in the architecture:

- `@nestjs/common`, `@nestjs/core`, `@nestjs/platform-express` (^11.0.1) — the NestJS framework running on the Express HTTP adapter.
- `@nestjs/config` (^4.0.4) + `joi` (^18.1.2) — environment configuration with schema validation at boot.
- `@prisma/client` / `prisma` (^5.22.0) — type-safe database access and migrations against PostgreSQL.
- `@nestjs/jwt` (^11.0.2), `@nestjs/passport` (^11.0.5), `passport` (^0.7.0), `passport-jwt` (^4.0.1) — JWT issuance and the Passport JWT authentication strategy.
- `bcrypt` (^6.0.0) — password hashing (used only in `apps/backend/src/auth/auth.service.ts`).
- `class-validator` (^0.14.4) + `class-transformer` (^0.5.1) — declarative DTO validation and type coercion via the global `ValidationPipe`.
- `@nestjs/swagger` (^11.2.6) — OpenAPI/Swagger documentation served at `/api`.
- `cookie-parser` (^1.4.7) — parsing the HTTP-only auth cookie for web clients.
- `@aws-sdk/client-s3` (^3.888.0) — storing/retrieving result PDFs on S3-compatible object storage.
- `firebase-admin` (^14.0.0) — Firebase Cloud Messaging (FCM) push notifications (used only in `apps/backend/src/notifications/notifications.service.ts`).
- `@google/genai` (^2.8.0) — Google Gemini for the agentic chat assistant (used only in `apps/backend/src/chat/chat.service.ts`).

The package scripts (`package.json`) expose the standard NestJS lifecycle (`start`, `start:dev`, `build`, `start:prod`) plus Prisma helpers: `prisma:generate`, `prisma:migrate`, `prisma:seed` (`ts-node prisma/seed.ts`), `prisma:reset`, and `prisma:bootstrap` (reset + seed).

---

## 2. Global Application Setup (`main.ts` and `app.module.ts`)

### 2.1 Bootstrap (`apps/backend/src/main.ts`)

`bootstrap()` wires every cross-cutting concern before the server starts listening (default port `3001`, overridable by `PORT`):

1. **CORS** — Reads `CORS_ORIGIN` (comma-separated, default `http://localhost:3000`), splits and trims it into an allow-list. The origin callback **allows requests with no `Origin` header** (native mobile apps send none) and rejects unknown browser origins with an error. `credentials: true` is set so the browser sends the auth cookie cross-site. This dual design (cookie for web, header for mobile) recurs throughout auth.
2. **`cookie-parser`** — installed as middleware so `request.cookies` is populated for the JWT strategy.
3. **Global exception filter** — `app.useGlobalFilters(new HttpExceptionFilter())` installs the standardized error envelope (Section 9.1).
4. **Global `ValidationPipe`** — configured with `whitelist: true` (strip unknown properties), `forbidNonWhitelisted: true` (reject unknown properties with 400), and `transform: true` (instantiate DTO classes and coerce types via `class-transformer`). This is why every DTO can rely on `@Type(() => Number)` etc.
5. **Swagger** — A `DocumentBuilder` titled "TesTly Backend API" is mounted at `/api` via `SwaggerModule.setup('api', ...)`.

### 2.2 Root module (`apps/backend/src/app.module.ts`)

The root `AppModule` does three things:

- **Configuration**: `ConfigModule.forRoot({ isGlobal: true, validationSchema: Joi.object({...}) })`. The Joi schema **fails fast** at boot if required env vars are missing. Required: `DATABASE_URL`, `JWT_SECRET`. Validated-with-defaults: `NODE_ENV` (`development`/`production`/`test`/`provision`), `PORT` (3001), `LAB_STORAGE_DRIVER` (`local`|`s3`, default `local`), `CORS_ORIGIN`. Optional: `FCM_SERVICE_ACCOUNT_JSON`, `GEMINI_API_KEY`.
- **Imports**: `AuthModule` and `NotificationsModule` (the only two sub-`@Module`s; the rest of the app is registered flat on the root module).
- **Controllers / providers**: It registers, flat, all the feature controllers (`AppController`, `LabController`, `PatientController`, `PublicLabsController`, `PublicTestsController`, `BookingsController`, `FaqController`, `AdminController`, `ResultsDownloadController`, `ChatController`) and their services as providers (`PrismaService`, `BookingsService`, `PatientService`, `LabService`, `FaqService`, `AuditLogService`, `AdminService`, `ClinicalNormalizationService`, `StructuredResultsService`, `LabPatientContextService`, `ChatService`). `LabStorageService` is provided via a `useFactory` so its storage driver (local vs S3) is selected at construction time from env.

This flat-on-root layout is a pragmatic choice for a graduation-scale project: every provider is available to every controller without managing inter-module exports, at the cost of strict module encapsulation.

---

## 3. Data Model (`apps/backend/prisma/schema.prisma`)

The Prisma schema (provider `postgresql`) is the contract the whole backend operates on. Key models and enums:

**Identity**: `User` (id uuid, unique `email`, `password_hash`, `role`) has optional `patient_profile` and `lab_profile`, plus `refresh_tokens`, `device_tokens`, and `conversations`. `PatientProfile` and `LabProfile` each `@unique` on `user_id`.

**Enums**: `Role` (Patient/LabStaff/Admin); `LabOnboardingStatus` (PendingReview/Active/Rejected/Suspended); `BookingType` (LabVisit/HomeCollection/HomeTestKit); `KitStatus` (AwaitingShipment/Shipped/Delivered/SampleReceived); `BookingStatus` (Pending/Confirmed/Rejected/Cancelled/Completed); `PaymentMethod` (Online/CashHomeCollection/CashLabVisit/CashOnDelivery); `PaymentStatus` (Pending/Paid/Failed/Refunded); `ResultStatus` (Pending/Uploaded/Delivered); `ReviewStatus` (Pending/Published/Rejected); `LabHistorySharing` (SAME_LAB_ONLY default / FULL_HISTORY_AUTHORIZED); `ChatRole` (User/Assistant).

**Marketplace**: `LabProfile` (lab_name, address, city, lat/long, accreditation, turnaround_time, `home_collection`, `home_test_kit`, `onboarding_status`, denormalized `rating_average` + `review_count`, indexed on `city` and `rating_average`). `LabTest` (name, category, `price_egp` Int, description, preparation, `parameters_count`, `is_active`). `LabScheduleSlot` (starts_at/ends_at, capacity, indexed on `[lab_profile_id, starts_at]`).

**Bookings**: `Booking` carries the full lifecycle — `booking_type`, `status`, `scheduled_at`, `home_address`, `total_price_egp`, the payment block (`payment_method`, `payment_status`, `payment_reference`, `payment_paid_at`, `payment_failed_at`, `payment_failure_reason`), the kit block (`kit_status`, `kit_tracking_number`, `kit_shipped_at`, `kit_delivered_at`, `sample_received_at`), and a `@unique` optional `schedule_slot_id` (one slot ↔ one active booking). `BookingStatusEvent` is an append-only audit timeline (status, note, `actor_user_id`).

**Results**: `ResultFile` (`@unique` per booking — the official PDF: file_name, file_url, mime_type, size_bytes, `ResultStatus`, uploader). `ResultSummary` (free-text `summary` + JSON `highlights`). Structured results: `ResultPanel` → many `ResultObservation` (raw_name, value_numeric Decimal(18,6), value_text, unit, ref_low/ref_high/ref_text, plus normalization fields `value_in_canonical_unit`, `comparable_unit`, `is_comparable`, `comparability_note`). `CanonicalMarker` + `MarkerAlias` power cross-lab analyte trending.

**Other**: `Review` (rating, comment, `ReviewStatus`, `@unique` per booking); `FaqEntry`; `RefreshToken` (`@unique` `token_hash`, expiry, `revoked`); `DeviceToken` (`@unique` `fcm_token`, platform); `Conversation` → `ChatMessage` (role, content, JSON `metadata` for agentic tool cards).

The schema has evolved through 10 migrations under `apps/backend/prisma/migrations/`, from `20260326120000_init_full_schema` through structured results, lab-history sharing, payment fields, lab coordinates, home test kit, city, search indexes, and the chat models — a useful record of the project's incremental development.

---

## 4. Authentication & Authorization (`src/auth/`)

### 4.1 AuthModule (`auth.module.ts`)

Registers `PassportModule`, configures `JwtModule.registerAsync` with `signOptions.expiresIn: '8h'`, and **throws at boot if `JWT_SECRET` is unset**. Provides `AuthService`, `JwtStrategy`, and `AuditLogService`.

### 4.2 AuthController (`auth.controller.ts`) — routes

| Method | Path | Guard | Purpose |
|---|---|---|---|
| POST | `/auth/register/patient` | — | Register a patient (creates `User` + `PatientProfile`). |
| POST | `/auth/register/lab` | — | Register a lab account in `PendingReview`. |
| POST | `/auth/login` | — | Validate credentials + selected role, set cookie, return token pair. |
| GET | `/auth/me` | `JwtAuthGuard` | Return the canonical current user from DB. |
| POST | `/auth/refresh` | — | Rotate refresh token, issue new access token (mobile). |
| POST | `/auth/logout` | — | Clear cookie + revoke refresh token. |

Each register/login/logout call also emits an audit event (`auth.register.patient`, `auth.login`, etc.).

### 4.3 AuthService (`auth.service.ts`) — core logic

- **Registration**: Emails are normalized (`trim().toLowerCase()`). Existing email → `ConflictException`. Passwords are hashed with **bcrypt** using a generated salt of cost factor 10 (`bcrypt.genSalt(10)` + `bcrypt.hash`). Patient registration nests `patient_profile.create`; lab registration nests `lab_profile.create` with `onboarding_status: PendingReview` so a new lab cannot transact until an admin activates it.
- **Login** (`validateUser`): Looks up by normalized email, `bcrypt.compare`s the password, then checks that the account's `role` matches the `selectedRole` the client chose at the login screen (`patient`/`lab`/`admin`). A mismatch returns `{ wrongRole: true }`, which the controller turns into a clear "Wrong account type" `UnauthorizedException` — a deliberate UX decision so users on the wrong portal get a meaningful message.
- **Token issuance** (`login`): Builds a JWT payload `{ email, sub: userId, role }`. For lab staff it additionally embeds `lab_onboarding_status` so guards can cheaply check activation without a DB hit. The access token is signed (8h). A refresh token is created (see below).
- **Refresh-token design**: Refresh tokens are **opaque random secrets** (`randomBytes(64).toString('hex')`), never JWTs. Only their **SHA-256 hash** is stored (`RefreshToken.token_hash`), with a 30-day TTL (`REFRESH_TOKEN_TTL_DAYS`). `refreshAccessToken` looks the hash up, rejects if missing/revoked/expired, then **rotates**: it revokes the used token and issues a fresh pair. `revokeRefreshToken` and `revokeAllRefreshTokensForUser` support logout and global invalidation. This rotation-with-revocation pattern limits the blast radius of a stolen refresh token.
- **`getCurrentUser`**: Returns id/email/role plus thin profile slices for `/auth/me`.

### 4.4 Strategies & Guards

- **`JwtStrategy`** (`strategies/jwt.strategy.ts`): Extracts the JWT from **two** sources via `ExtractJwt.fromExtractors`: first the `access_token` HTTP-only cookie (web), then the `Authorization: Bearer` header (mobile). `validate()` re-fetches the user from the DB (so a deleted user is rejected even with a valid token) and returns `{ id, email, role, lab_onboarding_status }`, which Nest attaches to `req.user`.
- **`JwtAuthGuard`** (`guards/jwt-auth.guard.ts`): Thin `AuthGuard('jwt')` subclass.
- **`RolesGuard`** (`guards/roles.guard.ts`): Reads required roles from the `@Roles(...)` metadata via `Reflector.getAllAndOverride` (method overrides class). If no roles are declared it allows; otherwise it requires `req.user.role` to be one of them.
- **`LabActiveGuard`** (`guards/lab-active.guard.ts`): For `LabStaff` users it asserts `lab_onboarding_status === Active`, throwing `ForbiddenException('Lab account is not active')` otherwise. Non-lab roles pass through untouched. This is what prevents a `PendingReview`/`Suspended` lab from operating even though it can authenticate.
- **`@Roles` decorator** (`decorators/roles.decorator.ts`): `SetMetadata('roles', roles)`.

### 4.5 Cookie strategy (`auth.constants.ts`)

`buildAuthCookieOptions()` returns `httpOnly: true, path: '/'`, and **environment-dependent** `sameSite`/`secure`: in production `sameSite: 'none'` + `secure: true` (web and API are on different sites, e.g. Vercel + Railway, so the browser only accepts/sends the cookie cross-site under these flags); locally `sameSite: 'lax'` + non-secure so it works over plain `http://localhost`. The cookie `maxAge` is 8h, matching the access-token TTL. Logout calls `clearCookie` with the *same* attributes so the browser reliably drops it.

### RBAC summary

Access control is layered: **(1)** `JwtAuthGuard` proves identity; **(2)** `RolesGuard` + `@Roles` enforce the actor type; **(3)** `LabActiveGuard` enforces lab activation on lab-only routes; **(4)** every service performs **ownership checks** (e.g. "you can only update your own lab bookings") as a defence-in-depth layer that does not trust the route guard alone.

---

## 5. Public Marketplace (`src/public/`)

These controllers are **unauthenticated** — the storefront a visitor browses before signing up. Every query is hard-filtered to `onboarding_status: Active`, so only approved labs and their active tests are ever exposed.

### 5.1 PublicLabsController (`public-labs.controller.ts`)

| Method | Path | Purpose |
|---|---|---|
| GET | `/public/labs` | Search/filter/sort/paginate active labs. |
| GET | `/public/labs/:labProfileId` | Lab detail: profile, paginated test catalog, published reviews. |

`listLabs` is the most elaborate endpoint. It accepts query params `q`, `labName`, `city`, `page`, `pageSize`, `sort` (`price`/`rating`/`distance`), `minRating`, `maxDistanceKm`, `userLat`/`userLng`, `maxPriceEgp`, `homeCollection`, `accreditations` (CSV). Logic:
- Builds a base Prisma `where` for active labs matching the structured filters.
- For free-text `q`, it tokenizes (dropping stopwords "test"/"tests"), then unions labs matching by **name/address** with labs matching by **test catalog** (name/category/description), and records the minimum matching test price per lab via `groupBy`.
- Computes per-lab `startingFromEgp` and `testsAvailable` via `groupBy` aggregates.
- If user coordinates are supplied, computes `distanceKm` with the **Haversine formula** (`haversineKm` in `public-utils.ts`) and filters by `maxDistanceKm`; un-geocoded labs are excluded only when an explicit radius is supplied.
- Sorts in-memory by the chosen key, then paginates. Returns `{ items, pagination }`.

`getLabDetail` returns the lab card, a paginated/sortable/searchable view of that lab's active tests, and up to 50 **published** reviews, with reviewer names **privacy-reduced** to "First L." form (single name kept, "Anonymous" if blank).

`public-utils.ts` provides the shared, defensive helpers: `clampInt`/`clampFloat` (parse + bound, fall back to a default), `parseBoolean`, `parseCsv`, and `haversineKm`. Clamping all numeric query params is a deliberate hardening choice against malformed or hostile input.

### 5.2 PublicTestsController (`public-tests.controller.ts`)

| Method | Path | Purpose |
|---|---|---|
| GET | `/public/tests` | Catalog of distinct tests (grouped by name+category) with min price and lab count. |
| GET | `/public/tests/by-name` | All active labs offering a specific `name`+`category` test, price-ascending. |
| GET | `/public/tests/:labTestId` | One specific lab-test row + its lab. |

`listTests` uses `groupBy(['name','category'])` so the same test offered by many labs appears once with its cheapest price and the number of labs offering it — the "compare across labs" view. `by-name` is the comparison drill-down (returns the test metadata plus every lab's price, rating, accreditation, and coordinates). All three filter to active labs/tests.

---

## 6. Bookings & Payments (`src/bookings/`)

The bookings module is the transactional heart of the system. `BookingsController` is guarded globally by `@UseGuards(JwtAuthGuard, RolesGuard)`; lab-only routes add `LabActiveGuard`.

### 6.1 Routes

| Method | Path | Role / Guard | Purpose |
|---|---|---|---|
| GET | `/bookings/availability` | Patient | Open future slots for a lab+test over N days. |
| POST | `/bookings` | Patient | Create a booking. |
| GET | `/bookings/patient` | Patient | List the caller's bookings. |
| PATCH | `/bookings/:bookingId/patient-cancel` | Patient | Cancel own pending/confirmed booking. |
| POST | `/bookings/:bookingId/demo-online-payment` | Patient | Simulate online payment (`success`/`failure`). |
| PATCH | `/bookings/:bookingId/mark-cash-collected` | LabStaff + Active | Record cash payment received. |
| GET | `/bookings/lab` | LabStaff + Active | List the lab's bookings. |
| PATCH | `/bookings/:bookingId/lab-status` | LabStaff + Active | Confirm/Reject a pending booking. |
| PATCH | `/bookings/:bookingId/kit-status` | LabStaff + Active | Advance home-test-kit fulfilment stage. |

### 6.2 Availability and booking creation

`getAvailability` resolves the window bounds **in UTC** (a comment explains this is deliberate so the Cairo server timezone, UTC+2/+3, doesn't mis-bucket slots near midnight), verifies the test exists at an active lab, loads slots in the window, and excludes any slot whose linked booking is in an "active" state (`Pending`/`Confirmed`/`Completed`). Returns ISO timestamps.

`createBooking` enforces a chain of business rules before writing:
1. Caller must have a `PatientProfile`.
2. The test must be active at an active lab.
3. **Capability checks**: `HomeCollection` requires `lab.home_collection`; `HomeTestKit` requires `lab.home_test_kit`; both require a non-empty `homeAddress`.
4. **Payment-method/booking-type compatibility**: `CashHomeCollection` only for `HomeCollection`, `CashLabVisit` only for `LabVisit`, `CashOnDelivery` only for `HomeTestKit`. Default method is `Online`.
5. **Scheduling**: `HomeTestKit` has no appointment — `scheduled_at` is set to ~5 days out as an estimated delivery date and `kit_status` initialises to `AwaitingShipment`. Other types require a `slotId` that exists, is active, and is in the future.
6. **Pricing**: `total_price_egp = test.price_egp + (HomeCollection ? 100 : 0) + (HomeTestKit ? 150 : 0)` — fixed surcharges for home logistics.
7. **Atomicity**: All writes run inside `prisma.$transaction`. Inside the transaction it re-checks for a conflicting active booking on the slot and relies on the `schedule_slot_id @unique` constraint, catching Prisma's `P2002` unique-violation to throw a friendly `ConflictException('Selected slot is already booked')` — protecting against double-booking races. It creates the booking with `status: Pending`, `payment_status: Pending`, and writes the first `BookingStatusEvent` ("Booking created by patient").

After commit it logs `booking.created` and **notifies the lab** via FCM ("New Booking").

### 6.3 Payment handling — design

Payment is modelled by two fields on `Booking`: `payment_method` (how) and `payment_status` (where in the lifecycle). The project supports **four methods** and **four statuses**, exercised by three flows:

- **Online (simulated gateway)** — `demoOnlinePayment`. The method name is honest: this is a graduation-demo simulation, not a real PayMob/charge integration (the code comment reads "simulates an online payment gateway (no real charges)"). It validates ownership, that the method is `Online`, that the booking is still `Pending`, and that it isn't already `Paid`/`Refunded`. On `outcome === 'success'` it sets `payment_status: Paid`, a synthetic `payment_reference: DEMO-PAY-<uuid>`, and `payment_paid_at`; on `failure` it sets `payment_status: Failed`, `payment_failed_at`, and `payment_failure_reason: 'Simulated gateway decline (demo only)'`. Audited as `booking.payment.demo_succeeded` / `_failed`. This cleanly mirrors what a real gateway webhook would do, so swapping in a real provider later is a localized change. *(The architecture name "PayMob/online" in the project brief corresponds to this `Online` method; the current implementation stubs the gateway.)*
- **Cash variants** — `markCashCollected` (lab-side). Applies to `CashHomeCollection`, `CashLabVisit`, and `CashOnDelivery`. After ownership/active-lab checks, it requires the current `payment_status` to be `Pending` and the booking to be `Pending`/`Confirmed`, then sets `Paid` with `payment_reference: DEMO-CASH-<timestamp>` and `payment_paid_at`. It is idempotent on already-`Paid` bookings (returns the booking unchanged). Audited as `booking.payment.cash_marked_collected`.
- **Refund** — handled inside `cancelByPatient`: if the cancelled booking was `Paid`, `payment_status` transitions to `Refunded` (statuses `Pending`/`Failed` are left as-is). No money actually moves; the status reflects what a real refund would record.

A key **gating rule** lives in `setLabBookingStatus`: a lab cannot `Confirm` an `Online` booking unless `payment_status === Paid` ("Online payment must be completed before the lab can confirm this booking"). Cash bookings can be confirmed before collection. This encodes the real-world difference between prepaid online orders and pay-on-service cash orders.

### 6.4 Booking lifecycle transitions

- `setLabBookingStatus` restricts labs to `Confirmed` or `Rejected`, only from `Pending`. `Rejected` releases the slot (`schedule_slot_id: null`). Writes a `BookingStatusEvent`, audits, and **notifies the patient** (Confirmed/Rejected).
- `cancelByPatient` allows cancellation only from `Pending`/`Confirmed`, releases the slot, optionally refunds, writes a `Cancelled` event, and audits.
- `updateKitStatus` (home test kits) enforces a **strict one-step forward** state machine `AwaitingShipment → Shipped → Delivered → SampleReceived` (rejects skipping stages), blocks shipping before payment unless the method is `CashOnDelivery`, stamps the matching timestamp field (`kit_shipped_at`, etc.), stores a tracking number on shipment, and pushes a "Kit Shipped" notification.

The whole module returns a uniform, camelCased `toBookingResponse` shape that includes the full `timeline` of status events — the frontend renders this as an order-tracking view.

---

## 7. Patient & Lab Workspaces (`src/api/`)

This module hosts the authenticated, role-specific "workspaces" plus result handling. It is the largest module.

### 7.1 PatientController (`patient.controller.ts`)

Guarded by `JwtAuthGuard, RolesGuard`, all routes `@Roles(Role.Patient)`.

| Method | Path | Purpose |
|---|---|---|
| GET | `/patient/workspace` | Aggregated dashboard: profile, upcoming/past bookings, results. |
| GET | `/patient/health-profile` | Cross-lab analyte trends (`range`=3m/6m/12m/all, `groupBy`=analyte/lab_test). |
| PATCH | `/patient/profile` | Update name/phone/address and `labHistorySharing`. |
| POST | `/patient/reviews` | Submit a review for a completed booking. |

`PatientService.getWorkspace` does one rich query and maps it into `{ profile, bookings: { upcoming, past }, results }`. Bookings are split upcoming/past by `scheduled_at`. The `results` list is derived only for bookings that have a `result_file` or `result_summary`, and each result carries: the file reference (served as `/results/files/<id>`, never the raw storage URL), the normalized summary highlights, whether structured data exists (`hasStructuredData`, `structuredObservationCount`), the review (if any), and a `canReview` flag (true only when a result is `Uploaded`/`Delivered` and not yet reviewed).

`createReview` enforces: patient owns the booking; a `result_file` exists and is `Uploaded`/`Delivered`; no review yet. It writes the review as `Published` inside a transaction, then **recomputes the lab's denormalized `rating_average` + `review_count`** (`recomputeLabRating` aggregates published reviews) so public listings stay fast, and notifies the lab.

`updateProfile` does partial updates (only non-empty trimmed fields), including the privacy toggle `lab_history_sharing` (Section 7.5).

### 7.2 LabController (`lab.controller.ts`)

Guarded by `JwtAuthGuard, RolesGuard, LabActiveGuard` at the class level, all routes `@Roles(Role.LabStaff)`.

| Method | Path | Purpose |
|---|---|---|
| GET | `/lab/workspace` | Lab dashboard: profile, booking queue, tests, schedule, analytics. |
| PATCH | `/lab/profile` | Toggle `homeCollection` / `homeTestKit`. |
| GET | `/lab/patient-context` | Privacy-scoped clinical history for a patient (by bookingId or patientProfileId). |
| POST | `/lab/tests` | Create a lab test. |
| PATCH | `/lab/tests/:testId` | Update a test. |
| DELETE | `/lab/tests/:testId` | Delete a test (blocked if it has bookings). |
| POST | `/lab/schedule` | Create a schedule slot. |
| PATCH | `/lab/schedule/:slotId` | Update a slot. |
| DELETE | `/lab/schedule/:slotId` | Deactivate a slot (soft delete). |
| POST | `/lab/results/:bookingId/upload` | Upload the official result **PDF** (+ summary/highlights). |
| PATCH | `/lab/results/:bookingId/status` | Set result status (`Uploaded`/`Delivered`). |
| PUT | `/lab/results/:bookingId/structured` | Upsert structured panels/observations. |

`LabService.getWorkspace` runs six queries in parallel (`Promise.all`) — the booking queue (reusing `BookingsService.listLabBookings`), tests, slots (capped at 120), computed analytics, and a `groupBy` of top-5 most-booked tests. `computeAnalytics` derives totals, completed count, pending-results count, a revenue estimate (sum of `total_price_egp` over confirmed/completed bookings), and a capacity-usage percentage (occupied future active slots ÷ total future active slots).

Test/slot CRUD all funnel through `getLabProfileId(userId)` for the ownership check, validate inputs, and (for slots) enforce a future, well-ordered window via `validateScheduleWindow`. Deleting a slot is a **soft delete** (`is_active: false`) to preserve referential history; deleting a test is blocked when bookings reference it.

### 7.3 Results handling — PDF + structured data

TesTly stores results in **two complementary forms**, a deliberate design that separates the legally authoritative document from the queryable data.

**(a) Official PDF** — `LabService.uploadResult`. It rejects anything whose MIME type isn't PDF **and** verifies the magic bytes (`buffer.subarray(0,4) === '%PDF'`) — a robust content check beyond the file extension. The route uses Multer's `FileInterceptor('file', { limits: { fileSize: 10MB } })`. It validates lab ownership and that the booking isn't cancelled/rejected, persists the file via `LabStorageService` (Section 8.1), and in one transaction **upserts** the `ResultFile` (status `Uploaded`) and the `ResultSummary` (free-text summary + optional `highlights` JSON, which is parsed defensively and rejected with 400 if malformed), and appends a status event. The response exposes the file only through the proxy path `/results/files/<id>`.

**(b) Structured results** — `StructuredResultsService.upsertStructuredResults` (Section 8.2). The lab posts panels of observations; this requires that the official PDF already exists ("Upload the official PDF result before adding structured data"). The whole panel set is replaced (`deleteMany` then recreate) inside a transaction, so an upsert is a full overwrite.

**Status & delivery** — `setResultStatus` sets `Uploaded`/`Delivered`. Setting `Delivered` also flips the booking to `Completed`, writes a "Result delivered" event, and pushes a "Result Ready" notification to the patient.

**Result highlights normalization** (`result-highlights.util.ts`): Because labs may submit `highlights` JSON in several shapes (object map, array of strings, array of `{label,value}`, or a single string), `normalizeResultHighlights` coerces all of them into a stable `{ items: [{ key, label, value, kind }] }` list (with slugified keys) so the patient UI renders consistently regardless of how the lab entered the data.

### 7.4 Structured results & cross-lab trending (`structured-results.service.ts` + `clinical-normalization.service.ts`)

This is the most clinically interesting subsystem. The problem it solves: different labs report the **same analyte** under different names and units, so naive trending across labs is meaningless. The solution is canonical normalization.

`ClinicalNormalizationService`:
- `normalizeKey` lowercases, strips accents/diacritics (NFD + combining-mark removal), and collapses to single-spaced alphanumerics — a stable matching key.
- `resolveCanonicalMarker(canonicalCode, rawName)` resolves a raw observation to a `CanonicalMarker` by, in order: explicit code → `MarkerAlias` table lookup on the normalized key → fuzzy match against canonical display names. Returns `null` if unmapped.
- `toCanonicalValue` performs **unit conversion** to a canonical unit with explicit, hand-coded clinical rules per marker: glucose mmol/L → mg/dL (×18); HbA1c IFCC mmol/mol → NGSP % (`(v+23.5)/10.93`); creatinine µmol/L → mg/dL (÷88.4); TSH unit harmonisation to mIU/L; FT4/FT3 pass-through. Unrecognised units are flagged `comparable: false` with an explanatory `note` rather than silently mis-converted — a safety-first choice.
- `referenceRangeToCanonical` converts reported reference bounds with the same rules (and swaps inverted bounds).

`StructuredResultsService.upsertStructuredResults` validates ownership and that a PDF exists, then per observation resolves the canonical marker and computes `value_in_canonical_unit`, `comparable_unit`, `is_comparable`, and `comparability_note`. Non-numeric and unmapped values are explicitly marked non-comparable so they never pollute numeric trends.

`getHealthProfile(userId, range, groupBy)` powers `/patient/health-profile`. It pulls comparable, canonical-valued observations within the time range, groups them into series (by analyte or by lab+test), computes per-series **trend** (`increasing`/`decreasing`/`stable`/`insufficient_data`, using a 2% relative threshold between first and last point) and a qualitative note about crossing the reference band, flags each point `abnormal` against the converted reference range, and also surfaces `pdfOnlyBookings` (results that exist only as PDFs with no structured data). A repeated **disclaimer** stresses the data is informational, not clinical advice.

### 7.5 Lab patient-context with privacy scoping (`lab-patient-context.service.ts`)

`/lab/patient-context` lets a lab view a patient's clinical history when preparing or interpreting a sample. Its central concern is **privacy**, governed by the patient's `lab_history_sharing` setting:
- `SAME_LAB_ONLY` (default): the lab sees only bookings/results/summaries from **its own** lab.
- `FULL_HISTORY_AUTHORIZED`: the lab additionally sees **cross-lab** structured summaries and trends — but **never other labs' PDFs** (PDF links are emitted only for the requesting lab's own uploads).

Access requires either a `bookingId` belonging to the lab, or a `patientProfileId` for which `assertLabPatientRelationship` confirms at least one booking exists between this lab and the patient (no relationship → `ForbiddenException`). The response returns demographics, prior bookings (with summary previews truncated to 220 chars and structured observation summaries), a recurring-tests summary, a bounded 12-month `trendSummary` (capped at 8 markers × 4 points), and an explicit `privacyNotice` describing the effective scope. Constants (`MAX_BOOKINGS=45`, `MAX_TREND_MARKERS=8`, etc.) bound the payload.

### 7.6 Result file download (`results-download.controller.ts`)

`GET /results/files/:id` (guarded by `JwtAuthGuard`) is the single, authorization-checked gateway to result PDFs — clients never receive the raw S3/disk URL. It loads the `ResultFile` with its booking's patient and lab user ids and authorizes by relationship: **Admin**, the owning **patient**, or the owning **lab staff**. A patient may only download once the result is `Uploaded`/`Delivered`. It then streams the file from `LabStorageService.streamFile`, setting `Content-Type`, `X-Content-Type-Options: nosniff`, and a `Content-Disposition: attachment` header (with quote-stripping on the filename). Storage-miss errors degrade to `404`.

---

## 8. Integrations

### 8.1 File storage / AWS S3 (`api/lab-storage.service.ts`)

`LabStorageService` is a thin facade over a `LabFileStorageAdapter` interface with two implementations, selected at construction from `LAB_STORAGE_DRIVER`:
- **`LocalDiskLabStorageAdapter`** (default `local`) — writes to `uploads/results/` with a randomized safe filename; used in development.
- **`S3CompatibleLabStorageAdapter`** (`s3`) — uses `@aws-sdk/client-s3`. The SDK is loaded lazily via `require('@aws-sdk/client-s3')` (`loadS3Sdk`) so the heavy dependency is only pulled in when S3 is actually configured. It reads required env (`LAB_S3_BUCKET`, `LAB_S3_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`; optional `AWS_SESSION_TOKEN`, `LAB_S3_ENDPOINT`, `LAB_S3_PUBLIC_BASE_URL`), supports S3-compatible providers via custom endpoint + `forcePathStyle`, writes objects under date-partitioned keys `results/YYYY-MM-DD/<ts>-<uuid>-<safeName>.pdf` (sanitized), and `streamFile` re-derives the object key from the stored URL by anchoring on `/results/`. Because `LabStorageService` is registered through a `useFactory` in `app.module.ts`, the right adapter is chosen once at startup. The adapter pattern means the rest of the codebase is storage-agnostic.

### 8.2 Push notifications / Firebase Admin (`notifications/`)

`NotificationsModule` is a real Nest sub-module that **exports** `NotificationsService` so other modules can inject it. The service initializes the Firebase Admin SDK from `FCM_SERVICE_ACCOUNT_JSON`; if that env var is absent it logs a warning and **degrades gracefully** (push becomes a no-op) — the rest of the app works without FCM configured.

- `NotificationsController`: `POST /notifications/device` (204) registers/refreshes an FCM token; `DELETE /notifications/device` (204) removes one on logout. Both require `JwtAuthGuard`. `RegisterDeviceDto` validates a non-empty `fcm_token` and `platform ∈ {ios, android}`.
- `sendToUser(userId, payload)` looks up the user's `DeviceToken`s and sends a multicast message. It **prunes stale tokens** automatically: responses with `registration-token-not-registered` / `invalid-registration-token` errors are deleted. This keeps the token table self-cleaning.

Push is emitted at every meaningful state change: new booking (→lab), booking confirmed/rejected (→patient), kit shipped (→patient), result ready (→patient), and new review (→lab).

### 8.3 AI assistant / Google GenAI (`chat/`)

`ChatService` uses `@google/genai` with model `gemini-2.5-flash` to power an **agentic** health assistant for patients. It is configured by `GEMINI_API_KEY`; missing key → `ServiceUnavailableException`. Endpoints (all `@Roles(Role.Patient)`):

| Method | Path | Purpose |
|---|---|---|
| GET | `/chat/conversations` | List the patient's conversations. |
| GET | `/chat/conversations/:id/messages` | Get messages (ownership-checked, UUID-validated). |
| POST | `/chat/messages` | Send a message; reply streamed as **Server-Sent Events**. |

`sendMessage` deliberately uses `@Res()` directly and streams SSE (`text/event-stream`), so it **bypasses the global filters/interceptors**; errors surface as an `error` SSE event rather than the standard HTTP envelope. The SSE protocol emits typed events: `meta` (conversation id), `delta` (streamed text), `tool` (structured cards), `done` (message id), `error`.

`streamReply` implements a **function-calling loop** (bounded to `MAX_TOOL_ROUNDS=4`). The model is given a strict `SYSTEM_PROMPT` (it is not a doctor; never invents prices/labs; defers to physicians; emergency-care guidance; replies in the user's language) and two tools: `find_labs(query, city?)` and `search_tests(query)`. When the model calls a tool, the service runs the real Prisma query (only active labs/tests), streams structured **lab/test cards** to the UI as `tool` events, and feeds a compact payload back to the model so it can summarise. User and assistant messages are persisted (the assistant's `metadata.tools` stores the cards for replay); history is capped at the last 20 turns. This grounds the LLM in real catalog data and prevents hallucinated prices/availability.

---

## 9. Cross-Cutting Concerns

### 9.1 Standardized error envelope (`common/filters/http-exception.filter.ts`)

`HttpExceptionFilter` is a global `@Catch()` filter (catches *everything*, not just `HttpException`). For Nest `HttpException`s it preserves the status and message; for anything else it logs the stack and returns `500`. The uniform JSON envelope is:

```json
{ "statusCode": <number>, "message": <string|string[]>, "timestamp": <ISO>, "path": <originalUrl> }
```

This means every client — web, mobile, Swagger — sees the same error shape, and `class-validator` failures (arrays of messages) pass through cleanly. (As noted, the chat SSE endpoint intentionally opts out, reporting errors as SSE events instead.)

### 9.2 Validation (`class-validator` + global pipe)

Validation is entirely **declarative** via DTOs decorated with `class-validator` (e.g. `@IsEmail`, `@IsEnum`, `@IsUUID`, `@MinLength`, `@Min/@Max`, `@MaxLength`, `@ValidateNested`) and `class-transformer` (`@Type(() => Number)` for query-string coercion). The global `ValidationPipe` (whitelist + forbid-non-whitelisted + transform) enforces them everywhere. Highlights: `LoginDto.selectedRole` is constrained to `patient|lab|admin`; `CreateBookingDto` validates booking-type/payment-method enums; `UpsertStructuredResultDto` recursively validates nested panels and observations; `SendMessageDto` bounds chat text to 4000 chars. Several services add a second layer of semantic validation that the type system can't express (future-dated slots, one-step kit transitions, payment-before-confirm).

### 9.3 Audit logging (`common/services/audit-log.service.ts`)

`AuditLogService.log(event, details)` emits a structured JSON line (`{ event, details, timestamp }`) through the Nest `Logger` under the `AuditLog` context. It is lightweight (log-stream based, not a DB table) and is invoked at every security- or money-relevant action: auth (register/login/logout), booking creation, every payment transition (demo success/failure, cash collected), booking status changes, kit updates, result upload/status, test deletion, and admin lab-status changes. The booking lifecycle additionally keeps a **persistent** audit trail in the `BookingStatusEvent` table (with `actor_user_id`), giving both a real-time log and a queryable history.

### 9.4 Database resilience (`prisma/prisma.service.ts`)

`PrismaService` extends `PrismaClient` and hooks `OnModuleInit`/`OnModuleDestroy` for connect/disconnect. It installs a **`$use` middleware that retries transient errors** (codes `P1001`, `P1002`, `P1017`, `P2024`, plus init/rust-panic errors) up to 3 times with linear backoff (`150ms × attempt`). This is explicitly aimed at serverless Postgres (Neon) cold-starts and pool timeouts, making the API resilient to the most common infrastructure hiccups.

---

## 10. Admin Module (`src/admin/`)

`AdminController` is guarded by `JwtAuthGuard, RolesGuard` with class-level `@Roles(Role.Admin)`; `AdminService` additionally re-asserts admin on every method (`assertAdmin`), a defence-in-depth duplicate of the guard.

| Method | Path | Purpose |
|---|---|---|
| GET | `/admin/workspace` | Lab governance dashboard with onboarding readiness. |
| PATCH | `/admin/labs/:labProfileId/status` | Set a lab's `LabOnboardingStatus`. |
| GET | `/admin/stats` | Total bookings + total paid revenue. |
| GET | `/admin/patients` | List patients with booking counts. |
| GET | `/admin/payments/recent` | Recent payments feed (booking + payment fields). |
| GET | `/admin/analytics/charts` | 30-day booking volume, revenue by city, popular tests. |

The standout is the **onboarding readiness gate**. `getWorkspace` enriches each lab with an `onboardingReadiness` object computed by `buildOnboardingReadiness`: a lab is "ready" only if it has a phone, accreditation, turnaround time, ≥1 active test, and ≥1 active schedule slot (5 requirements; the response lists exactly which are missing). `setLabOnboardingStatus` **refuses to activate** (`status: Active`) a lab that isn't ready, throwing a `BadRequestException` naming the missing requirements. This guarantees that any lab that becomes bookable in the public marketplace is operationally complete. Status changes are audited (`admin.lab_onboarding_status.updated`, with previous/next status). `getChartData` builds zero-filled daily volume, revenue-by-city (paid bookings), and popular-tests aggregates for the admin charts.

---

## 11. FAQ Module (`src/faq/`)

`FaqController` (public, no auth) provides a lightweight, **non-LLM** help system — a deterministic fallback to the AI assistant:

| Method | Path | Purpose |
|---|---|---|
| GET | `/faq/intents` | Guided quick-action intents (prep/fasting, pricing, booking, results). |
| GET | `/faq/search` | Search active `FaqEntry` rows (question/answer/tags). |
| POST | `/faq/ask` | Return the best-matching FAQ answer + escalation note. |

`FaqService.search` queries active entries with case-insensitive `contains` over question/answer and `hasSome` over the `tags` array, paginated. `ask` reuses `search` and returns the top answer (or a support-contact fallback) plus an escalation message. A hard-coded `GUIDED_INTENTS` list seeds the chatbot's quick-action buttons. This module exists so the app can answer common questions cheaply and reliably without consuming Gemini quota or risking hallucination.

---

## 12. Root Controller

`AppController` exposes `GET /` → `"Hello World!"` (`AppService.getHello`), a trivial liveness/health check.

---

## 13. Complete REST API Endpoint Table

| # | Method | Path | Auth / Role | Purpose |
|---|---|---|---|---|
| 1 | GET | `/` | public | Liveness ("Hello World!"). |
| 2 | POST | `/auth/register/patient` | public | Register patient. |
| 3 | POST | `/auth/register/lab` | public | Register lab (PendingReview). |
| 4 | POST | `/auth/login` | public | Login; sets cookie + returns token pair. |
| 5 | GET | `/auth/me` | JWT | Current user. |
| 6 | POST | `/auth/refresh` | public (refresh token) | Rotate tokens. |
| 7 | POST | `/auth/logout` | public | Clear cookie + revoke refresh token. |
| 8 | GET | `/public/labs` | public | Search/filter labs. |
| 9 | GET | `/public/labs/:labProfileId` | public | Lab detail + tests + reviews. |
| 10 | GET | `/public/tests` | public | Distinct tests (min price, lab count). |
| 11 | GET | `/public/tests/by-name` | public | Labs offering a named test. |
| 12 | GET | `/public/tests/:labTestId` | public | Single lab-test detail. |
| 13 | GET | `/bookings/availability` | Patient | Open future slots. |
| 14 | POST | `/bookings` | Patient | Create booking. |
| 15 | GET | `/bookings/patient` | Patient | List own bookings. |
| 16 | PATCH | `/bookings/:bookingId/patient-cancel` | Patient | Cancel own booking. |
| 17 | POST | `/bookings/:bookingId/demo-online-payment` | Patient | Simulate online payment. |
| 18 | PATCH | `/bookings/:bookingId/mark-cash-collected` | LabStaff (Active) | Record cash collected. |
| 19 | GET | `/bookings/lab` | LabStaff (Active) | List lab bookings. |
| 20 | PATCH | `/bookings/:bookingId/lab-status` | LabStaff (Active) | Confirm/Reject. |
| 21 | PATCH | `/bookings/:bookingId/kit-status` | LabStaff (Active) | Advance kit stage. |
| 22 | GET | `/patient/workspace` | Patient | Patient dashboard. |
| 23 | GET | `/patient/health-profile` | Patient | Cross-lab analyte trends. |
| 24 | PATCH | `/patient/profile` | Patient | Update profile + sharing. |
| 25 | POST | `/patient/reviews` | Patient | Submit review. |
| 26 | GET | `/lab/workspace` | LabStaff (Active) | Lab dashboard. |
| 27 | PATCH | `/lab/profile` | LabStaff (Active) | Toggle home collection/kit. |
| 28 | GET | `/lab/patient-context` | LabStaff (Active) | Privacy-scoped patient history. |
| 29 | POST | `/lab/tests` | LabStaff (Active) | Create test. |
| 30 | PATCH | `/lab/tests/:testId` | LabStaff (Active) | Update test. |
| 31 | DELETE | `/lab/tests/:testId` | LabStaff (Active) | Delete test (if no bookings). |
| 32 | POST | `/lab/schedule` | LabStaff (Active) | Create slot. |
| 33 | PATCH | `/lab/schedule/:slotId` | LabStaff (Active) | Update slot. |
| 34 | DELETE | `/lab/schedule/:slotId` | LabStaff (Active) | Deactivate slot. |
| 35 | POST | `/lab/results/:bookingId/upload` | LabStaff (Active) | Upload result PDF + summary. |
| 36 | PATCH | `/lab/results/:bookingId/status` | LabStaff (Active) | Set result status. |
| 37 | PUT | `/lab/results/:bookingId/structured` | LabStaff (Active) | Upsert structured results. |
| 38 | GET | `/results/files/:id` | JWT (relationship) | Download result PDF (stream). |
| 39 | GET | `/admin/workspace` | Admin | Lab governance dashboard. |
| 40 | PATCH | `/admin/labs/:labProfileId/status` | Admin | Set onboarding status. |
| 41 | GET | `/admin/stats` | Admin | Aggregate stats. |
| 42 | GET | `/admin/patients` | Admin | List patients. |
| 43 | GET | `/admin/payments/recent` | Admin | Recent payments. |
| 44 | GET | `/admin/analytics/charts` | Admin | Chart datasets. |
| 45 | GET | `/faq/intents` | public | Guided intents. |
| 46 | GET | `/faq/search` | public | Search FAQ. |
| 47 | POST | `/faq/ask` | public | Best FAQ answer. |
| 48 | GET | `/chat/conversations` | Patient | List conversations. |
| 49 | GET | `/chat/conversations/:id/messages` | Patient | Conversation messages. |
| 50 | POST | `/chat/messages` | Patient | Send message (SSE stream). |
| 51 | POST | `/notifications/device` | JWT | Register FCM token (204). |
| 52 | DELETE | `/notifications/device` | JWT | Remove FCM token (204). |

---

## 14. Design Summary

The backend's recurring architectural themes, and why they matter for a marketplace handling health data and money:

- **Dual-client auth** (cookie for web, Bearer for mobile) with rotating, hashed, opaque refresh tokens — secure sessions for both client types from one codebase.
- **Layered RBAC** (identity guard → role guard → lab-active guard → per-service ownership checks) — no single point of failure in authorization.
- **Activation gating** — labs must pass a concrete 5-point readiness check before they can be activated and become bookable, so the public marketplace only ever exposes operational labs.
- **Payment as explicit state** — `payment_method` × `payment_status`, with the online-prepaid-vs-cash distinction enforced at confirmation, and refunds modelled as a status transition; the gateway is currently a faithful simulation that a real provider can drop into.
- **Results in two forms** — an authoritative PDF (served only through an authorization-checked proxy) plus normalized structured observations enabling safe, unit-converted, cross-lab health trends, with privacy controlled by the patient.
- **Graceful degradation** of optional integrations (FCM, Gemini, S3) so the core API runs even when they're unconfigured, and **DB-level resilience** via transient-error retries for serverless Postgres.
- **Uniform contracts** — one error envelope, declarative validation, and consistent camelCased response shapes across every endpoint.
