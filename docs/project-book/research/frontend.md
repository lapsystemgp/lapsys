# TesTly — Frontend (Web Application) Subsystem

This chapter documents the **frontend** of TesTly, the medical lab-testing
marketplace for Egypt. The frontend is a single Next.js 16 application located
at `apps/frontend`. It serves every user-facing screen for the three roles the
platform supports — **Patient**, **Lab Staff**, and **Admin** — plus the public,
unauthenticated browsing experience (landing page, lab search, lab details, test
offers). It talks to a separate NestJS backend over HTTP, authenticating via an
http-only JWT cookie.

Every claim below is grounded in the actual source files; paths are given
relative to the repository root.

---

## Technology Stack and Project Layout

The stack is declared in `apps/frontend/package.json`:

- **Next.js 16.1.6** with the **App Router** (`src/app`), built with the Webpack
  builder (`"build": "next build --webpack"`).
- **React 19.2.3** / **React DOM 19.2.3**.
- **Tailwind CSS 4** (`@tailwindcss/postcss`, `tailwindcss@^4`), configured
  entirely through CSS (`@import "tailwindcss"` + `@theme inline` tokens in
  `src/app/globals.css`) — there is **no `tailwind.config.js`**; Tailwind 4 reads
  design tokens from CSS custom properties.
- **Radix UI** primitives: `@radix-ui/react-dialog`, `@radix-ui/react-label`.
- **Recharts ^2.15** for all charts (patient health trends, admin analytics).
- **jose ^6.2** for JWT decoding in middleware.
- **zod ^4.3** for runtime environment-variable validation.
- **lucide-react** for icons, **clsx** + **tailwind-merge** for the `cn()` class
  helper.
- **Playwright** for end-to-end tests (`tests/*.spec.ts`).

The source tree under `apps/frontend/src` is organised as follows:

- `src/app/` — App Router routes, layouts, error/loading boundaries, favicon.
- `src/components/` — app-specific shared React components (`AppShell`,
  `SessionProvider`, `ToastProvider`, `Breadcrumb`, and the patient
  `HealthTrendsPanel`).
- `src/lib/` — the typed API client layer (one module per backend domain).
- `src/teslty/` — the **presentational component library** exported from a Figma
  design (`components/`, `components/ui/`, `components/figma/`, `styles/`,
  `types.ts`). The route files in `src/app` are thin wrappers that wire these
  presentational components to data and navigation.
- `src/middleware.ts` — Edge middleware enforcing route protection.
- `src/env.mjs` — zod-validated environment schema.
- `tests/` — Playwright e2e specs.

A deliberate architectural pattern runs through the whole app: **route files are
"smart" container components** (they fetch data, handle auth redirects, own
state, and push navigation) while the `src/teslty/components/*` files are
**"dumb" presentational components** that receive everything via props and call
back through callbacks. This separation is why, for example, `src/app/labs/
LabsClient.tsx` is only 28 lines while the `LabComparison` component it renders
is 735 lines.

---

## Backend Communication: the Same-Origin `/api` Proxy

How the browser reaches the backend is one of the most important design
decisions, because the app uses **cookie-based authentication** and modern
browsers block third-party cookies.

### The API base URL

`src/lib/api.ts` defines:

```ts
export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/+$/, '') || 'http://localhost:3001';
```

So the base URL comes from the public env var `NEXT_PUBLIC_API_BASE_URL`. It is
validated in `src/env.mjs` with zod, which accepts **either** an absolute
`http(s)` URL **or** a path beginning with `/`:

```ts
NEXT_PUBLIC_API_BASE_URL: z.string().refine(
  (v) => v.startsWith('/') || /^https?:\/\//.test(v),
  { message: 'must be an absolute http(s) URL or a path starting with "/"' },
).default('http://localhost:3001'),
```

- **In local development**, `.env.local.example` sets it to
  `http://localhost:3001` — the browser talks directly to the local NestJS
  server. (`next.config.ts` simply imports `./src/env.mjs` to trigger validation
  at build time and otherwise holds no config.)
- **In production (Vercel)**, `vercel.json` overrides it to the relative path
  `"/api"` and declares a **rewrite** that proxies `/api/*` to the Railway-hosted
  backend:

```jsonc
// apps/frontend/vercel.json
"env": { "NEXT_PUBLIC_API_BASE_URL": "/api", "NEXT_PUBLIC_SHOW_DEMO_CREDENTIALS": "false" },
"rewrites": [
  { "source": "/api/:path*",
    "destination": "https://testly-backend-production-c28a.up.railway.app/:path*" }
]
```

### Why this matters (the design rationale)

By making the API base a **same-origin** path (`/api`) in production, every
request the browser issues goes to the Vercel domain itself; Vercel's edge then
forwards it server-side to Railway. From the browser's perspective the auth
cookie is **first-party**, so it is sent on every request without `SameSite`
problems. This is the fix recorded in the git history (`feat: proxy backend via
same-origin /api rewrite` and `fix(auth): use SameSite=None cross-site cookie`).
It is the cleanest way to keep an http-only JWT cookie working between a Vercel
frontend and a separately deployed backend.

### The `apiFetch` helper

`src/lib/api.ts` exports a single generic fetch wrapper used by almost every API
module:

```ts
export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const url = `${API_BASE_URL}${path.startsWith('/') ? '' : '/'}${path}`;
  const response = await fetch(url, {
    ...init,
    credentials: 'include',          // always sends the auth cookie
    headers: { ...(init?.headers ?? {}) },
  });
  if (!response.ok) {
    const bodyText = await readBodyTextSafe(response);
    throw new ApiError(`API request failed: ${response.status}`, { status, bodyText });
  }
  if (response.status === 204) return undefined as T;
  return (await response.json()) as T;
}
```

Key properties:

