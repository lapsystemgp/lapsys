# TesTly Mobile Application (Flutter)

This chapter documents the **TesTly mobile client** — the native Flutter
application that lives in `apps/mobile`. It is one of two front-ends in the
TesTly platform (the other being a Next.js web app in `apps/frontend`), and it
talks to the same NestJS backend over HTTP. The app serves **patients** and
**lab staff**; the admin console is web-only by design.

The codebase is written in Dart with a **feature-first, clean-architecture**
layout, **Riverpod** for state management and dependency injection, **Dio** for
networking, **go_router** for navigation, and **Firebase Cloud Messaging** for
push. It ships with full **English/Arabic localization** (including RTL) and a
**light/dark theme**.

> Source of truth for the dependency set: `apps/mobile/pubspec.yaml`.

---

## Project Layout & Conventions

The `lib/` tree is split into three top-level concerns:

```
lib/
  main.dart                 ← entry point: Firebase init + boot sequence
  app.dart                  ← root MaterialApp.router widget
  core/                     ← cross-cutting infrastructure (no business logic)
    config/    env.dart                 (compile-time config via --dart-define)
    network/   dio_client.dart, auth_interceptor.dart, api_exception.dart
    storage/   secure_token_store.dart  (Keychain/Keystore wrapper)
    router/    app_router.dart          (go_router + auth/role redirects)
    theme/     app_theme.dart, theme_controller.dart
    locale/    locale_controller.dart
    location/  location_service.dart    (geolocator + haversine)
  features/                 ← one folder per business capability
    auth/  lab/  notifications/
    patient/  (home, labs, booking, bookings, results, trends, profile,
               assistant, workspace, presentation)
  shared/                   ← reusable models & widgets
    models/    pagination.dart
    widgets/   animations, empty_state, error_state/view, list_skeleton, loading…
  l10n/                     ← generated localization classes + ARB sources
```

Within each feature the **clean-architecture three-layer split** is applied
consistently:

| Folder | Layer | Responsibility |
|---|---|---|
| `presentation/` | UI | Flutter widgets / screens; reads providers, never touches Dio directly |
| `application/` | State | Riverpod `Notifier`/`StateNotifier` + derived providers; orchestration |
| `data/` | Data | Repositories (Dio clients) + immutable `freezed` models with JSON mapping |

Immutable models are generated with **`freezed`** + **`json_serializable`**
(the `*.freezed.dart` and `*.g.dart` files are build artifacts checked into the
tree). Models map the backend's `snake_case` JSON to Dart `camelCase` using
`@JsonKey(name: …)`, and Prisma enums to Dart enums using `@JsonValue('…')`
(e.g. `auth/data/auth_models.dart`, `booking/data/booking_models.dart`).

---

## Application Bootstrap

### `lib/main.dart`
`main()` is asynchronous and runs four steps before the UI shows:

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `Firebase.initializeApp()` **wrapped in try/catch** — if Firebase config is
   missing the app degrades gracefully (push disabled) rather than crashing.
   This is a deliberate design choice so the app runs out-of-the-box without
   real Firebase credentials.
3. Registers the top-level background FCM handler
   `_fcmBackgroundHandler` (annotated `@pragma('vm:entry-point')`, required by
   the plugin because it executes in a separate isolate).
4. `runApp(ProviderScope(child: _AppBoot()))` — the `ProviderScope` is the
   Riverpod root container.

`_AppBoot` is a `ConsumerStatefulWidget` that, in `initState`, schedules a
microtask to: (a) `notificationServiceProvider.initialize()` (FCM listeners +
local-notification channels + cold-start deep-link capture), then (b)
`sessionNotifierProvider.notifier.restore()` (validate stored tokens against
`/auth/me`). It then renders `App`.

### `lib/app.dart`
`App` is a `ConsumerWidget` that watches three providers and feeds them into a
single `MaterialApp.router`:

- `appRouterProvider` → `routerConfig`
- `localeControllerProvider` → `locale`
- `themeControllerProvider` → `themeMode`

It wires `AppTheme.light`/`AppTheme.dark`, the four
`localizationsDelegates` (app + Material/Widgets/Cupertino globals), and
declares `supportedLocales` `en` and `ar`. App title is `TesTly`.

---

## (c) Clean Architecture & Riverpod State Management

The app uses Riverpod end-to-end. Three provider patterns recur:

