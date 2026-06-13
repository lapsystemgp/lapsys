# TesTly Mobile App — Detailed Build Plan & Implementation Spec

> **Audience:** This document is written to be executed by an AI coding agent (Sonnet) with no prior
> context about this conversation. It is self-contained. Read it top to bottom before starting.
> Every phase lists exact files to touch, code patterns to follow, and acceptance criteria.

---

## 0. Context: what TesTly is

TesTly is a **lab-testing marketplace for Egypt**. Patients search for diagnostic labs, book tests,
pay (cash or a demo online flow), and receive results (PDF + structured data with cross-lab health
trends). Labs manage their catalog, bookings, schedule, and results, and see an analytics dashboard.
Admins approve labs and view platform-wide stats.

### Existing monorepo layout

```
my-fullstack-app/
├── apps/
│   ├── backend/      # NestJS 11 + Prisma 5 + PostgreSQL (Neon). REST API on :3001
│   ├── frontend/     # Next.js 16 (React 19) web app on :3000
│   └── mobile/       # ← NEW: Flutter app (this plan creates it)
└── docs/
    └── mobile-plan.md  # this file
```

### Existing tech facts the mobile app depends on

- **API base URL (dev):** `http://localhost:3001`. Swagger at `http://localhost:3001/api`.
- **Auth today:** JWT signed with `JWT_SECRET`, delivered as an **HTTP-only cookie** named
  `access_token` (see `apps/backend/src/auth/auth.constants.ts` → `AUTH_COOKIE_NAME`). Token TTL = 8h.
  JWT payload: `{ sub: userId, email, role, lab_onboarding_status? }`.
- **Roles** (`Role` enum in Prisma): `Patient`, `LabStaff`, `Admin`.
- **Lab gating:** `LabStaff` accounts must have `onboarding_status = "Active"` (Prisma
  `LabOnboardingStatus`: `PendingReview | Active | Rejected | Suspended`) to reach `/lab/*` endpoints
  (enforced by `LabActiveGuard`).

### Demo accounts (password `password123` for all)

- Admin: `admin@testly.com`
- Active lab: `alborglaboratories@testly.com`
- Patient: `patient@testly.com` (Mazen Amir)
- Pending lab (blocked from workspace): `pendinglab@testly.com`

---

## 1. Product scope for the mobile app

The Flutter app ships **two role experiences** selected at login:

| Mode | Who | Capability |
|---|---|---|
| **Patient** | `Role.Patient` | **Full** parity with the website's patient surface — browse/book/pay/results/trends/profile — plus mobile-only features (push, maps, biometrics, offline results). |
| **Lab** | `Role.LabStaff` (Active) | **Strictly read-only analytics & monitoring.** Charts, KPIs, reviews, booking list — **no write actions**. All fulfillment (confirm/reject/upload/schedule edits) stays on the web. Push alerts inform; the lab acts on desktop. |

**Out of scope for v1:** Admin mode (stays web-only). Apple Health / Google Fit sync (backlog).
Any lab write action (backlog — would relax the read-only line).

### Locked decisions (already approved)
1. **Push notifications = core, built early** (Phase 3). Requires backend groundwork in Phase 0.
2. **Lab mode = strictly read-only** in v1.
3. **Platforms = iOS + Android** from day one (single Flutter codebase).

### Open decisions to confirm before coding
- **Refresh tokens vs. long-lived mobile token.** This plan assumes **refresh tokens** (recommended
  for medical data). If the maintainer prefers a simpler long-lived token, see §4.4 for the fallback.

---

## 2. Mobile tech stack (pin these)

Use the latest stable Flutter SDK (≥ 3.24, Dart ≥ 3.5). Package choices:

| Concern | Package | Notes |
|---|---|---|
| State management / DI | `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` | Code-gen providers. |
| Immutable models | `freezed` + `freezed_annotation` + `json_serializable` + `json_annotation` | JSON (de)serialization. |
| Networking | `dio` | Interceptors for auth + error normalization. |
| Routing | `go_router` | Declarative routes + deep links. |
| Secure storage | `flutter_secure_storage` | Tokens in Keychain / Keystore. |
| Local (non-secret) prefs | `shared_preferences` | Locale, onboarding flags. |
| Charts | `fl_chart` | Lab analytics + patient trends. |
| Push | `firebase_core` + `firebase_messaging` | FCM → APNs. |
| Local notifications | `flutter_local_notifications` | Prep reminders + foreground push display. |
| Maps | `google_maps_flutter` + `geolocator` + `permission_handler` | "Labs near me". |
| PDF viewing | `syncfusion_flutter_pdfviewer` (or `pdfx`) | Result PDFs. |
| File cache | `flutter_cache_manager` + `path_provider` | Offline result caching. |
| Biometrics | `local_auth` | FaceID / fingerprint gate. |
| Sharing | `share_plus` | Share result PDF to a doctor. |
| Crash/analytics | `sentry_flutter` (or `firebase_crashlytics`) | Phase 6. |
| Codegen runner | `build_runner` (dev) | For freezed/riverpod/json. |

> Run code generation with `dart run build_runner watch --delete-conflicting-outputs` during dev.

### Directory structure for `apps/mobile/lib`

Feature-first layering. Create this skeleton in Phase 1.

```
lib/
├── main.dart                      # bootstrap (Firebase init, ProviderScope, runApp)
├── app.dart                       # MaterialApp.router, theme, localization wiring
├── core/
│   ├── config/
│   │   └── env.dart               # API_BASE_URL via --dart-define
│   ├── network/
│   │   ├── dio_client.dart        # Dio factory + base options
│   │   ├── auth_interceptor.dart  # injects Bearer, handles 401 → refresh
│   │   └── api_exception.dart     # normalized error type
│   ├── storage/
│   │   └── secure_token_store.dart
│   ├── router/
│   │   └── app_router.dart        # go_router + auth redirect logic
│   ├── theme/
│   │   └── app_theme.dart         # TesTly brand colors, light/dark
│   └── localization/              # ARB files + generated l10n
├── features/
│   ├── auth/                      # login, register, session, biometrics
│   ├── patient/
│   │   ├── labs/                  # browse + map + detail
│   │   ├── booking/               # availability + create + checkout
│   │   ├── bookings/              # my bookings list/detail, cancel, pay, kit tracking
│   │   ├── results/               # list + PDF viewer + share + offline cache
│   │   ├── trends/                # health-profile charts
│   │   └── profile/               # edit profile + privacy
│   ├── lab/
│   │   ├── dashboard/             # KPI home (read-only)
│   │   ├── analytics/             # charts
│   │   ├── reviews/               # read-only reviews
│   │   └── bookings/              # read-only booking list
│   └── notifications/             # device registration, handlers, deep links
└── shared/
    ├── widgets/                   # buttons, cards, empty/error/loading states
    └── models/                    # shared DTOs (enums, pagination)
```

### Architecture rules (follow consistently)

- **Layers per feature:** `data/` (Dio calls + DTO mapping) → `domain/` (models, optional) →
  `application/` (Riverpod providers/notifiers) → `presentation/` (screens + widgets).
- **No business logic in widgets.** Widgets read providers and render. Mutations go through notifiers.
- **All API responses parsed into freezed models.** Never pass raw `Map<String,dynamic>` to the UI.
- **One Dio instance** provided via Riverpod; the auth interceptor is the only place tokens are read.
- **Errors:** every Dio call maps failures to `ApiException { status, message, isAuthError }`.
  Screens render error states from that, never raw exceptions.

---

## 3. API contract reference (authoritative shapes)

These mirror the existing frontend clients. Build Dart freezed models matching them exactly
(camelCase as shown — the backend already returns camelCase for these workspace endpoints).
Source files for verification:
`apps/frontend/src/lib/{patientApi,labApi,publicApi,adminApi,api}.ts`.

### 3.1 Auth
- `POST /auth/login` body: `{ email: string, password: string, selectedRole: "patient"|"lab"|"admin" }`
  - **Currently** returns `{ message, user }` and sets the cookie. **Phase 0 adds** `access_token`
    (+ `refresh_token`) to the body. `user` = `{ id, email, role, lab_onboarding_status }`.