- `credentials: 'include'` is **always** set, so the http-only `access_token`
  cookie travels with every call — the frontend never reads or stores the token
  itself.
- Failures throw a typed `ApiError` (subclass of `Error`) carrying `status` and
  `bodyText`. Callers check `err instanceof ApiError && err.status === 401/403/
  404/409` to drive redirects and toasts. This typed-error pattern appears in
  every dashboard.
- 204 No Content is handled gracefully (returns `undefined`).

The chat endpoint is the one exception: `streamChatMessage` in `src/lib/
chatApi.ts` uses raw `fetch` directly (not `apiFetch`) because it must read a
**Server-Sent Events** stream rather than parse a single JSON body — but it still
uses `${API_BASE_URL}` and `credentials: "include"` so it goes through the same
proxy and cookie mechanism.

---

## The API Client Library (`src/lib`)

Each file in `src/lib` is a typed wrapper around one backend domain. They define
TypeScript types mirroring the backend DTOs and export thin async functions.
This gives the route components full type-safety and a single place where the
URL shape lives.

### `publicApi.ts` — unauthenticated browsing data

Powers the landing page, search, lab details, and test offers. Endpoints:

- `fetchPublicLabs(params)` → `GET /public/labs` — paginated lab cards. Accepts a
  rich query: `q`, `labName`, `city`, `sort` (`price` | `rating` | `distance`),
  `minRating`, `maxDistanceKm`, `maxPriceEgp`, `homeCollection`,
  `accreditations` (joined by commas), `userLat`/`userLng`, `page`, `pageSize`.
  Returns `PublicLabCard[]` with fields such as `rating`, `reviews`,
  `distanceKm`, `testsAvailable`, `startingFromEgp`, `priceForQueryEgp`,
  `homeCollection`, `homeTestKit`, `imageEmoji`.
- `fetchPublicLabDetail(labId, params)` → `GET /public/labs/:labId` — one lab plus
  its test catalogue and published `reviewItems`.
- `fetchPublicTest(labTestId)` → `GET /public/tests/:labTestId` — a single
  lab-test offer (used when pre-loading the booking screen).
- `fetchPublicTests(params)` → `GET /public/tests` — aggregated test cards
  (`name`, `category`, `minPriceEgp`, `labCount`).
- `fetchTestOffers({ name, category })` → `GET /public/tests/by-name` — all labs
  offering a named test, each with `latitude`/`longitude` so the client can sort
  by distance.

### `bookingsApi.ts` — booking lifecycle

Defines the booking domain types (`BookingStatus`, `BookingType`,
`PaymentMethod`, `PaymentStatus`, `KitStatus`) and functions:

- `fetchBookingAvailability({ labId, testId, dateFrom, days })` → `GET /bookings/
  availability`.
- `createBooking(input)` → `POST /bookings`.
- `demoOnlinePayment(bookingId, "success"|"failure")` → `POST /bookings/:id/
  demo-online-payment` (simulated payment gateway).
- `markCashCollected(bookingId)` → `PATCH /bookings/:id/mark-cash-collected`.
- `fetchPatientBookings()` / `fetchLabBookings()`.
- `cancelPatientBooking(bookingId)` → `PATCH /bookings/:id/patient-cancel`.
- `setLabBookingStatus(bookingId, "Confirmed"|"Rejected")` → `PATCH /bookings/:id/
  lab-status`.
- `updateKitStatus(bookingId, kitStatus, trackingNumber?)` → `PATCH /bookings/:id/
  kit-status`.

### `patientApi.ts` — patient workspace, health profile, profile, reviews

- `fetchPatientWorkspace()` → `GET /patient/workspace` — returns the patient's
  `profile`, `bookings` (split `upcoming`/`past`), and `results` (each with
  optional `summary.highlights`, structured-data flags, file metadata, and an
  optional `review`).
- `fetchPatientHealthProfile(range, groupBy)` → `GET /patient/health-profile` —
  longitudinal analyte series for the trends charts. Range is `3m|6m|12m|all`,
  grouping is `analyte|lab_test`. Returns `series`, `labTestGroups`,
  `pdfOnlyBookings`, a `disclaimer`, and a `hasStructuredData` flag.
- `updatePatientProfile(input)` → `PATCH /patient/profile` (includes the
  `labHistorySharing` privacy setting: `SAME_LAB_ONLY` vs.
  `FULL_HISTORY_AUTHORIZED`).
- `submitPatientReview({ bookingId, rating, comment })` → `POST /patient/reviews`.

### `labApi.ts` — lab workspace and operations

- `fetchLabWorkspace()` → `GET /lab/workspace` — the lab's bookings, test
  catalogue, schedule slots, and an `analytics` block (`totalBookings`,
  `completedBookings`, `pendingResults`, `revenueEstimateEgp`,
  `capacityUsagePercent`, `topTests`).
- `updateLabProfile({ homeTestKit, homeCollection })` → `PATCH /lab/profile`.
- Test CRUD: `createLabTest`, `updateLabTest`, `deleteLabTest` (`/lab/tests`).
- Schedule CRUD: `createScheduleSlot`, `updateScheduleSlot`,
  `deactivateScheduleSlot` (`/lab/schedule`).
- Results: `uploadLabResult(bookingId, { file, summary, highlights })` →
  multipart `POST /lab/results/:id/upload`; `setLabResultStatus`;
  `upsertLabStructuredResults(bookingId, panels)` → `PUT /lab/results/:id/
  structured` (the structured analyte panels that feed the patient trends).
- `fetchLabPatientContext({ bookingId | patientProfileId })` → `GET /lab/
  patient-context` — the privacy-scoped patient history a lab is allowed to see,
  including a `privacyNotice`, `effectiveScopeForThisLab`, prior bookings,
  recurring-test signals, and a 12-month trend summary.