**1. Singletons / DI (`Provider`).** Infrastructure and repositories are exposed
as plain providers so they can be injected and overridden in tests:
`secureTokenStoreProvider`, `dioClientProvider`, `authRepositoryProvider`,
`publicRepositoryProvider`, `bookingRepositoryProvider`, `patientRepositoryProvider`,
`labRepositoryProvider`, `chatRepositoryProvider`, `notificationServiceProvider`,
`locationServiceProvider`. Every repository's constructor takes the shared `Dio`
via `ref.watch(dioClientProvider)`, so the auth interceptor is applied uniformly.

**2. Async data (`FutureProvider` / `FutureProvider.family`).** Read-only server
state is fetched and cached by Riverpod:
- `workspaceProvider` (`FutureProvider<PatientWorkspaceResponse>`) — the single
  source of truth for the patient: bookings, results and profile in one call.
  Tabs read **derived selectors** (`upcomingBookingsProvider`,
  `pastBookingsProvider`, `resultsProvider`, `workspaceProfileProvider`) that
  each slice the workspace with `.whenData(...)` so a tab only rebuilds when its
  slice changes.
- `labsListProvider`, `labDetailProvider`, `testsListProvider`,
  `testOffersProvider` are `family` providers keyed by their filter/id, giving
  per-query caching.
- `healthProfileProvider` is `FutureProvider.autoDispose.family` (disposed when
  the Trends screen leaves the tree).
- `labWorkspaceProvider` mirrors the patient pattern for lab staff, with derived
  selectors (`labInfoProvider`, `pendingBookingsProvider`, `confirmedBookingsProvider`,
  `labAnalyticsProvider`, …).

  Refresh is uniformly implemented as `ref.invalidate(provider)` wired to
  `RefreshIndicator` and retry buttons.

**3. Mutable flows (`Notifier` / `StateNotifier` / `FamilyNotifier`).** Stateful
orchestration lives in `application/`:
- `SessionNotifier` (`NotifierProvider`) holds `SessionState` (status enum +
  `AuthUser`) and drives auth.
- `BookingFlowNotifier` (`NotifierProvider.family`) is the multi-step booking
  wizard's state machine.
- `ChatNotifier` (`NotifierProvider`) manages the streaming AI chat.
- `ThemeController` / `LocaleController` are `StateNotifier`s persisting to
  `SharedPreferences`.

State objects are either `freezed` immutables (`SessionState`) or hand-written
immutable classes with `copyWith` (`BookingFlowState`, `ChatState` — the latter
uses a `_sentinel` trick so `copyWith(error: null)` can distinguish "clear" from
"unchanged").

The clean separation pays off: presentation widgets only ever depend on
providers and `freezed` models; they never construct a `Dio` request. This makes
the data layer swappable and the UI testable with provider overrides
(`mocktail` is in dev-dependencies for this purpose).

---

## Core Infrastructure (`lib/core`)

### Configuration — `core/config/env.dart`
`Env` reads compile-time constants via `String.fromEnvironment` (`--dart-define`):
- `API_BASE_URL`, defaulting to the deployed Railway backend
  (`https://testly-backend-production-c28a.up.railway.app`) so the app works on
  real devices without setup. Doc comments give the override commands for iOS
  simulator (`localhost`), Android emulator (`10.0.2.2`) and physical devices
  (LAN IP).
- `GOOGLE_MAPS_API_KEY` (empty default).

### Networking — `core/network/`
- **`dio_client.dart`** builds the single shared `Dio` with `baseUrl = Env.apiBaseUrl`,
  a 10 s connect / 30 s receive timeout, and a JSON content-type. It attaches one
  `AuthInterceptor`. `secureTokenStoreProvider` wraps `FlutterSecureStorage`,
  configured with `AndroidOptions(encryptedSharedPreferences: true)`.
- **`auth_interceptor.dart`** is a `QueuedInterceptor` (so concurrent 401s don't
  all race to refresh). `onRequest` attaches `Authorization: Bearer <access>`.
  `onError` implements **silent token rotation**: on a 401 it reads the refresh
  token, calls `POST /auth/refresh` on a *fresh* Dio (to avoid recursing through
  the interceptor), persists the new pair, then **retries the original request**
  via `dio.fetch` and `handler.resolve`. If refresh fails or no refresh token
  exists, it clears tokens so the session collapses to "unauthenticated".
- **`api_exception.dart`** is the app's normalized error type. `fromDioException`
  extracts the backend's `message` field (or Dio's message), the status code,
  and an `isAuthError` flag for 401s. Every repository catches `DioException` and
  rethrows `ApiException`, giving the UI a single error contract.