- `POST /auth/register/patient` body: `{ email, password, full_name, phone, address }` → `{ id, email, role, created_at }`.
- `POST /auth/register/lab` body: `{ email, password, lab_name, address, phone?, home_collection?, accreditation?, turnaround_time? }`.
- `GET /auth/me` → `{ id, email, role, lab_profile?: {id, onboarding_status, lab_name}, patient_profile?: {id, full_name} }`.
- `POST /auth/logout` → clears cookie (mobile also discards local tokens).

### 3.2 Public (no auth)
- `GET /public/labs?q&labName&city&sort=price|rating|distance&minRating&maxDistanceKm&maxPriceEgp&homeCollection&accreditations(csv)&userLat&userLng&page&pageSize`
  → `{ items: PublicLabCard[], pagination }`.
  - `PublicLabCard`: `{ id, name, address, city?, phone?, contactEmail?, accreditation?, turnaroundTime?, homeCollection, homeTestKit, rating?, reviews, distanceKm?, testsAvailable, startingFromEgp?, priceForQueryEgp?, imageEmoji? }`.
- `GET /public/labs/:labId?q&category&page&pageSize` → `{ lab, tests[], pagination, reviewItems[] }`.
- `GET /public/tests?q&page&pageSize` → `{ items: PublicTestCard[], pagination }`.
- `GET /public/tests/:labTestId` → `PublicTestResponse` (test + its lab).
- `GET /public/tests/by-name?name&category` → `TestOffersResponse` with `labs: TestOfferLab[]`
  (each has `latitude`/`longitude` — use for map markers).

### 3.3 Patient (auth: Patient)
- `GET /patient/workspace` → `PatientWorkspaceResponse`:
  - `profile: { fullName, phone, address, email, labHistorySharing: "SAME_LAB_ONLY"|"FULL_HISTORY_AUTHORIZED" }`
  - `bookings: { upcoming: PatientWorkspaceBooking[], past: PatientWorkspaceBooking[] }`
  - `results: PatientWorkspaceResult[]`
  - `PatientWorkspaceBooking`: `{ id, status, bookingType, scheduledAt, totalPriceEgp, homeAddress?, paymentMethod, paymentStatus, paymentReference?, paymentPaidAt?, paymentFailedAt?, paymentFailureReason?, kitStatus?, kitTrackingNumber?, kitShippedAt?, kitDeliveredAt?, sampleReceivedAt?, lab: {id,name,address}, test: {id,name,priceEgp}, timeline: [{id,status,note?,createdAt}] }`
  - `PatientWorkspaceResult`: `{ bookingId, bookingStatus, scheduledAt, labName, testName, resultStatus: "Pending"|"Uploaded"|"Delivered", hasStructuredData, structuredObservationCount, file?: {id,fileName,fileUrl,mimeType,sizeBytes,uploadedAt}, summary?: {summary, highlights:{items:[{key,label,value,kind}]}}, review?: {id,rating,comment?,status,createdAt}, canReview }`
- `GET /patient/health-profile?range=3m|6m|12m|all&groupBy=analyte|lab_test` → `PatientHealthProfileResponse`:
  `{ range, groupBy, hasStructuredData, disclaimer, series: HealthProfileSeries[], labTestGroups[], pdfOnlyBookings[] }`.
  - `HealthProfileSeries`: `{ canonicalCode, displayName, chartUnit, category?, labTestName?, trend: {direction, narrative, qualitativeNote?}, points: [{testDate, value, comparable, comparabilityNote?, bookingId, labName, labTestName, refLow?, refHigh?, abnormal?}] }`.
- `PATCH /patient/profile` body: `{ fullName?, phone?, address?, labHistorySharing? }` → updated profile.
- `POST /patient/reviews` body: `{ bookingId, rating, comment? }` → `{ id, rating, comment?, status, createdAt }`.

### 3.4 Bookings (auth: Patient for these)
- `GET /bookings/availability?labId&testId&bookingType=LabVisit|HomeCollection|HomeTestKit`
  → available slots (verify exact shape in `apps/backend/src/bookings/bookings.controller.ts`).