### `adminApi.ts` — platform administration

- `fetchAdminWorkspace()` → `GET /admin/workspace` — labs with onboarding status
  and an `onboardingReadiness` object (completed/total requirements, missing
  list), plus aggregate `stats`.
- `setAdminLabOnboardingStatus(labProfileId, status)` → `PATCH /admin/labs/:id/
  status` (Approve / Reject / Suspend / etc.).
- `fetchAdminRecentPayments()` → `GET /admin/payments/recent`.
- `fetchAdminAggregateStats()` → `GET /admin/stats`.
- `fetchAdminPatients()` → `GET /admin/patients`.
- `fetchAdminChartData()` → `GET /admin/analytics/charts` (booking volume,
  revenue by city, popular tests for the Recharts dashboards).

### `chatApi.ts` — the agentic AI assistant (SSE)

Defines the streaming chat protocol used by the patient assistant:

- `fetchConversations()` / `fetchConversationMessages(id)` → `GET /chat/...`.
- `streamChatMessage({ text, conversationId, signal }, onEvent)` →
  `POST /chat/messages` with `Accept: text/event-stream`. It manually reads the
  `ReadableStream`, splits on blank lines (`\n\n`), and parses each `data:` SSE
  frame into a typed `ChatStreamEvent`:
  `meta` (conversationId), `delta` (token text), `tool` (a structured tool
  result), `done` (final message id), `error`.
- Tool results are typed: `find_labs` returns `AssistantLabCard[]`,
  `search_tests` returns `AssistantTestCard[]`. The assistant is therefore
  **agentic** — it can surface clickable lab/test cards inline in the chat.

### `faqApi.ts` — guided FAQ chatbot

- `fetchFaqIntents()` → `GET /faq/intents` (quick-topic buttons).
- `searchFaq({ q, page, pageSize })` → `GET /faq/search`.
- `askFaq(question)` → `POST /faq/ask` — returns an `answer`, optional `matched`
  FAQ items, and an optional `escalation` message. This powers the floating
  `ChatBot` widget present on every page.

---

## Authentication, Session, and Route-Guard Flow

Authentication is split across three layers: **the login form**, **the
SessionProvider client context**, and **the Edge middleware**.

### Token model

The backend issues an **http-only cookie named `access_token`** containing a JWT.
The frontend never reads the token in client JS; instead it relies on
`credentials: 'include'` to attach the cookie, and on the middleware to decode it
on the Edge.

### Login / Register (the form)

The actual auth form lives in `src/teslty/components/LoginPage.tsx` and is reused
by both `(auth)/login/page.tsx` and `(auth)/register/page.tsx`. Its flow
(`handleSubmit`):

1. If registering, it first POSTs to `/auth/register/patient` or
   `/auth/register/lab` (labs send extra fields: `lab_name`, `address`, `phone`,
   `accreditation`, `turnaround_time`, `home_collection`).
2. It then POSTs to `/auth/login` with `{ email, password, selectedRole }`. The
   `selectedRole` is chosen via the Patient/Lab/Admin pill toggle (admin is only
   offered on the login tab, never registration).
3. On success it normalises the returned `user.role` (`LabStaff`→`lab`,
   `Admin`→`admin`, else `patient`), calls `useSession().refresh()` to re-hydrate
   the global session, then invokes the route's `onAuthenticated` callback.

The route wrappers (`login/page.tsx`, `register/page.tsx`) own the **post-login
redirect logic**: admins → `/admin/dashboard`, active labs → `/lab/dashboard`,
labs whose `lab_onboarding_status !== "Active"` → `/unauthorized?reason=...`
(`pending_review` / `rejected` / `suspended`), everyone else → `/patient/
dashboard`. The login route also reads `?reason=expired` from the URL and shows a
"session expired" toast (set by the middleware on token expiry).

All API calls in the form go through `${API_BASE_URL}` with `credentials:
'include'`, so the login response's `Set-Cookie` lands as a first-party cookie.

### `SessionProvider` (client context)

`src/components/SessionProvider.tsx` is a React context mounted near the root.
On mount it calls `apiFetch<CurrentUser>("/auth/me")`:

- On success it stores the `CurrentUser` (`id`, `email`, `role`, optional
  `lab_profile` with `onboarding_status`/`lab_name`, optional `patient_profile`).
- On `401` it sets `user = null` (treated as logged-out, not an error).
- `logout()` POSTs `/auth/logout` (best-effort) and clears local state.
- Exposes `{ user, loading, refresh, logout }` via `useSession()`.

This context is what the landing page and every dashboard header use to show the
user's name/role and to drive the logout button.

### Edge Middleware (the route guard)

`src/middleware.ts` is the real access-control gate. Its `config.matcher`
protects exactly four path prefixes:

```ts
matcher: ['/lab/:path*', '/patient/:path*', '/booking/:path*', '/admin/:path*']
```

For each matched request it:

1. Reads the `access_token` cookie; if absent → redirect to `/login`.
2. Decodes the JWT with **`jose`'s `decodeJwt`** (note: it *decodes*, it does not
   verify the signature — verification happens server-side; the Edge check is a
   fast routing gate, and any forged token is rejected by the backend on the
   actual API call).
3. Checks `exp`; if expired → redirect to `/login?reason=expired`.
4. Enforces role rules from the JWT claims `role` and `lab_onboarding_status`:
   - `/lab/*` requires `role === 'LabStaff'`; if the role matches but the lab's
     `lab_onboarding_status !== 'Active'`, it redirects to `/unauthorized?reason=`
     with `rejected`/`suspended`/`pending_review` derived from the status.
   - `/patient/*` and `/booking/*` require `role === 'Patient'`.
   - `/admin/*` requires `role === 'Admin'`.
   - Any mismatch → `/unauthorized`.