### Secure Token Storage — `core/storage/secure_token_store.dart`
`SecureTokenStore` persists `access_token` and `refresh_token` in
`flutter_secure_storage`, which maps to the **iOS Keychain** and the **Android
Keystore-backed EncryptedSharedPreferences**. It exposes `getAccessToken`,
`getRefreshToken`, `saveTokens`, `saveAccessToken`, `clearTokens`. This is the
only place credentials are stored; tokens never touch `SharedPreferences`.

### Location — `core/location/location_service.dart`
`LocationService.getCurrentLocation()` runs the full permission dance via
**`geolocator`**: checks the service is enabled, checks/requests permission, and
returns a `LatLng` or **`null`** (rather than throwing) when denied, timed-out,
or unavailable, so callers can fall back to a non-distance sort. Accuracy is set
to `low` with a 27 s time limit. `currentLocationProvider` (a `FutureProvider`)
resolves the fix **once per session and caches it**, so multiple screens don't
re-prompt. `haversineKm(...)` computes great-circle distance rounded to one
decimal, **matching the web frontend's `haversineKm` exactly** so both clients
show identical numbers.

### Theming & Dark Mode — `core/theme/`
- **`app_theme.dart`** defines `AppColors` (the brand palette ported from the
  web app's `globals.css`: brand `#2563EB`, neutrals, semantic colours, a 4-colour
  chart palette, and dark-mode equivalents) and two Material 3 `ThemeData`
  objects (`light`, `dark`) built from `ColorScheme.fromSeed(seedColor: brand)`.
  Both themes style app bars, bottom nav, buttons (48 px full-width default),
  inputs (filled, 10 px radius), and cards (12 px radius, subtle border).
- **`theme_controller.dart`** — `ThemeController` (`StateNotifier<ThemeMode>`),
  defaulting to `ThemeMode.system`, persisting the choice to `SharedPreferences`
  under `theme_mode`. The user picks System/Light/Dark in the profile screen.

### Localization — `core/locale/` + `lib/l10n/`
- **`locale_controller.dart`** — `LocaleController` (`StateNotifier<Locale?>`).
  A `null` state means "follow the device language". The choice is persisted to
  `SharedPreferences` under `locale_code`.
- Localization is generated by Flutter's `gen-l10n` tool. `l10n.yaml` points at
  `lib/l10n/app_en.arb` (template) + `app_ar.arb`, producing
  `AppLocalizations`, `AppLocalizations_en`, `AppLocalizations_ar`.
  **Both ARB files carry 330 keys each** (full English + Arabic parity).
  Arabic gives the app RTL support automatically via
  `GlobalWidgetsLocalizations`. Strings include ICU plurals/placeholders
  (e.g. `labCount`, `startingFromEgp`, `homeGreeting(name)`).

---

## (a) Feature-by-Feature Breakdown

### Routing — `core/router/app_router.dart`

Navigation uses **go_router**. `appRouterProvider` builds a `GoRouter` with
`initialLocation = /login`. A `Routes` constant class names every path.

**Auth + role redirect.** The central `redirect` callback is the app's gatekeeper:
- It first consumes any **pending notification deep-link** (see Notifications)
  if the user is authenticated.
- While the session is `initial`/`loading`, it returns `null` (no redirect),
  showing whatever screen is mounted.
- When `unauthenticated`, anything other than the login/register screens is
  redirected to `/login`.
- When authenticated, it **routes by role**:
  - `admin` → `/admin-unsupported` (mobile shows a "use the web" screen).
  - `labStaff` → `/lab-pending` unless `labProfile.onboardingStatus == active`,
    otherwise the lab shell.
  - `patient` → the patient shell.

`refreshListenable` is a `_RouterListenable` that fires on **both** session
changes and incoming notification routes, so the redirect re-evaluates at the
right moments.

**Route structure.** Two `ShellRoute`s provide the bottom-nav scaffolds:
- **Patient shell** (`PatientShell`) wraps Home (`/patient` + nested `search`,
  `labs/:labId`, `tests/:testName`), Bookings (`/patient/bookings/:bookingId`),
  Results (`/patient/results/:bookingId`), Trends, Profile.
- **Lab shell** (`LabShell`) wraps Dashboard (`/lab`), Analytics, Reviews,
  Bookings (`/lab/bookings/:bookingId`).

Two full-screen routes live **outside** the shells: the **booking flow**
(`/patient/book`, receiving `BookingFlowParams` via `state.extra`) and the **AI
assistant** (`/patient/assistant`). Detail screens receive a pre-fetched object
via `extra` so they render instantly, then reconcile with fresh workspace data.