- `POST /bookings` → create booking.
- `GET /bookings/patient` → patient's bookings.
- `PATCH /bookings/:id/patient-cancel` → cancel.
- `POST /bookings/:id/demo-online-payment` → demo payment (success/failure).

> **Before building the booking flow (Phase 2), read `apps/backend/src/bookings/bookings.controller.ts`
> and `bookings.service.ts`** to capture the exact request/response DTOs for availability and create —
> they are not fully reproduced here.

### 3.5 Lab (auth: LabStaff + Active) — READ-ONLY use in mobile
- `GET /lab/workspace` → `LabWorkspaceResponse`:
  - `lab: {id,name,address,homeCollection,homeTestKit}`
  - `bookings[]` (same shape as patient booking + `patient:{id,fullName?,phone?}`)
  - `tests[]`, `schedule[]`
  - `analytics: { totalBookings, completedBookings, pendingResults, revenueEstimateEgp, capacityUsagePercent, topTests: [{testId,testName,count}] }`
- **Mobile uses GET only.** Do **not** call `POST/PATCH/DELETE /lab/*` or booking mutation endpoints.

---

## 4. Phase 0 — Backend prerequisites (DO THIS FIRST)

> All Phase 0 work is in `apps/backend`. It is **additive and non-breaking**: the web app keeps using
> cookies. Mobile uses bearer tokens. Verify the web login/logout still works after each change.

### 4.1 Return tokens in the login response body

**File:** `apps/backend/src/auth/auth.controller.ts` (`login` handler, ~line 63–88).
Keep setting the cookie (web depends on it). Additionally return the token(s) in the JSON body:

```ts
// after generating tokens
response.cookie(AUTH_COOKIE_NAME, access_token, { /* unchanged */ });
return { message: 'Login successful', user: userData, access_token, refresh_token };
```

Do the same consideration for register endpoints if the app should auto-login after registration
(optional; simpler to redirect to login).

### 4.2 Accept a Bearer token, not just the cookie

**File:** `apps/backend/src/auth/strategies/jwt.strategy.ts`.
Extend the extractor list so the JWT can come from **either** the cookie **or** the
`Authorization: Bearer <token>` header:

```ts
super({
  jwtFromRequest: ExtractJwt.fromExtractors([
    (req: Request) => req?.cookies?.[AUTH_COOKIE_NAME],
    ExtractJwt.fromAuthHeaderAsBearerToken(),
  ]),
  ignoreExpiration: false,
  secretOrKey: jwtSecret,
});
```

This is the **single change that unblocks the entire mobile app.** Web is unaffected (cookie extractor
runs first).

### 4.3 Refresh tokens (recommended path)

Mobile sessions should not silently expire after 8h. Add a refresh mechanism.

1. **Prisma:** add a `RefreshToken` model in `apps/backend/prisma/schema.prisma`:
   ```prisma
   model RefreshToken {
     id         String   @id @default(uuid())
     user_id    String
     token_hash String   @unique   // store a hash, never the raw token
     expires_at DateTime
     revoked    Boolean  @default(false)
     created_at DateTime @default(now())
     user       User     @relation(fields: [user_id], references: [id], onDelete: Cascade)
     @@index([user_id])
   }
   ```
   Add the inverse relation field to `User`. Then run a migration:
   `pnpm --filter backend prisma migrate dev --name add_refresh_tokens` (confirm the package manager
   used in the repo — check root `package.json`/lockfile; could be `npm`/`pnpm`/`yarn`).
2. **AuthService:** on login, also issue a refresh token (random opaque string, e.g. 64 bytes hex),
   store its hash + expiry (e.g. 30 days), return the raw token to the client.
3. **New endpoint** `POST /auth/refresh` body `{ refresh_token }` → validates (lookup by hash, not
   revoked, not expired), **rotates** it (revoke old, issue new), returns a fresh `{ access_token, refresh_token }`.
4. **Logout:** `POST /auth/logout` should also accept/revoke the refresh token for mobile.
5. Keep access-token TTL short-ish (e.g. 1h) once refresh exists; mobile silently refreshes on 401.