5. A `catch` around the decode falls back to `/login`.

This is **defence in depth**: the middleware does cheap, fast role-routing on the
Edge, while the API itself still authorises every request server-side. Public
routes (`/`, `/labs`, `/labs/[labId]`, `/tests/[testName]`) are deliberately
*not* matched, so anonymous visitors can browse freely — matching the landing
page's "No registration required to browse" promise.

---

## Root Layout and the AppShell

`src/app/layout.tsx` is the root layout. It sets the document metadata (title
template `"%s | TesTly"`, description), applies `globals.css`, and wraps all
children in `<AppShell>`.

`src/components/AppShell.tsx` is a client component that composes the three
global providers and the floating chatbot:

```tsx
<SessionProvider>
  <ToastProvider>
    {children}
    <ChatBot isOpen={isChatOpen} onToggle={...} />
  </ToastProvider>
</SessionProvider>
```

So **every page** has access to the session, a global toast system, and the
floating FAQ `ChatBot` button in the bottom-right corner.

Supporting global UI files:

- `src/app/loading.tsx` — a centred spinner shown during route-segment loading.
- `src/app/error.tsx` — a `'use client'` error boundary ("Something went wrong!"
  with a *Try again* button), dark-mode aware.
- `src/app/icon.tsx` — generates the favicon at the Edge with `next/og`'s
  `ImageResponse` (a blue rounded square containing a flask SVG).

---

## Route / Page Catalogue

Below, each route is described as if narrating a screenshot: who uses it, what it
renders, what it fetches, and which components it relies on. Routes live under
`src/app`. The `(auth)` segment is a **route group** (parentheses → no URL
segment), giving login/register a bare white layout
(`(auth)/layout.tsx` renders `min-h-screen w-full bg-white`).

### `/` — Landing Page (public)

- **File:** `src/app/page.tsx` → renders `src/teslty/components/LandingPage.tsx`.
- **Audience:** everyone (anonymous and logged-in).
- **Screenshot:** A sticky white header with the **Tes**Tly logo, "Features" /
  "How It Works" anchor links, and either a *Sign In* button (anonymous) or a
  *Dashboard* link + user chip + logout icon (logged-in, role-aware). Below is a
  blue-gradient **hero** with decorative blurred blobs, a trust badge ("Egypt's
  Trusted Medical Lab Platform"), a large headline "Find the Best **Medical
  Labs** Near You", and a two-field **search bar** (test/symptom + optional
  city) plus a Search button. Popular-search chips (CBC, Lipid Profile, Thyroid
  Panel, HbA1c) and "Browse by: Nearest / Best Price / Top Rated" shortcuts sit
  under it. Then a six-card **"Why Choose TesTly?"** feature grid, a **Featured
  Labs** section (top-rated lab cards with rating, distance, tests-available,
  turnaround, starting price), a four-step **How It Works** strip, a blue **CTA**
  band, and a dark **footer** with patient/lab/support links.
- **Data:** `LandingPage` fetches `fetchPublicLabs({ sort: 'rating', pageSize: 6 })`
  on mount to populate Featured Labs. The page itself reads `useSession()` to
  derive role and a display label.
- **Navigation:** the page's `onSearch` builds a query string (`q`, `sort`,
  `city`) and pushes `/labs`; `onLabSelect` pushes `/labs/{id}`; `handleNavigate`
  maps the design's `Page` enum to real routes; `handleLogout` logs out and goes
  to `/login`.

### `/labs` — Lab & Test Search / Comparison (public)

- **Files:** `src/app/labs/page.tsx` (Suspense wrapper) → `LabsClient.tsx` (reads
  `q`, `sort`, `city` from `useSearchParams`) → `src/teslty/components/
  LabComparison.tsx`.
- **Audience:** everyone.
- **Screenshot:** A sticky header with brand, breadcrumb, a back-to-home link,
  and a "*N* results" badge. Two pills toggle **Tests** vs **Labs**. A persistent
  search bar (test/lab query + city filter). The **Tests** tab shows a grid of
  test cards (icon, name, category, "from EGP X", "Available at N labs", "View
  labs ›"). The **Labs** tab shows a sticky left sidebar ("Browse Labs", a
  Labs-Found / Home-Collection stat pair) and a right column of lab cards. Above
  the cards is a filter/sort bar: a *Filters* button (with active-count badge), a
  "Home Collection Only" checkbox, and a Sort-by select (Price / Rating /
  Distance). The expandable advanced-filter panel has range sliders for minimum
  rating, maximum distance, maximum price, plus accreditation toggle chips. Each
  lab card has a clickable blue lab name, rating, distance, address,
  accreditation, turnaround, a green "Home Collection" tag (and a green left
  border), the per-query/starting price, and a **Book Now** button.
- **Data:** `LabComparison` runs two effects — one fetching `fetchPublicTests`
  (on query change) and one fetching `fetchPublicLabs` (on any filter/sort/
  location change, keyed by a serialized `requestKey`). It manages skeleton,
  error, and empty states for each tab independently, with Retry buttons.
- **Geolocation:** to support "Distance" sort it requests the browser location
  via `navigator.geolocation.watchPosition` (more reliable than the one-shot
  API), with a 30s fallback timer and `navigator.permissions` change-watching to
  auto-retry if the user grants access after an initial denial. Status banners
  (requesting / denied / timeout / granted) appear when sorting by distance.

### `/labs/[labId]` — Lab Details (public)

- **File:** `src/app/labs/[labId]/page.tsx` → `src/teslty/components/
  LabDetailsPage.tsx`.