### Auth — `features/auth`

**Data (`auth_models.dart`).** `freezed` models map the backend: `UserRole`
(`Patient`/`LabStaff`/`Admin`), `LabOnboardingStatus`, `LabProfile`,
`PatientProfile`, `AuthUser`, `LoginResponse`. `AuthRepository`
(`auth_repository.dart`) wraps the endpoints:
`POST /auth/login` (sends `email`, `password`, `selectedRole`; maps `access_token`/
`refresh_token` + nested `user`), `GET /auth/me`, `POST /auth/logout`,
`POST /auth/register/patient`, `POST /auth/register/lab`.

**Application.**
- `SessionNotifier` (`session_notifier.dart`) is the auth brain. `restore()`
  reads the stored access token and validates it via `/auth/me`; `login()`
  authenticates, persists tokens, re-hydrates the user via `/auth/me` (to capture
  `lab_profile`), and **registers the device for push** (`registerDeviceForUser`).
  `logout()` unregisters the device, best-effort calls `/auth/logout`, then clears
  tokens and resets state. `SessionState` is a `freezed` model
  (`status`, `user`, `error`).
- `BiometricService` (`biometric_service.dart`) wraps **`local_auth`**. It stores
  a `biometric_enabled` flag (default on) in `SharedPreferences`, checks
  `canCheckBiometrics && isDeviceSupported`, and `authenticate()` returns `true`
  when biometrics are disabled/unavailable (fail-open) so the gate never locks a
  user out of a device that can't do biometrics. Exposed via a nullable provider
  that waits for `SharedPreferences` to load.

**Presentation.**
- `LoginScreen` — role-toggle `SegmentedButton` (Patient/Lab), email/password
  with validation, animated entrance (`FadeSlideIn`), error surfacing, link to
  register.
- `RegisterScreen` — one screen with a `RegisterMode` (patient vs lab); patient
  requires name/phone/address, lab requires name/address with optional phone.
- `BiometricGate` — wraps a child and prompts Face ID / fingerprint on cold
  start; shows a retry button if it fails.
- `LabPendingScreen` and `AdminUnsupportedScreen` — terminal states with a logout
  button.

### Patient: Home — `features/patient/home`

`HomeScreen` (`ConsumerWidget`) is a native landing page mirroring the web
LandingPage: a gradient **hero** greeting the user by first name (from
`workspaceProfileProvider`), a tappable search field, "browse by"
chips (Nearest → `sort=distance`, Best price → `sort=price`, Top rated →
`sort=rating`), **popular searches** chips (CBC, Lipid Profile, Thyroid Panel,
HbA1c), a horizontally-scrolling **featured labs** carousel
(`labsListProvider(LabsFilter(sort: 'rating'))`, first card badged "Top rated"),
a "Why choose TesTly" feature grid, and a "How it works" 4-step walkthrough.
Pull-to-refresh invalidates the featured-labs provider. A `FloatingActionButton`
in the shell opens the AI assistant.

### Patient: Labs & Tests — `features/patient/labs`

**Data (`lab_models.dart`).** `PublicLabCard`, `PublicLabTest`, `PublicReview`,
`PublicLabDetailResponse`, plus the **Tests** models (`PublicTestCard`,
`PublicTestListResponse`) and **Test offers** models (`TestOfferLab` with
lat/long, `TestOffersResponse`). `LabsFilter` is a `freezed` value used as a
`FutureProvider.family` key (query, city, sort, max price, home-collection flag,
page, user lat/lng). `PublicRepository` wraps `GET /public/labs`,
`GET /public/tests`, `GET /public/tests/by-name`, `GET /public/labs/:id`.

**Presentation.**
- `LabsScreen` — a `TabController` with two tabs: **Tests** (search medical tests
  via `testsListProvider`) and **Labs** (search facilities via `labsListProvider`,
  injecting the cached `currentLocationProvider` so the backend can return
  `distanceKm` and honour the Nearest sort). A shared `_searchQueryProvider`
  feeds both tabs; a filter bottom-sheet sets sort + home-collection-only. Tapping
  a test row opens `TestDetailScreen`; tapping a lab opens `LabDetailScreen`.
- `LabDetailScreen` — a `NestedScrollView` with a collapsing `SliverAppBar`
  (emoji hero), info chips (rating, accreditation, home collection), and a pinned
  two-tab bar (Tests / Reviews). Each test tile has a **Book** button that pushes
  the booking flow with a fully-populated `BookingFlowParams`.