> **Fallback (no refresh tokens):** if the maintainer rejects refresh tokens for v1, instead issue a
> longer-lived access token for mobile logins (e.g. set `expiresIn: '30d'` when a `client=mobile` flag
> is present on login). Simpler, less secure. Document whichever is chosen here.

### 4.4 Notifications groundwork

1. **Prisma:** add `DeviceToken`:
   ```prisma
   model DeviceToken {
     id         String   @id @default(uuid())
     user_id    String
     fcm_token  String   @unique
     platform   String   // "ios" | "android"
     created_at DateTime @default(now())
     updated_at DateTime @updatedAt
     user       User     @relation(fields: [user_id], references: [id], onDelete: Cascade)
     @@index([user_id])
   }
   ```
2. **Endpoints** (JWT-protected): `POST /notifications/register-device` `{ fcmToken, platform }` (upsert
   by token), `DELETE /notifications/device` (on logout).
3. **NotificationsService** that sends FCM messages. Wire it to the points where booking state already
   changes — the codebase records these in `BookingStatusEvent`. Emit a push when:
   - booking → `Confirmed` or `Rejected` (target: patient)
   - result status → `Delivered` (target: patient)
   - `kitStatus` → `Shipped` (target: patient)
   - a new booking is created (target: that lab's staff)
   - a new review is published (target: that lab's staff)
   - payment marked collected (target: lab staff)
   Find these transitions in `apps/backend/src/bookings/bookings.service.ts`,
   `apps/backend/src/api/lab.controller.ts`/service, and review creation in the patient service.
4. **FCM credentials:** add a Firebase service-account JSON via env/secret; use `firebase-admin` in Nest.
   Do **not** commit credentials. Add to `.env.example`.

### 4.5 CORS / config

- Confirm `apps/backend/src/main.ts` CORS allows the mobile origin. Native apps send no `Origin`
  header, so bearer-token requests are generally unaffected, but verify no global cookie-only
  assumptions break mobile.
- Add `MOBILE_*` / Firebase env vars to `.env.example` and document them.

**Phase 0 acceptance criteria**
- [ ] `POST /auth/login` returns `access_token` (+ `refresh_token` if chosen) in the body **and** web cookie login still works.
- [ ] A request with `Authorization: Bearer <token>` and **no cookie** succeeds on `GET /auth/me` and a patient/lab endpoint.
- [ ] `POST /auth/refresh` rotates tokens (if refresh chosen).
- [ ] `POST /notifications/register-device` stores a token; a booking confirm triggers an FCM send (verify via Firebase console/log).
- [ ] Existing backend tests pass; new tests cover bearer extraction + refresh.

---

## 5. Phase 1 — Flutter foundation & auth

**Goal:** a runnable app on both platforms where a user logs in as patient or lab and lands on the
correct (mostly empty) shell, with secure token handling and biometric unlock.

### Tasks
1. **Scaffold** `apps/mobile` with `flutter create` (org id e.g. `com.testly.app`, platforms ios+android).
   Add all packages from §2. Set up `build_runner`.
2. **Env config** (`core/config/env.dart`): read `API_BASE_URL` from `--dart-define=API_BASE_URL=...`,
   default `http://localhost:3001`. (On Android emulator, localhost is `http://10.0.2.2:3001`; document this.)
3. **Secure token store** (`core/storage/secure_token_store.dart`): get/set/clear access + refresh tokens
   via `flutter_secure_storage`.
4. **Dio client + auth interceptor** (`core/network/`):
   - Base options with `API_BASE_URL`, JSON content type, timeouts.
   - Request interceptor: attach `Authorization: Bearer <accessToken>` if present.
   - Response/error interceptor: on `401`, attempt one `POST /auth/refresh`; on success retry the
     original request; on failure clear tokens and route to login. Map all errors to `ApiException`.
5. **Theme** (`core/theme/app_theme.dart`): port TesTly brand colors from the web app
   (`apps/frontend` Tailwind config / globals). Provide light + dark.
6. **Localization skeleton**: configure `flutter_localizations`, add `l10n.yaml` + `app_en.arb` +
   `app_ar.arb`. **Wire RTL from the start** (`MaterialApp` uses `Directionality` via locale; Arabic →
   RTL automatically). Even if Arabic strings are stubbed, the plumbing must exist now.
7. **Router** (`core/router/app_router.dart`): go_router with redirect logic:
   - unauthenticated → `/login`
   - authenticated Patient → `/patient` shell (bottom nav: Labs, Bookings, Results, Trends, Profile)
   - authenticated LabStaff (Active) → `/lab` shell (bottom nav: Dashboard, Analytics, Reviews, Bookings)
   - LabStaff not Active → a "pending/blocked" screen explaining they must be approved (mirror `LabActiveGuard`).
   - Admin → a "not supported on mobile, use the web" screen.
8. **Auth feature**:
   - `LoginScreen`: email, password, role selector (patient/lab — hide admin or show the "use web" notice). Calls `POST /auth/login`, stores tokens, hydrates session via `GET /auth/me`.
   - `RegisterScreen` (patient + lab variants) calling the register endpoints.
   - `SessionNotifier` (Riverpod): holds `AuthState { user?, status }`; exposes `login/logout/restore`.
     On app start, `restore()` reads stored token and calls `/auth/me`.
9. **Biometric gate** (`local_auth`): after a token exists, require FaceID/fingerprint on cold start
   before showing protected content. Provide a settings toggle (store preference). Graceful fallback
   when biometrics unavailable.

### Acceptance criteria
- [ ] App builds & runs on an iOS simulator and an Android emulator.
- [ ] Logging in as `patient@testly.com` lands on the patient shell; `alborglaboratories@testly.com` lands on the lab shell; `pendinglab@testly.com` shows the pending screen.
- [ ] Killing and reopening the app keeps the session (token restored) and prompts biometrics.
- [ ] A forced token expiry triggers a silent refresh (or clean logout if refresh fails).
- [ ] Switching device language to Arabic flips the UI to RTL.

---

## 6. Phase 2 — Patient core experience

**Goal:** full parity with the website's patient surface, plus the mobile-native polish that doesn't
need push (push is Phase 3).

### 6.1 Browse labs (list + map)
- **List:** `GET /public/labs` with search (`q`/`labName`), city filter, sort, price/rating/distance
  filters, pagination (infinite scroll). Render `PublicLabCard` cards (rating, starting price, services,
  distance when available).
- **Map view:** toggle to `google_maps_flutter`. Get the device location via `geolocator`
  (+ `permission_handler`), pass `userLat`/`userLng` to the API for distance, and drop markers using
  lab coordinates (available on `TestOfferLab` from `/public/tests/by-name`, and you may need to confirm
  lat/long on the labs list — if absent there, fetch detail or extend the public labs endpoint).
- Empty/error/loading states via shared widgets.

### 6.2 Lab detail
- `GET /public/labs/:labId`: header (name, address, accreditation, rating), test catalog (searchable,
  paginated), reviews. CTA → start booking for a chosen test.

### 6.3 Booking flow
- Read `bookings.controller.ts` first (see §3.4 note) to lock DTOs.
- Steps: choose test → choose booking type (LabVisit / HomeCollection / HomeTestKit, gated by the lab's
  `homeCollection`/`homeTestKit`) → `GET /bookings/availability` to pick a slot → enter home address if
  needed → choose payment method (cash variants or demo Online) → `POST /bookings`.
- After creation, if Online: call `POST /bookings/:id/demo-online-payment` and show success/failure.

### 6.4 My Bookings
- `GET /patient/workspace` (`bookings.upcoming`/`past`) or `GET /bookings/patient`.
- Booking detail: status timeline (`timeline[]`), payment status, **kit tracking** for HomeTestKit
  (`kitStatus`, `kitTrackingNumber`, ship/deliver timestamps).
- Actions: `PATCH /bookings/:id/patient-cancel`; retry demo payment when `paymentStatus = Failed`.

### 6.5 Results
- From `workspace.results`: list with status (`Pending|Uploaded|Delivered`), structured-data badge.
- **PDF viewer** for `file.fileUrl` (Authorization header may be required depending on how files are
  served — verify how `ResultFile.file_url` is produced/served in the backend).
- **Offline caching** via `flutter_cache_manager` so opened PDFs are viewable without network.
- **Native share** (`share_plus`) to send the PDF to a doctor.
- **Review** completed bookings (`POST /patient/reviews`) where `canReview`.

### 6.6 Profile & privacy
- `GET` from workspace `profile`; `PATCH /patient/profile` for name/phone/address and the
  `labHistorySharing` privacy toggle (`SAME_LAB_ONLY` ↔ `FULL_HISTORY_AUTHORIZED`) with a clear
  explanation of what sharing enables (cross-lab trends).

### Acceptance criteria
- [ ] A patient can search labs (list + map), open a lab, book a test of each booking type, pay (cash + demo online), and see it in My Bookings with correct status.
- [ ] Kit tracking shows for HomeTestKit bookings.
- [ ] A delivered result opens in the PDF viewer, is viewable offline after first open, and can be shared.
- [ ] Profile edits and the privacy toggle persist (re-fetch confirms).
- [ ] All screens have loading/empty/error states; Arabic renders RTL.

---

## 7. Phase 3 — Push notifications (patient) + prep reminders

**Goal:** patients get timely pushes; tapping one deep-links to the relevant screen. Depends on Phase 0 §4.4.

### Tasks
1. **Firebase setup:** add iOS + Android Firebase apps; place `google-services.json` (Android) and
   `GoogleService-Info.plist` (iOS); configure APNs key in Firebase. `firebase_core` init in `main.dart`.
2. **Permission priming:** request notification permission with a rationale screen (don't cold-prompt).
3. **Device registration:** on login (and token refresh from FCM), call `POST /notifications/register-device`
   `{ fcmToken, platform }`. On logout, `DELETE /notifications/device`.
4. **Foreground handling:** display foreground messages with `flutter_local_notifications`.
5. **Deep links:** notification payload carries `{ type, bookingId }`. Tapping routes via go_router to the
   exact booking/result. Handle cold-start (terminated), background, and foreground cases.
6. **Local prep reminders:** when a booking is confirmed for a test with a non-empty `preparation`
   (from `LabTest.preparation` / test detail), schedule a `flutter_local_notifications` reminder the
   evening before `scheduledAt` (e.g. "Fast for 12h before tomorrow's test"). Cancel if booking cancelled.

### Acceptance criteria
- [ ] Confirming a booking on the web (or via backend) delivers a push to the patient's device; tapping opens that booking.
- [ ] Result-delivered and kit-shipped pushes work and deep-link correctly.
- [ ] A confirmed booking with prep instructions schedules a local reminder; cancelling removes it.
- [ ] Permission flow is polite and re-promptable from settings.

---

## 8. Phase 4 — Patient Health Trends (hero feature)

**Goal:** make the cross-lab longitudinal trends shine natively — this is the app's differentiator.

### Tasks
- `GET /patient/health-profile?range=&groupBy=`. Controls for `range` (3m/6m/12m/all) and `groupBy`
  (analyte / lab_test).
- For each `HealthProfileSeries`, render an `fl_chart` line chart of `points` (x = `testDate`, y = `value`),
  shade the reference band (`refLow`–`refHigh`), mark `abnormal` points, and visually distinguish
  non-`comparable` points (with `comparabilityNote`).
- Show `trend.direction` + `trend.narrative` per marker, the global `disclaimer`, and a section listing
  `pdfOnlyBookings` (results that exist only as PDF, not in trends).
- Empty state when `hasStructuredData = false`, explaining how trends populate (share preference + structured results).

### Acceptance criteria
- [ ] Trends render for `patient@testly.com` across the seeded labs; ranges and groupings switch correctly.
- [ ] Reference bands, abnormal markers, and comparability notes are visible and correct.
- [ ] Disclaimer always shown; empty state appears when there's no structured data.

---

## 9. Phase 5 — Lab mode (strictly read-only)

**Goal:** a glanceable analytics/monitoring app for lab owners. **No write calls whatsoever.**

### Tasks
- **KPI home dashboard** from `GET /lab/workspace` `analytics`: cards for `totalBookings`,
  `completedBookings`, `pendingResults`, `revenueEstimateEgp`, `capacityUsagePercent`, plus a "today"
  derived count from `bookings[]`.
- **Analytics charts** (`fl_chart`): bookings over time (derive from `bookings[].scheduledAt`), revenue by
  payment method (group `bookings[]` by `paymentMethod`/`paymentStatus`), kit pipeline (group by
  `kitStatus`), top tests (`analytics.topTests`).
- **Reviews:** read-only list (fetch via lab workspace or a reviews endpoint — confirm where lab reviews
  are exposed; `LabWorkspaceResponse` may not include them, in which case use the public lab detail
  `reviewItems` for the lab's own id, or add a read endpoint).
- **Bookings list (read-only):** show `bookings[]` with patient name/phone, test, status, payment — but
  **no buttons** to confirm/reject/collect. Add an explicit "Manage on web" note where actions would be.
- **Lab push alerts** (depends on Phase 0 §4.4): new booking, new review, cash collected. Tapping opens
  the relevant read-only screen.

### Guardrails
- The lab Dio layer must expose **only GET** methods. Do not implement any `POST/PATCH/DELETE /lab/*`
  or booking-mutation client methods in mobile. Add a code comment stating this is intentional (v1 read-only).

### Acceptance criteria
- [ ] `alborglaboratories@testly.com` sees KPIs, charts, reviews, and a read-only booking list — with zero action buttons.
- [ ] No mobile code path can mutate lab data (grep confirms no lab write calls).
- [ ] Lab push alerts deliver and deep-link to the read-only screens.

---

## 10. Phase 6 — Hardening & release

- Comprehensive empty/error/offline states; retry affordances; skeleton loaders.
- Accessibility: text scaling, contrast, semantics labels; full RTL QA with real Arabic strings.
- Deep-link QA across cold/background/foreground.
- Crash + analytics (`sentry_flutter` or Crashlytics).
- App icons, splash, store screenshots; privacy nutrition labels / data-safety form (health data
  disclosures). iOS background modes / push entitlements; Android `POST_NOTIFICATIONS` permission (API 33+).
- Build flavors: `dev` (localhost / 10.0.2.2) vs `prod` (real API URL) via `--dart-define`.
- Submit to TestFlight + Play Internal testing.

### Acceptance criteria
- [ ] Release builds for both stores pass internal testing.
- [ ] No PII logged; crash reporting scrubs sensitive data.
- [ ] Privacy disclosures completed and accurate.

---

## 11. Sequencing & dependencies

```
Phase 0 (backend) ──┬─> Phase 1 (foundation+auth) ──┬─> Phase 2 (patient core) ─> Phase 4 (trends)
                    │                                ├─> Phase 5 (lab read-only)
                    └─(notifications groundwork)─────┴─> Phase 3 (push)  ──────────> Phase 6 (release)
```

- **Phase 0 blocks everything.** Do not start Flutter API integration until §4.1–4.2 are merged.
- After Phase 1, **Phase 2 and Phase 5 are independent** and can be built in parallel by separate agents.
- Phase 3 needs Phase 0 §4.4 done.
- Recommended order: **0 → 1 → 2 → 3 → 4 → 5 → 6**, pulling Phase 5 earlier if a lab-facing demo is needed sooner.

## 12. Cross-cutting conventions (apply in every phase)

- **Never store tokens in plain `shared_preferences`** — only `flutter_secure_storage`.
- **All money** is `priceEgp`/`totalPriceEgp` integers in EGP — format with an Arabic/English-aware currency formatter.
- **All dates** from the API are ISO strings — parse to `DateTime` and display localized.
- **Enums** (status, bookingType, paymentMethod, kitStatus, resultStatus, role, onboarding status) →
  Dart enums with `@JsonValue` mapping; never compare raw strings in the UI.
- **Verify before assuming a contract** that isn't reproduced verbatim here — open the corresponding
  backend controller/service. The frontend clients in `apps/frontend/src/lib/*.ts` are the most reliable
  mirror of response shapes.
- **Keep the read-only invariant for lab mode** mechanically enforceable (no write client methods exist).
```