- **Audience:** everyone.
- **Screenshot:** A header with breadcrumb and back link. A large lab header card
  (lab name, rating + reviews, distance, address, a green "Home Collection
  Available" pill if applicable) followed by a four-cell grid (Accreditation,
  Turnaround Time, Contact phone, Email). Below, a **Patient Reviews** card (if
  any published reviews) listing reviewer initials, names, star ratings,
  comments, dates. Finally the **Available Tests** catalogue with category-filter
  chips ("All Tests" + each category) and per-test cards (name, price,
  description, preparation, turnaround, parameters count) each with a *Book This
  Test* button.
- **Data:** the route calls `fetchPublicLabDetail(labId)` in an effect with
  mount-guarding, a `retryKey` for retries, and a `resolvedLabId` trick to drive
  the loading state. It distinguishes **404 → "Lab not found"** from other errors
  (`err instanceof ApiError && err.status === 404`), each with its own error card
  and Back-to-Labs button.
- **Navigation:** `onBookTest(lab, test)` pushes `/booking?labId={id}&testId={id}`.

### `/tests/[testName]` — Test Offers / Compare Labs for a Test (public)

- **Files:** `src/app/tests/[testName]/page.tsx` (Suspense wrapper) →
  `TestDetailClient.tsx` (a 635-line self-contained client component).
- **Audience:** everyone.
- **Screenshot:** A sticky header with breadcrumb and Back-to-Results. A **test
  info card** (flask icon, test name, category pill, description, a three-cell
  facts row — results-in turnaround, parameters-measured, available-at-N-labs —
  and a Preparation bullet list parsed from the comma/semicolon-separated
  preparation string). Then a **sort + filter bar**: Nearest / Price / Rating
  segmented control (Nearest disabled until a location fix arrives), a Filters
  button with active-count badge, and a "then by Price/Reviews" secondary sort
  when Nearest is active. The filter panel offers a max-price slider, a
  minimum-rating chip row (Any/3+/3.5+/4+/4.5+), and a home-collection checkbox.
  Below is the **labs list**: each card shows lab name, distance badge, rating,
  accreditation, turnaround, address, Home Collection / Home Test Kit tags, the
  price, and *View Lab* + *Book Now* buttons.
- **Data:** fetches `fetchTestOffers({ name, category })` once on mount
  (`testName` is URL-decoded from the path; `category` from `?category`).
- **Client-side distance:** unlike `/labs`, distance here is computed **in the
  browser** with a `haversineKm` helper using each offer's `latitude`/
  `longitude` and the user's geolocation (same `watchPosition` + permission-watch
  strategy). When a location arrives, the UI auto-switches the sort to Nearest.
  All filtering and sorting of the offers list happen client-side in `useMemo`s.
- **States:** dedicated skeleton, "Something went wrong" (retryable), and "Test
  not found" cards.

### `/booking` — Booking Flow (Patient only)

- **Files:** `src/app/booking/page.tsx` (Suspense) → `BookingClient.tsx` →
  `src/teslty/components/BookingPage.tsx`. Protected by middleware (`/booking/*`
  requires `Patient`).
- **Audience:** logged-in patients.
- **Screenshot:** A breadcrumb header ("Labs / {lab} / Book Appointment") and the
  title "Book Your Appointment". A **lab info card** (name, address, selected
  test, base price). A **Choose Collection Type** card with three large
  selectable tiles — *Visit Lab*, *Home Collection* (+EGP 100, disabled unless
  the lab offers it), *Home Test Kit* (+EGP 150, disabled unless offered). For
  lab/home flows, a **Select Date** grid (built from the available slots) and a
  **Select Time Slot** grid (only future slots for the chosen day). For the kit
  flow, an explanatory "How it works" banner instead. A **Payment** card lets the
  patient pick *Pay online (demo)* or a context-appropriate cash option (cash on
  collection / at lab / on delivery). A home/kit **address** textarea appears when
  relevant. Finally a **Booking Summary** card itemising test price + any
  collection/kit fee → total, the payment method, and the *Confirm Booking* /
  *Order Kit* button. On success it shows a green confirmation card and
  auto-navigates to the patient dashboard after ~1.6s.
- **Data:** `BookingClient` reads `labId`/`testId` from `useSearchParams`, then
  `Promise.all([fetchPublicLabDetail, fetchPublicTest, fetchBookingAvailability(
  { days: 7 })])`. On submit it calls `createBooking(...)`. It handles `401` →
  `/login` and `409` (slot taken) → toast + re-fetch availability, surfacing
  errors via the toast system.

### `/patient/dashboard` — Patient Workspace (Patient only)

- **File:** `src/app/patient/dashboard/page.tsx` (629 lines). Protected.
- **Audience:** patients.
- **Screenshot:** A header with the patient's avatar (first initial), name, a
  "Patient" pill, a back-to-home link, and three action buttons: **AI Assistant**,
  **Browse Labs**, **Logout**. Three quick-stat tiles (Total Bookings, Upcoming,
  Results). A four-tab pill bar: **Bookings**, **Results**, **Trends**, **Profile**.
  - *Bookings*: cards per booking with a coloured left border by status, test/lab
    name, status badge, a four-field grid (date/order-date, type, total, address),
    a kit-status progress bar for Home Test Kit orders, payment method/status
    line, demo-payment buttons for pending online payments (*pay successfully* /
    *decline*), and a *Cancel Booking* button for pending/confirmed bookings.
  - *Results*: per-result cards with status, "Structured data · N values" vs "PDF
    only" badge, an AI **Summary** block with highlighted key/value items, an
    *Open PDF* link, and a **review** widget (5-star picker + comment) gated by
    `result.canReview && !result.review`.
  - *Trends*: renders `<HealthTrendsPanel>` (the Recharts charts, see below).
  - *Profile*: editable full name / phone / address, a read-only email, and the
    **lab history sharing** select (`SAME_LAB_ONLY` vs `FULL_HISTORY_AUTHORIZED`)
    with an explanatory privacy note; a *Save Profile* button.