- `TestDetailScreen` — the mobile twin of the web test-detail "nearest labs" view.
  It resolves the user's location, computes **client-side haversine distance** for
  each offering lab (using the lat/lng in `TestOfferLab`), and sorts by
  nearest/price/rating (defaulting to nearest once a fix exists). When no location
  is available it shows an "enable location for distance sort" prompt with retry.

### Patient: Booking flow — `features/patient/booking`

**Data (`booking_models.dart`).** Enums for `BookingType`
(LabVisit/HomeCollection/HomeTestKit), `BookingStatus`, `PaymentMethod`,
`PaymentStatus`, `KitStatus`; slot/availability models; `BookingItem` (full
booking with payment + kit fields + timeline); and `BookingFlowParams` (carried
into the flow). `BookingRepository` wraps `GET /bookings/availability`,
`POST /bookings`, `POST /bookings/:id/demo-online-payment`, `GET /bookings/patient`,
`PATCH /bookings/:id/patient-cancel`. It manually serializes the enum names to the
backend's PascalCase strings.

**Application (`booking_flow_notifier.dart`).** `BookingFlowNotifier`
(`FamilyNotifier`) is a **step state-machine** (`BookingStep`: type → slot →
address → payment → confirm → submitting → done/error). `selectType` fetches 7
days of availability; `selectSlot` branches to the address step only for
home-based types; `confirm()` creates the booking and, for `Online` payment,
chains the demo payment call. On success it **schedules a local prep reminder**
(if the test has preparation text) via the notification service.

**Presentation (`booking_flow_screen.dart`).** A single screen that renders the
current step with a `switch`: type cards, slot list, an address form (home types
only), payment options (online demo + cash variant matched to the booking type),
a confirmation summary, and done/error states. Step-aware back button drives
`notifier.back()`.

### Patient: Bookings list/detail — `features/patient/bookings`

- `MyBookingsScreen` — Upcoming/Past `SegmentedButton`, reading the derived
  `upcomingBookingsProvider`/`pastBookingsProvider`; cards show test, lab, date,
  price and a colour-coded `_StatusBadge`.
- `BookingDetailScreen` — reconciles its `extra` seed with the freshest copy from
  `workspaceProvider`. Shows an info card, a **kit-tracking stepper** (4 stages,
  only for kit bookings), a status **timeline**, a **Cancel** action (pending/
  confirmed), and a **Retry payment** action (failed payments → demo payment).

### Patient: Results — `features/patient/results`

- `ResultsScreen` — lists `WorkspaceResult`s (from `resultsProvider`), badged by
  `ResultStatus` and flagged when structured data / a PDF is attached.
- `ResultDetailScreen` — the richest screen. Shows a header, an optional AI
  **summary card** (narrative + highlight rows), a PDF card, and a review section.
  - **PDF viewing**: `_PdfViewer` downloads the protected file **through the
    authenticated Dio client** (`responseType: bytes`, so the Bearer token is
    attached) and renders it in a bottom sheet with **`pdfx`**.
  - **Sharing**: `_share` downloads the bytes, writes them to a temp file
    (`path_provider`), and invokes the native share sheet via **`share_plus`**.
  - **Reviews**: a star-rating dialog posts to `/patient/reviews` and invalidates
    the workspace.

### Patient: Health Trends — `features/patient/trends`

**Data (`health_profile_models.dart`).** `HealthProfileResponse` carries
`series` (per-analyte), `labTestGroups` (grouped by lab test), `pdfOnlyBookings`,
`hasStructuredData`, and a `disclaimer`. Each `HealthSeries` has a canonical
code, display name, unit, a `HealthTrend` (direction + narrative), and
`HealthPoint`s (value, date, ref range, abnormal flag, comparability note).
Fetched via `PatientRepository.getHealthProfile(range, groupBy)` →
`GET /patient/health-profile`. `healthProfileProvider` is `autoDispose.family`
keyed by `(range, groupBy)`.

**Presentation (`trends_screen.dart`).** Filter row with range chips (3m/6m/12m/
all) and a group-by `SegmentedButton` (By analyte / By test). For each series it
renders a card with the trend badge (rising/falling/stable), narrative, an
optional qualitative caveat, and — when ≥2 points exist — a **`fl_chart`
`LineChart`**. The chart is heavily customised: curved line for >3 points, dots
coloured **red when the reading is abnormal**, dashed green/orange reference
lines for the low/high bounds (labelled "Low"/"High"), date axis labels, a
themed tooltip, and a "recent readings" table with `[low – high]` ranges and
warning icons. Single-point series get a compact value display. A `_PdfOnlySection`
lists results that have no structured data, and the medical disclaimer is shown
in italics at the bottom.

### Patient: Profile — `features/patient/profile`

`ProfileScreen` reads `workspaceProfileProvider`. The form edits name/phone/address
and a **privacy toggle** (`labHistorySharing`: same-lab-only vs full-history-
authorized — controls cross-lab trend aggregation), then `PATCH /patient/profile`.
It also surfaces app settings: a **biometric unlock switch** (only when the device
supports it), a **language selector** (System/English/Arabic via `RadioGroup`),
a **theme selector** (System/Light/Dark), and **Sign out** (`SessionNotifier.logout`).

### Patient: AI Assistant — `features/patient/assistant`

**Data (`chat_models.dart`, `chat_repository.dart`).** Models for conversations
and messages, plus **agentic tool results**: `ToolResult` (discriminated by
`tool`: `find_labs` → `AssistantLabCard`s, `search_tests` → `AssistantTestCard`s).
`ChatRepository.sendMessage` posts to `/chat/messages` with
`responseType: stream` + `Accept: text/event-stream` and **parses Server-Sent
Events by hand** — buffering chunks, splitting on blank lines, concatenating
`data:` lines, and `jsonDecode`-ing each event (`meta`/`delta`/`tool`/`done`/
`error`). Receive timeout is bumped to 2 minutes for long model replies. It also
wraps `GET /chat/conversations` and `…/messages`.

**Application (`chat_notifier.dart`).** `ChatNotifier` appends an optimistic user
bubble + a streaming placeholder, subscribes to the SSE stream, and incrementally
mutates the message list: `delta` appends text, `tool` appends a card group,
`done` clears the streaming flag, `error`/`onError` surface a message and drop the
empty placeholder. `startNewChat` cancels the subscription and resets.

**Presentation (`assistant_screen.dart`).** A chat UI with user/assistant bubbles,
a three-dot **typing indicator** while a reply streams, inline **lab/test cards**
(tappable, deep-linking into `/patient/labs/:id` or `/patient/tests/:name`), an
empty state with suggestion chips, a multiline composer (disabled while streaming),
and a medical disclaimer. It auto-scrolls to the bottom as content streams and
shows errors via a `SnackBar`. A brightness-aware palette extension picks the
right surface/foreground colours because the screen draws its own bubbles.

### Patient: Workspace — `features/patient/workspace`

The "workspace" is the aggregation layer for the patient. `PatientRepository`
(`patient_repository.dart`) wraps `GET /patient/workspace` (returns profile +
bookings split into upcoming/past + results in one call), `PATCH /patient/profile`,
`POST /patient/reviews`, and `GET /patient/health-profile`. `workspace_models.dart`
defines the full response graph (`WorkspaceBooking`, `WorkspaceResult` with
optional `ResultFile`/`ResultSummary`/review, `WorkspaceProfile`,
`LabHistorySharing`). The `application/workspace_provider.dart` exposes
`workspaceProvider` + four derived selectors so each tab subscribes to just its
slice.

### Lab Staff — `features/lab`

**Data.** `lab_workspace_models.dart` models the lab's world: `LabInfo`,
`LabBookingItem` (includes patient contact, slot, timeline), `LabTest`,
`LabScheduleSlot`, and `LabAnalytics` (totals, completed, pending results, revenue
estimate, capacity %, top tests). `LabRepository` wraps a large surface:
`GET /lab/workspace`, `PATCH /lab/profile` (home-collection/kit capabilities),
CRUD on `/lab/tests` and `/lab/schedule`, `PATCH /bookings/:id/lab-status`
(confirm/reject), `PATCH /bookings/:id/kit-status` (+ tracking number),
`PATCH /lab/results/:id/status`.

**Application.** `labWorkspaceProvider` + derived selectors
(`labInfoProvider`, `pendingBookingsProvider`, `confirmedBookingsProvider`,
`labTestsProvider`, `labScheduleProvider`, `labAnalyticsProvider`).

**Presentation.**
- `LabShell` — bottom nav (Dashboard / Analytics / Reviews / Bookings).
- `DashboardScreen` — lab header, an animated stats grid (`CountUpText`-style),
  a capacity `AnimatedProgressBar`, a pending-bookings alert, and a **capabilities**
  editor (home-collection / home-test-kit switches → `PATCH /lab/profile`).