- **Data:** `fetchPatientWorkspace()` on mount; mutations call
  `cancelPatientBooking`, `demoOnlinePayment`, `updatePatientProfile`,
  `submitPatientReview`, each followed by a re-fetch and a toast. `401` redirects
  to `/login`. Result PDF URLs are resolved against `API_BASE_URL`.

### `/patient/assistant` — AI Health Assistant (Patient only)

- **File:** `src/app/patient/assistant/page.tsx` (426 lines). Protected.
- **Audience:** patients.
- **Screenshot:** A chat-style screen: header with a heart-pulse avatar, "Health
  Assistant" title, back-to-dashboard link, and a *New chat* button. The body is
  a scrollable message area; when empty it shows a welcome state ("Hi {name}! I'm
  your health assistant") with three suggestion buttons (e.g. "How do I prepare
  for a fasting blood test?"). Messages render as bubbles (blue for user, grey for
  assistant) with animated typing dots while streaming. The assistant can attach
  **structured tool-result cards** — clickable **lab cards** (`find_labs`) and
  **test cards** (`search_tests`) that route to `/labs/{id}` or `/tests/{name}`.
  A bottom composer has an auto-sizing textarea (Enter to send, Shift+Enter for
  newline) and a circular send button, with a disclaimer beneath.
- **Data:** uses `streamChatMessage` (SSE) from `chatApi.ts`. It optimistically
  appends the user message and an empty streaming assistant bubble, then mutates
  that bubble as `meta`/`delta`/`tool`/`done` events arrive. Errors drop the empty
  placeholder and toast; `401` redirects to `/login`. This is the **agentic**
  assistant — distinct from the simpler guided FAQ `ChatBot`.

### `/lab/dashboard` — Lab Workspace (Lab Staff only)

- **File:** `src/app/lab/dashboard/page.tsx` (1002 lines). Protected (LabStaff
  with `Active` onboarding).
- **Audience:** lab staff.
- **Screenshot:** A header (back-to-home, "Lab Workspace", lab name, Logout). A
  seven-tab pill bar: **Bookings, Tests, Results, Schedule, Analytics, Reviews,
  Settings**.
  - *Bookings*: pending first, then the rest. Each card shows patient name, test,
    date, status badge, a four-field grid (type, phone, address, amount), a
    payment line, **Confirm/Reject** buttons (Confirm disabled until online
    payment is `Paid`), a *Record cash received* button for cash bookings, the
    **Home Test Kit** action ladder (Ship Kit + tracking input → Mark Delivered →
    Mark Sample Received), and a *Patient history & context* button that opens a
    slide-over drawer.
  - *Tests*: an **Add Test** form (name/category/price) plus inline-editable test
    rows with Edit/Delete/Active-toggle.
  - *Results*: for confirmed/completed bookings, a PDF file picker + summary
    field + *Upload Result*, a *Mark Delivered*, and *Patient history & context*.
  - *Schedule*: an **Add Slot** form (datetime-local start/end + capacity) and a
    list of slots with *Deactivate*.
  - *Analytics*: stat cards (Total Bookings, Completed, Pending Results, Revenue
    Estimate, Capacity Usage %, Top Tests).
  - *Reviews*: published patient reviews fetched lazily via
    `fetchPublicLabDetail` when the tab opens.
  - *Settings*: a toggle for **Home Test Kits** (writes `updateLabProfile`).
- **Patient-context drawer:** a right-hand `aside` overlay showing the
  privacy-scoped patient history from `fetchLabPatientContext` — privacy notice,
  the patient's sharing setting and the lab's *effective scope*, demographics,
  recurring-test signals, a 12-month trend summary, and prior bookings/results
  (cross-lab entries flagged "Other lab", PDFs only linkable for *this* lab).
- **Data:** `fetchLabWorkspace()` on mount; `403` → `/unauthorized?reason=
  pending_review`. Mutations (`setLabBookingStatus`, `markCashCollected`,
  `updateKitStatus`, test/schedule CRUD, `uploadLabResult`, `setLabResultStatus`,
  `updateLabProfile`) each re-fetch and toast; delete-with-bookings yields a `400`
  with a specific message.

### `/admin/dashboard` — Admin Panel (Admin only)

- **File:** `src/app/admin/dashboard/page.tsx` (748 lines). Protected.
- **Audience:** platform admins.
- **Screenshot:** An indigo→purple gradient header (shield icon, "Admin Panel /
  TesTly Platform", Logout). A five-card stats row (Total Labs, Active Labs,
  Total Bookings, Platform Revenue in "EGP NK", Pending Approvals — highlighted
  orange). A tabbed card with four tabs (the Lab Approvals tab carries a pending
  count badge):
  - *Lab Approvals*: a search box, status-filter chips (All / Pending / Active /
    Rejected / Suspended), and lab cards (name, status badge, contact details,
    submitted date). Pending labs are tinted orange. Each card has **Approve Lab**
    (disabled unless `onboardingReadiness.isReady`), **Reject**, and a
    **View Details** expander revealing a stat grid (Tests, Bookings, Schedule
    Slots, Rating) and an onboarding-readiness summary listing missing
    requirements.
  - *User Management*: a searchable patient table (Name, Email, Role, Bookings,
    Joined).
  - *All Bookings*: a table of the most recent payments (Booking ID, Patient,
    Lab, Test, Date, Status badge, Amount).
  - *Analytics*: Recharts dashboards (below) plus a "Top Performing Labs" list
    aggregated client-side from the recent-payments data.
- **Data:** one `Promise.all` loads `fetchAdminWorkspace`,
  `fetchAdminRecentPayments`, `fetchAdminAggregateStats`, `fetchAdminPatients`,
  `fetchAdminChartData`. `401` → `/login`, `403` → `/unauthorized`. Status
  updates call `setAdminLabOnboardingStatus` and parse backend validation
  messages via a `readApiErrorMessage` helper.

### `(auth)/login` and `(auth)/register` — Authentication (public)

- **Files:** `src/app/(auth)/login/page.tsx`, `src/app/(auth)/register/page.tsx`,
  shared layout `src/app/(auth)/layout.tsx`, presentational `LoginPage.tsx`.
- **Screenshot:** A blue-gradient screen with a back-to-home link and a centred
  white card: the **Tes**Tly logo, a "Welcome Back" / "Create Account" heading, a
  role toggle (Patient / Lab / Admin — Admin only on login), the form fields
  (name, plus lab-only address/phone/accreditation/turnaround/home-collection
  fields when registering a lab; email; password with show/hide eye toggle), a
  blue submit button, a Sign-In/Sign-Up toggle link, a lab-review notice when
  registering a lab, and an "AES-256 encryption" security badge. The login page
  also surfaces a "session expired" toast when arriving with `?reason=expired`.

### `/unauthorized` — Access Denied (any authenticated user)

- **File:** `src/app/unauthorized/page.tsx` — a server component (it `await`s
  `searchParams`).
- **Screenshot:** A dark (zinc-950) full-screen page with a single card titled
  "Access Denied" (red→pink gradient text) and a *Return to Login* link. The body
  message is tailored by `?reason`: `pending_review`, `rejected`, `suspended`, or
  a generic permission message — exactly the reasons the middleware and login
  redirects produce for labs that are not yet active.

---

## Component Inventory

### App-level shared components (`src/components`)

- **`AppShell.tsx`** — client wrapper composing `SessionProvider` →
  `ToastProvider` → page children → floating `ChatBot`. Owns the chatbot
  open/close state.
- **`SessionProvider.tsx`** — global auth/session React context (`useSession`),
  hydrated from `GET /auth/me`. (Detailed in the Auth section.)
- **`ToastProvider.tsx`** — a self-contained toast system. Exposes
  `useToast().success/error/info`. Toasts are pushed into a top-right stack,
  auto-dismiss after 3.5s, animate in/out (`animate-slide-in-right` /
  `animate-slide-out-right`), and show a draining progress bar (`animate-drain`).
  Colour and icon vary by type (green check / red alert / blue info). This is the
  single source of user feedback across every dashboard mutation.
- **`Breadcrumb.tsx`** — a small `<nav aria-label="Breadcrumb">` that always
  prefixes a Home link (house icon) and renders `{ label, href? }` items with
  chevron separators; the last item is non-link, bold. Used on nearly every inner
  page.
- **`patient/HealthTrendsPanel.tsx`** — the patient trends visualisation (see
  Charts section).

### Presentational component library (`src/teslty/components`)

These are the larger UI components exported from the Figma design; the route
files feed them data and callbacks.

- **`LandingPage.tsx`** — the marketing landing page (header, hero+search,
  features, featured labs, how-it-works, CTA, footer). Self-fetches featured labs.
  Includes private `FeatureCard` and `StepCard` sub-components.
- **`LabComparison.tsx`** — the `/labs` search experience (Tests/Labs tabs,
  filters, sort, geolocation, lab/test cards). Self-fetches labs and tests.
- **`LabDetailsPage.tsx`** — the `/labs/[labId]` detail view (lab header, reviews,
  category-filtered test catalogue). Pure presentational (data passed in).
- **`BookingPage.tsx`** — the `/booking` multi-card wizard (collection type, date,
  time, payment, address, summary, confirmation). Pure presentational; computes
  fees (`HOME_COLLECTION_FEE = 100`, `HOME_KIT_FEE = 150`) and the effective
  payment method.
- **`ChatBot.tsx`** — the global floating **guided FAQ** widget (distinct from the
  agentic patient assistant). A blue bubble button that expands into a 384×600
  chat panel; greets the user, offers quick-intent buttons from
  `fetchFaqIntents()`, and answers via `askFaq()` (appending any `escalation`).
- **`LoginPage.tsx`** — the shared auth form (login + register, role toggle, lab
  fields). (Detailed in the Auth section.)

### Figma scaffolding (`src/teslty/components/ui` and `/figma`)

These are shadcn/Radix-style primitives carried over from the design export.
Notably, a grep shows the `ui/input`, `ui/label`, and `ui/dialog` primitives are
**not imported anywhere** in the app — the actual screens use raw Tailwind-styled
`<input>`/`<button>` markup — so they are dormant scaffolding rather than the
in-use component set. They remain useful as a reference for the intended design
system.

- **`ui/utils.ts`** — the `cn(...inputs)` helper (`twMerge(clsx(...))`). This one
  *is* used by the primitives.
- **`ui/dialog.tsx`** — a full Radix Dialog wrapper (Root/Trigger/Portal/Overlay/
  Content/Header/Footer/Title/Description/Close) with `data-slot` attributes and
  animation classes.
- **`ui/input.tsx`**, **`ui/label.tsx`** — Radix-backed Input and Label primitives
  themed via CSS variables (`border-input`, `text-muted-foreground`, etc.).
- **`figma/ImageWithFallback.tsx`** — an `<img>` wrapper that swaps to an inline
  SVG placeholder on load error.
- **`styles/globals.css`** — a second, larger stylesheet from the Figma export
  that is **not imported** by the app (`src/app/globals.css` is the live one); it
  is legacy/source material.
- **`types.ts`** — the design's navigation `Page` union and `UserRole` type, used
  by `LandingPage`/`page.tsx` to translate design-level page names into routes.

---

## Styling and Design System

The live stylesheet is **`src/app/globals.css`** (Tailwind 4). The design system
is expressed entirely in CSS, with no JS Tailwind config.