- `AnalyticsScreen` — metric cards (total/completed/pending/revenue) and top tests.
- `ReviewsScreen` — reuses the **public** `labDetailProvider` to show the lab's
  own reviews.
- `LabBookingsScreen` — 3 tabs (Pending / Confirmed / All).
- `LabBookingDetailScreen` — confirm/reject actions, and a **kit-status advancer**
  that walks AwaitingShipment → Shipped (prompts for tracking number) → Delivered
  → SampleReceived, plus marking results delivered.

### Notifications — `features/notifications`

`NotificationService` (`notification_service.dart`) is the push/local-notification
hub (see Platform Integrations). `NotificationRepository`
(`notification_repository.dart`) registers/removes the device token via
`POST /notifications/device` and `DELETE /notifications/device` (body:
`fcm_token`, `platform`).

---

## (b) Screen Catalogue

| Route | Screen widget | Role | Purpose |
|---|---|---|---|
| `/login` | `LoginScreen` | public | Email/password login with role toggle |
| `/register/patient` | `RegisterScreen(patient)` | public | Patient sign-up |
| `/register/lab` | `RegisterScreen(lab)` | public | Lab sign-up |
| `/lab-pending` | `LabPendingScreen` | lab | Onboarding-not-active gate |
| `/admin-unsupported` | `AdminUnsupportedScreen` | admin | "Use the web app" |
| `/patient` | `HomeScreen` (in `PatientShell`) | patient | Landing / search / featured labs |
| `/patient/search` | `LabsScreen` | patient | Tests & Labs search tabs |
| `/patient/labs/:labId` | `LabDetailScreen` | patient | Lab profile, tests, reviews |
| `/patient/tests/:testName` | `TestDetailScreen` | patient | Labs offering a test, by distance |
| `/patient/book` | `BookingFlowScreen` | patient | Multi-step booking wizard |
| `/patient/bookings` | `MyBookingsScreen` | patient | Upcoming/Past bookings |
| `/patient/bookings/:id` | `BookingDetailScreen` | patient | Booking detail + kit tracking + cancel/pay |
| `/patient/results` | `ResultsScreen` | patient | Results list |
| `/patient/results/:id` | `ResultDetailScreen` | patient | Summary, PDF viewer, share, review |
| `/patient/trends` | `TrendsScreen` | patient | Health-trend charts (fl_chart) |
| `/patient/profile` | `ProfileScreen` | patient | Profile + privacy + app settings |
| `/patient/assistant` | `AssistantScreen` | patient | Streaming AI health assistant |
| `/lab` | `DashboardScreen` (in `LabShell`) | lab | KPIs + capabilities editor |
| `/lab/analytics` | `AnalyticsScreen` | lab | Metrics + top tests |
| `/lab/reviews` | `ReviewsScreen` | lab | Lab's own reviews |
| `/lab/bookings` | `LabBookingsScreen` | lab | Pending/Confirmed/All bookings |
| `/lab/bookings/:id` | `LabBookingDetailScreen` | lab | Confirm/reject, kit status, results |

Shared UI primitives in `shared/widgets`: `FadeSlideIn`, `PressableCard`,
`CountUpText`, `AnimatedProgressBar`, `ShimmerBox` (motion toolkit honouring the
OS "reduce motion" setting), plus `EmptyState`, `ErrorState`/`ErrorView`,
`CardListSkeleton`, `LoadingIndicator`/`LoadingView`.

---

## (d) Platform Integrations

### Auth token storage in Keychain / Keystore
Access + refresh tokens are stored exclusively in `flutter_secure_storage`
(`SecureTokenStore`) → iOS Keychain and Android Keystore-encrypted
SharedPreferences (`encryptedSharedPreferences: true`). The auth interceptor
reads/writes them; the rest of the app never sees raw tokens.

### Push notifications (FCM) — setup & permission flow
- **Plugins**: `firebase_core`, `firebase_messaging`, `flutter_local_notifications`,
  `timezone`. Native side: `android/app/google-services.json` and
  `ios/Runner/GoogleService-Info.plist` are present; the Android Gradle config
  applies `com.google.gms.google-services` (declared in `settings.gradle.kts`,
  applied in `app/build.gradle.kts`). The iOS `AppDelegate` registers the
  generated plugin registry.