- **Font:** Google "Plus Jakarta Sans" (imported at the top, set as
  `--font-sans`/`--font-display`).
- **Design tokens (`:root`)** are described as "derived from the Figma
  medical-labs UI": a neutral surface palette (`--background #f9fafb`,
  `--surface #ffffff`, `--line-subtle #e5e7eb`), a blue **brand** (`--brand
  #2563eb`, `--brand-strong #1d4ed8`), semantic colours (success/warning/
  destructive), chart colours (`--chart-1..5`), radii, and sidebar tokens. A
  `dark` custom variant is declared (`@custom-variant dark`) and the error/loading
  pages use `dark:` classes, though the app ships light by default.
- **`@theme inline`** maps those variables into Tailwind's color/spacing scales
  (e.g. `--color-brand-600`, `--color-ink-500`, `--color-success-600`), plus
  custom radii (`--radius-card`, `--radius-panel`, `--radius-pill`) and shadows
  (`--shadow-card`, `--shadow-raised`, `--shadow-glow`).
- **Animations:** keyframes `shimmer`, `fade-in`, `slide-up`, `slide-in-left/
  right`, `slide-out-right`, `drain`, `scale-in`, exposed as utility classes
  (`.animate-fade-in`, `.animate-slide-up`, `.animate-slide-in-right`, etc.) plus
  `.animation-delay-100..600`. These drive the staggered card-entrance animations
  and toast transitions seen throughout.
- **`.skeleton`** — a shimmering grey gradient used for every loading skeleton
  (search, dashboards, booking, lab details).
- **`@layer components`** defines reusable design-system classes: `.ds-card`,
  `.ds-panel`, `.ds-button-primary/secondary`, `.ds-input`, `.ds-badge-success`.

In practice the screens lean heavily on **inline Tailwind utility classes**
(blue-600 primary buttons, `rounded-2xl` cards, `shadow-sm`, status-coloured
badge helpers like `bookingStatusClass`/`statusClass`) rather than the `.ds-*`
component classes, but the token foundation keeps the palette consistent. The
visual language is consistent across roles: white rounded cards on a `gray-50`
background, a blue brand accent, pill tabs (`bg-blue-600 text-white` active vs
`text-gray-600` inactive), and lucide-react icons.

---

## Charts (Recharts)

Two areas use Recharts.

### Patient health trends — `src/components/patient/HealthTrendsPanel.tsx`

Rendered inside the patient dashboard's *Trends* tab. It loads
`fetchPatientHealthProfile(range, groupBy)` and renders a **`LineChart`** per
analyte series (`SeriesChartCard`):

- Date-range chips (3m/6m/12m/all) and grouping chips (By analyte / By lab test).
- Each chart plots normalised numeric values over `testDate` with a monotone
  `Line`, a `CartesianGrid`, `XAxis`/`YAxis`, and a custom `Tooltip` that appends
  "(within/outside reference)" notes.
- A **`ReferenceArea`** shades the reference interval from the most recent report
  that included limits.
- **Custom dot colouring** flags abnormal points red, in-range green, unknown
  blue — a nice touch for clinical readability.
- Below each chart is a textual point-by-point breakdown, a trend badge (Rising/
  Falling/Stable/Not-enough-points), and qualitative notes.
- An **Export CSV** button serialises the visible series to a downloadable CSV
  (built and downloaded entirely client-side via a `Blob`).
- Rich empty/edge states: "structured values on file but not chartable", "no
  structured data yet" (with a list of PDF-only bookings), and a standing medical
  disclaimer.

### Admin platform analytics — inside `src/app/admin/dashboard/page.tsx`

The `AnalyticsTab` renders three Recharts visualisations from
`fetchAdminChartData()`:

- **Booking Volume** — an `AreaChart` (purple gradient fill) of daily bookings
  over 30 days.
- **Revenue by City** — a vertical `BarChart` (indigo bars, "Nk" Y-axis
  formatting).
- **Most Popular Tests** — a horizontal `BarChart` (sky-blue bars).

Each has a "no data yet" guard. A non-chart "Top Performing Labs" list is
aggregated client-side from the recent-payments rows.

---

## Testing (Playwright)

End-to-end tests live in `apps/frontend/tests` with `playwright.config.ts`
(Chromium only, `baseURL http://localhost:3000`, auto-starting `npm run dev` as
its `webServer`, HTML reporter, CI retries). There are three journey specs —
`patient-journey.spec.ts`, `lab-journey.spec.ts`, `admin-journey.spec.ts` —
covering anonymous search, login, and role-specific flows. (Note: some selectors
in the patient spec reference older placeholder text, e.g. `Search for labs`,
which differs from the current landing-page placeholder — a maintenance gap worth
flagging.)

---

## Summary of Architectural Strengths

- **Clean separation** of smart route containers (`src/app/**`) from dumb
  presentational components (`src/teslty/components/**`), connected by a typed API
  layer (`src/lib/**`).
- **Cookie-based auth done correctly** for a split deployment: a same-origin
  `/api` Vercel rewrite makes the JWT cookie first-party, with `jose`-based Edge
  middleware as a fast role-routing guard and server-side authorisation as the
  real gate.
- **Consistent UX scaffolding**: one toast system, one breadcrumb, one skeleton
  utility, one design-token palette, and uniform `ApiError` handling
  (`401`→login, `403`→unauthorized, `404`/`409` specialised) across every screen.
- **Two complementary assistants**: an SSE-streamed, agentic patient assistant
  that surfaces clickable lab/test cards, and a lightweight guided-FAQ chatbot on
  every page.
- **Thoughtful client-side geolocation** (watchPosition + permission-change
  retry) and **clinically aware charting** (reference bands, abnormal-point
  colouring, CSV export, disclaimers).