- **Initialization** (`NotificationService.initialize`): initialize timezones,
  create two Android channels (`testly_general`, `testly_reminders`), wire FCM
  listeners — `onMessage` (foreground), `onMessageOpenedApp` (background tap),
  `getInitialMessage` (terminated-state tap), and `onTokenRefresh`. On iOS it
  suppresses native foreground banners (the app shows its own via
  `flutter_local_notifications`).
- **Foreground display**: incoming foreground pushes are re-shown as local
  notifications carrying a deep-link payload.
- **Deep-linking**: `_payloadToRoute` maps `{type: 'booking'|'result', id}` to
  `/patient/bookings/:id` or `/patient/results/:id`. A tap navigates via the
  router; if the router isn't mounted yet (cold start), the route is stashed in
  `pendingNotificationRouteProvider` and consumed by the router `redirect`
  (only when authenticated).
- **Permission flow** is *deferred and rationale-first*: rather than prompting at
  launch, `PatientShell` shows a **bottom-sheet rationale** ("Stay up to date…")
  on first reaching the patient area (gated by a `notif_permission_prompted`
  flag). Tapping "Enable" calls `requestPermission()` which requests FCM
  authorization and, on grant, registers the device. Device registration
  (`registerDeviceForUser`) also runs at login: on iOS it requests permission +
  fetches the APNS token before the FCM token, then `POST`s
  `{fcm_token, platform}` to the backend. Logout unregisters the token.
- **Prep reminders**: `schedulePrepReminder` uses `flutter_local_notifications`
  + `timezone` to schedule a notification at **20:00 the evening before** a test
  that has preparation instructions (skipped if in the past); `cancelPrepReminder`
  removes it. The reminder payload also deep-links to the booking.

### Maps & location
- **Location** is fully wired (`geolocator` + the `LocationService`/
  `currentLocationProvider`/`haversineKm` stack). Android declares
  `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION`; iOS declares
  `NSLocationWhenInUseUsageDescription` ("…used to show and sort nearby labs…").
  Location powers the **Nearest** sort on the Labs tab (server-side `distanceKm`)
  and the **client-side distance ranking** on the test-detail screen.
- **Google Maps**: `google_maps_flutter` and `GOOGLE_MAPS_API_KEY` are declared
  as dependencies/config, but **no `GoogleMap` widget is currently rendered** in
  `lib/` (verified by search). Distance/proximity is surfaced as numeric "km/m"
  rather than an interactive map — the maps plugin is provisioned for future use.

### Charts / health-trends
Charts use **`fl_chart`** exclusively in `TrendsScreen` (`_TrendMiniChart`,
described above): customised `LineChart`s with abnormal-point highlighting and
reference-range bands. The lab dashboard/analytics use simple animated bars/
counters (`AnimatedProgressBar`, metric cards) rather than `fl_chart`.

### Localization / l10n
`flutter_localizations` + generated `AppLocalizations` from two ARB files
(`app_en.arb`, `app_ar.arb`, 330 keys each). Locale is user-selectable and
persisted; Arabic enables RTL. Strings use ICU placeholders/plurals.

### Other native integrations
- **`pdfx`** — in-app PDF rendering of result documents (bytes fetched through
  the authenticated Dio client).
- **`share_plus`** + **`path_provider`** — native share sheet for result PDFs.
- **`local_auth`** — biometric app-unlock gate, toggleable in the profile.
- **`intl`** — date/number formatting throughout (e.g. `EEE d MMM · h:mm a`).
- **`flutter_launcher_icons`** — adaptive app icon with the brand background.

---

## Design Rationale (why it's built this way)

- **Feature-first clean architecture** keeps each capability self-contained and
  makes the codebase navigable for a small team; the strict
  presentation/application/data split keeps UI testable and the backend swappable.
- **Riverpod** gives compile-safe DI, automatic caching/invalidation of server
  state, and fine-grained rebuilds via derived selectors — the patient workspace
  is fetched once and sliced, avoiding redundant calls.
- **A single shared Dio + queued auth interceptor** centralizes token attachment
  and silent refresh, so every repository inherits authentication and consistent
  error normalization for free.
- **Secure storage for tokens, SharedPreferences for preferences** is the correct
  security boundary (secrets in Keychain/Keystore, non-secrets in plain prefs).
- **Graceful degradation** is a recurring theme: missing Firebase, denied
  location, and unavailable biometrics all fail soft instead of blocking the user.
- **Parity with the web app** (palette ported from `globals.css`, identical
  `haversineKm`, mirrored search/test flows) keeps the two clients consistent for
  the same backend.
