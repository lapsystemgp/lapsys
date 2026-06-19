# TesTly — System Overview

> This chapter is the **synthesis** of the six subsystem deep-dives in this folder. It
> ties the backend, web frontend, mobile app, AI assistant, data model, and infrastructure
> into one coherent narrative for the project book. Where a claim is examined in depth in a
> subsystem chapter, it is cross-referenced inline (e.g. *(see [backend](./backend.md) §6)*)
> so a reader can drill down. The authoritative per-subsystem sources are:
> [backend.md](./backend.md), [frontend.md](./frontend.md), [mobile.md](./mobile.md),
> [ai-agent.md](./ai-agent.md), [data-model.md](./data-model.md), and [infra.md](./infra.md).

---

## Elevator Pitch & Problem Statement

**TesTly is a medical lab-testing marketplace for Egypt** — a single platform where a
patient can discover diagnostic labs near them, compare the same test (a CBC, a lipid
profile, an HbA1c) across many labs by price, rating, distance and accreditation, book and
pay for it (online or cash), receive the official result as a secure PDF *and* as
structured, queryable data, track their health markers over time **across different labs**,
and ask an AI health assistant — grounded in the real catalogue — where to get a test and
what it means.

**The problem.** In Egypt the lab-testing market is fragmented and opaque. Prices for an
identical test vary widely between labs and are rarely listed; patients have no neutral way
to compare options or read other patients' experiences; results arrive as one-off PDFs that
cannot be trended; and there is no privacy-respecting way for a patient's longitudinal
history to follow them when they switch labs. For labs, especially smaller ones, there is no
low-cost storefront, scheduling, and results-delivery system. For the ecosystem as a whole,
there is no trusted, *curated* intermediary that verifies labs are operationally complete
before exposing them to patients.

**What TesTly does about it.** It is a curated, multi-actor marketplace that (1) gives
patients a transparent, comparison-first storefront with real per-lab pricing; (2) gives
labs a complete back-office — catalogue, schedule, bookings queue, results upload, analytics
— behind an admin-gated onboarding process; (3) solves the cross-lab continuity problem with
a clinical-normalisation engine that converts each lab's differently-named, differently-united
analytes into a canonical, comparable form, governed by a patient-controlled privacy toggle;
and (4) layers an agentic, function-calling AI assistant over the live catalogue so help is
both conversational and truthful. It ships as **a web app and a native mobile app over one
shared API**, with security and data-handling treated as first-class because the domain is
medical *(see [infra.md](./infra.md) §d for the full security posture)*.

---

## High-Level Architecture

TesTly is an **npm-workspaces monorepo** with three applications over one API contract: a
NestJS backend (`apps/backend`), a Next.js web app (`apps/frontend`), and a Flutter mobile
app (`apps/mobile`) *(see [infra.md](./infra.md) §a)*. Two client front-ends consume one
backend, which fronts a PostgreSQL database and four external services.

```
        ┌──────────────────────────┐        ┌──────────────────────────┐
        │  WEB (Next.js 16 / React │        │  MOBILE (Flutter / Dart) │
        │  19, Vercel)             │        │  iOS + Android           │
        │  Patient · Lab · Admin   │        │  Patient · Lab           │
        └────────────┬─────────────┘        └────────────┬─────────────┘
                     │  httpOnly JWT cookie               │  Bearer JWT
                     │  via same-origin /api rewrite      │  (secure storage)
                     │                                    │
                     ▼                                    ▼
        ┌────────────────────────────────────────────────────────────────┐
        │   NestJS 11 API  (apps/backend, Railway / Render)               │
        │   ───────────────────────────────────────────────────────────  │
        │   Guards: JwtAuthGuard → RolesGuard → LabActiveGuard           │
        │           → per-service ownership checks                        │
        │   Modules: auth · public marketplace · bookings/payments ·     │
        │            patient & lab workspaces · results (PDF+structured) ·│
        │            clinical normalization · admin · faq · chat (agent)  │
        │   Cross-cutting: ValidationPipe · HttpExceptionFilter ·         │
        │                  AuditLog · Prisma retry middleware             │
        └───┬───────────────┬──────────────────┬────────────────┬────────┘
            │ Prisma 5      │ @aws-sdk/client-s3│ firebase-admin │ @google/genai
            ▼               ▼                   ▼                ▼
   ┌────────────────┐ ┌──────────────┐ ┌────────────────┐ ┌──────────────────┐
   │ PostgreSQL     │ │ S3 / local   │ │ Firebase Cloud │ │ Google Gemini    │
   │ (Neon prod /   │ │ disk         │ │ Messaging      │ │ (gemini-2.5-     │
   │  Docker local) │ │ result PDFs  │ │ push           │ │  flash)          │
   │ 20 tables      │ │              │ │                │ │ agentic chat     │
   └────────────────┘ └──────────────┘ └────────────────┘ └──────────────────┘
```

**Clients → API.** The web app never holds the JWT itself: the backend issues an `httpOnly`
`access_token` cookie, and the browser attaches it via `credentials: 'include'`. Because the
web app (Vercel) and API (Railway) are on different sites, the production deployment uses a
**same-origin `/api` rewrite** so the cookie is first-party, plus `SameSite=None; Secure`
cookie attributes — a problem solved at the infrastructure layer rather than by weakening
code *(see [frontend.md](./frontend.md) "Same-Origin /api Proxy" and [infra.md](./infra.md)
§d)*. The mobile app uses the same login endpoint but reads the token from the JSON body,
stores it in the iOS Keychain / Android Keystore, and sends it as a `Bearer` header through a
queued Dio interceptor that does silent refresh-token rotation *(see [mobile.md](./mobile.md)
"Core Infrastructure")*. The backend's JWT strategy accepts **either** transport from two
extractors, so one auth codebase serves both clients *(see [backend.md](./backend.md) §4.4)*.

**API → data & services.** Prisma 5 is the single data-access layer over PostgreSQL, with a
`$use` middleware that retries transient errors for serverless-Postgres (Neon) resilience.
Three external integrations all **degrade gracefully** when unconfigured: S3 (falls back to
local disk), Firebase Cloud Messaging (push becomes a no-op), and Google Gemini (the chat
endpoint returns 503). This is a deliberate, recurring design theme that lets the core API
run anywhere *(see [backend.md](./backend.md) §8–9, [infra.md](./infra.md) §c–d)*.

---

## Complete Feature Catalogue (by Actor)

TesTly models three human actors via the `Role` enum — **Patient**, **LabStaff**, **Admin** —
plus a non-human **AI agent**. The admin console is web-only by design; patients and lab
staff are served by both web and mobile *(see [mobile.md](./mobile.md) intro)*.

### Patient

- **Browse the public marketplace without registering** — landing page, lab search, lab
  detail, and test-comparison pages are all unauthenticated; only `Active` labs/tests are
  ever exposed *(see [backend.md](./backend.md) §5, [frontend.md](./frontend.md) route
  catalogue)*.
- **Search & compare labs** by free-text query, city, sort (price / rating / distance),
  minimum rating, max distance, max price, home-collection capability, and accreditation.
- **Compare a single test across labs** — one test name resolves to every lab offering it,
  with each lab's price, rating, accreditation, and coordinates (price-ascending).
- **Distance/geolocation ranking** — server-side Haversine on `/labs`; client-side Haversine
  on the test-offers screen; both web and mobile share the *identical* `haversineKm` formula
  for consistent numbers *(see [frontend.md](./frontend.md), [mobile.md](./mobile.md)
  location service)*.
- **Book a test** in one of three modes — **Lab Visit**, **Home Collection** (+EGP 100),
  **Home Test Kit** (+EGP 150) — choosing a future schedule slot (visit/home) or receiving an
  estimated kit delivery date *(see [backend.md](./backend.md) §6.2)*.
- **Pay** online (simulated gateway) or by cash (cash-at-lab / cash-to-collector /
  cash-on-delivery), matched to the booking type *(see [backend.md](./backend.md) §6.3)*.
- **Track bookings** — order timeline of status events, kit-shipment progress bar, cancel a
  pending/confirmed booking (auto-refund if already paid), retry a failed online payment.
- **Receive results** — an authoritative PDF (viewable/downloadable only through an
  authorisation-checked endpoint) plus an AI-style plain-language summary with highlights, and
  a flag for whether structured data exists.
- **View cross-lab health trends** — longitudinal charts per analyte (or per lab-test) with
  reference-range shading, abnormal-point colouring, trend direction, and CSV export; spans
  results from *different* labs thanks to canonical normalisation *(see
  [backend.md](./backend.md) §7.4, [data-model.md](./data-model.md) marker stack)*.
- **Control privacy** — toggle `lab_history_sharing` between `SAME_LAB_ONLY` (default) and
  `FULL_HISTORY_AUTHORIZED` *(see [data-model.md](./data-model.md) "Privacy Model")*.
- **Review a lab** — one review per completed booking; feeds the lab's denormalised rating.
- **Chat with the agentic AI assistant** (streaming, with clickable lab/test cards) and the
  lightweight guided-FAQ chatbot *(see [ai-agent.md](./ai-agent.md))*.
- **Manage profile** — name/phone/address; on mobile additionally biometric unlock, language
  (EN/AR), and light/dark theme *(see [mobile.md](./mobile.md) profile feature)*.
- **Push notifications** on booking confirmed/rejected, kit shipped, and result ready; plus a
  mobile local "prep reminder" the evening before a fasting test *(see
  [mobile.md](./mobile.md) notifications)*.

### Lab Staff

- **Account is gated** — a new lab registers in `PendingReview` and cannot transact until an
  admin activates it; the `LabActiveGuard` enforces this at the API boundary, and a deferred,
  role-based mobile/web route guard mirrors it *(see [backend.md](./backend.md) §4.4,
  [infra.md](./infra.md) §d)*.
- **Workspace dashboard** — booking queue, test catalogue, schedule slots, and computed
  analytics (totals, completed, pending results, revenue estimate, capacity-usage %, top
  tests) in one aggregated call *(see [backend.md](./backend.md) §7.2)*.
- **Manage the catalogue** — create/update/delete tests (delete blocked if bookings exist),
  with per-test price, description, preparation, turnaround, parameter count, and active flag.
- **Manage the schedule** — create/update slots; deactivate is a soft delete preserving
  history; windows must be future and well-ordered.
- **Process bookings** — confirm/reject pending bookings (online bookings can only be
  confirmed once paid), record cash collected, and advance the home-test-kit workflow through
  its strict one-step state machine (AwaitingShipment → Shipped → Delivered → SampleReceived).
- **Toggle capabilities** — enable/disable home collection and home test kits.
- **Upload & deliver results** — upload the official PDF (validated by 10 MB cap **and** `%PDF`
  magic bytes), attach a summary + highlights, set status Uploaded/Delivered (Delivered also
  completes the booking and notifies the patient), and upsert structured panels/observations
  that feed cross-lab trends *(see [backend.md](./backend.md) §7.3–7.4)*.
- **View privacy-scoped patient context** — a patient's clinical history, bounded by the
  patient's sharing setting; cross-lab structured summaries only when authorised, and **never**
  another lab's raw PDF *(see [data-model.md](./data-model.md) "Privacy Model")*.
- **See its own reviews** and receive push on new bookings and new reviews.

### Admin

- **Lab governance dashboard** — every lab with its onboarding status and an explicit
  *onboarding-readiness* object (5 requirements: phone, accreditation, turnaround, ≥1 active
  test, ≥1 active slot), listing exactly which are missing.
- **Activate / reject / suspend labs** — activation is **refused** for a lab that fails the
  readiness gate, guaranteeing every bookable lab is operationally complete *(see
  [backend.md](./backend.md) §10)*.
- **Platform stats & analytics** — total bookings and paid revenue; 30-day booking-volume
  area chart, revenue-by-city bar chart, popular-tests chart.
- **User management** — searchable list of patients with booking counts.
- **Recent payments feed** — booking + payment details across the platform.
- All admin methods re-assert the admin role inside the service as defence-in-depth.

### The AI Agent (cross-actor, patient-facing)

- **Agentic Health Assistant** — a Google Gemini (`gemini-2.5-flash`) assistant that streams
  replies over Server-Sent Events and runs a **server-side function-calling loop** (≤4 rounds)
  with two tools, `find_labs(query, city?)` and `search_tests(query)`, both querying the live
  Prisma catalogue (active labs/tests only). Tool results stream to the UI as clickable
  lab/test cards and are persisted in `ChatMessage.metadata` so reopened conversations
  re-render the cards *(see [ai-agent.md](./ai-agent.md) "Agentic Tool / Card Mechanism")*.
- **Grounded & guard-railed** — a strict system prompt forbids inventing labs/prices,
  enforces non-diagnosis and emergency-escalation rules, and mirrors the user's language
  (EN/AR). The "two-payload" tool result separates a rich render payload (UI) from a compact
  reasoning payload (model) *(see [ai-agent.md](./ai-agent.md) prompt design)*.
- **Guided FAQ bot** — a separate, **non-LLM**, deterministic keyword-search bot over a seeded
  `FaqEntry` table, available as a floating widget on every web page; handles the cheap, common
  questions without burning Gemini quota *(see [ai-agent.md](./ai-agent.md) "Guided FAQ Bot",
  [backend.md](./backend.md) §11)*.
- **Web + mobile parity** — both clients are thin renderers of the same SSE + card contract;
  all intelligence, grounding, and persistence live in the backend *(see
  [ai-agent.md](./ai-agent.md) "Client Rendering")*.

---

## End-to-End Flows

These five flows are the spine of the system; each crosses several subsystems, so the
cross-references below point to where each step is documented in depth.

### 1. Booking + Payment

1. **Discover** — patient browses `/public/labs` or `/public/tests/by-name`, picks a lab+test,
   and lands on the booking screen *(client: [frontend.md](./frontend.md) `/booking`,
   [mobile.md](./mobile.md) booking flow)*.
2. **Check availability** — `GET /bookings/availability` returns open future slots (resolved
   in UTC to avoid Cairo-timezone mis-bucketing), excluding slots with active bookings.
3. **Create booking** — `POST /bookings` runs the business-rule chain: capability checks for
   home modes, payment-method/booking-type compatibility, pricing (test + home/kit surcharge),
   and an atomic `$transaction` that relies on the `schedule_slot_id @unique` constraint to
   prevent double-booking (Prisma `P2002` → friendly conflict). It writes the first
   `BookingStatusEvent` and pushes "New Booking" to the lab *(see [backend.md](./backend.md)
   §6.2, [data-model.md](./data-model.md) Booking)*.
4. **Pay** —
   - *Online:* `POST /bookings/:id/demo-online-payment` simulates a gateway, setting
     `payment_status = Paid|Failed` with reference/timestamps. A lab cannot confirm an online
     booking until it is `Paid`.
   - *Cash:* the lab later calls `mark-cash-collected`. Cash bookings can be confirmed before
     collection.
   *(see [backend.md](./backend.md) §6.3)*.
5. **Confirm / reject** — the lab sets `lab-status`; rejection releases the slot; both push to
   the patient.
6. **Cancel / refund** — patient cancellation from Pending/Confirmed releases the slot and, if
   already paid, transitions `payment_status → Refunded`.

### 2. Result Upload → Structured Parsing → Delivery

1. **Upload PDF** — `POST /lab/results/:bookingId/upload` validates lab ownership, enforces the
   10 MB limit and `%PDF` magic-byte check, stores the file via the pluggable
   `LabStorageService` (local disk or S3), and upserts `ResultFile` (status `Uploaded`) +
   `ResultSummary` (+ normalised `highlights`) in one transaction *(see
   [backend.md](./backend.md) §7.3, [infra.md](./infra.md) §d secure file handling)*.
2. **Add structured data** — `PUT /lab/results/:bookingId/structured` (requires the PDF first)
   posts panels of observations. For each observation, `ClinicalNormalizationService` resolves
   the analyte to a `CanonicalMarker` (explicit code → alias table → fuzzy display-name match)
   and computes `value_in_canonical_unit` with hand-coded clinical conversions (glucose
   mmol/L→mg/dL ×18; HbA1c IFCC→NGSP; creatinine µmol/L→mg/dL; TSH harmonisation). Unmapped or
   non-numeric values are flagged non-comparable so they never pollute trends *(see
   [backend.md](./backend.md) §7.4, [data-model.md](./data-model.md) marker stack)*.
3. **Deliver** — `PATCH /lab/results/:bookingId/status` to `Delivered` flips the booking to
   `Completed`, writes a status event, and pushes "Result Ready" to the patient.
4. **Consume** — the patient downloads the PDF only through the authorisation-checked
   `GET /results/files/:id` (patient/lab/admin relationship check; `nosniff`; attachment
   disposition). Mobile fetches the bytes through the authenticated Dio client and renders with
   `pdfx` / shares via `share_plus` *(see [mobile.md](./mobile.md) results feature)*. The
   structured observations now feed the patient's trends.

### 3. Lab Onboarding & Approval

1. **Register** — `POST /auth/register/lab` creates a `User` + `LabProfile` in `PendingReview`;
   the lab can authenticate but the `LabActiveGuard` blocks all operational routes *(see
   [backend.md](./backend.md) §4)*.
2. **Complete the profile** — the lab adds phone, accreditation, turnaround, ≥1 active test,
   and ≥1 active slot (the 5 readiness requirements).
3. **Admin review** — `GET /admin/workspace` shows each lab's `onboardingReadiness` (completed
   vs missing). The admin calls `PATCH /admin/labs/:id/status`. **Activation is refused** by
   `BadRequestException` if the lab is not ready, naming the missing requirements *(see
   [backend.md](./backend.md) §10)*.
4. **Go live** — once `Active`, the lab surfaces in the public marketplace (every public query
   hard-filters to `Active`), and its routes unlock. Status changes are audited. Rejected and
   Suspended are the punitive states; a redirect/`/unauthorized` flow explains the state to a
   lab user on the client *(see [frontend.md](./frontend.md) middleware,
   [mobile.md](./mobile.md) `/lab-pending`)*.

### 4. Cross-Lab Health Trends

1. **Accumulate structured results** — over time, multiple labs upload structured observations
   for a patient; each is stored in *both* raw and canonical form (Flow 2).
2. **Request trends** — `GET /patient/health-profile?range=&groupBy=` pulls comparable,
   canonical-valued observations in range, groups them into series (by analyte or lab-test),
   computes trend direction (increasing/decreasing/stable/insufficient via a 2% threshold), and
   flags each point against its converted reference range. PDF-only results are surfaced
   separately. A standing disclaimer stresses the data is informational *(see
   [backend.md](./backend.md) §7.4)*.
3. **Privacy gate for labs** — when a lab views `/lab/patient-context`, the scope is bounded by
   the patient's `lab_history_sharing`: `SAME_LAB_ONLY` shows only this lab's data;
   `FULL_HISTORY_AUTHORIZED` adds cross-lab *structured summaries and trends* but **never**
   other labs' PDFs. The response carries an explicit `privacyNotice` and effective scope *(see
   [data-model.md](./data-model.md) "Privacy Model", [backend.md](./backend.md) §7.5)*.
4. **Render** — the web uses Recharts (`HealthTrendsPanel`) and mobile uses `fl_chart`; both
   shade reference bands, colour abnormal points red, show a trend badge, and offer the same
   clinical caveats *(see [frontend.md](./frontend.md) Charts, [mobile.md](./mobile.md)
   trends)*.

### 5. AI-Assisted Lab Discovery

1. **Ask** — the patient sends a message (e.g. "where can I get a CBC in Cairo?") to
   `POST /chat/messages` with `Accept: text/event-stream` (web cookie / mobile Bearer). The
   controller opens an SSE stream and emits a `meta` event with the conversation id *(see
   [ai-agent.md](./ai-agent.md) architecture diagram)*.
2. **Stream & call tools** — `ChatService.streamReply` runs the bounded function-calling loop:
   Gemini streams text `delta`s and may emit `functionCall`s. The service runs `find_labs` /
   `search_tests` as real Prisma queries over **active labs/tests only**, emits a `tool` SSE
   event (the lab/test cards) the instant the lookup returns, and feeds a compact payload back
   to the model for a natural-language summary.
3. **Render cards** — both clients render the streamed cards as clickable items that deep-link
   into `/labs/:id` or `/tests/:name` — turning the assistant into an on-ramp to the booking
   funnel (Flow 1) *(see [ai-agent.md](./ai-agent.md) "Client Rendering")*.
4. **Persist** — the assistant message is saved with `metadata = { tools: [...] }`, so reopening
   the thread re-hydrates the same cards; conversation history is capped at 20 turns *(see
   [ai-agent.md](./ai-agent.md), [data-model.md](./data-model.md) ChatMessage)*.
5. **Fallback** — for cheap, common questions the patient can instead use the floating
   **guided-FAQ** widget, a deterministic keyword search with no model call *(see
   [ai-agent.md](./ai-agent.md) "Guided FAQ Bot")*.

---

## Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Monorepo & tooling | npm workspaces, Node 22, ESLint + Prettier | Single repo for backend/web/mobile, shared API contract *(see [infra.md](./infra.md) §a)* |
| Backend framework | NestJS 11 (Express adapter, TypeScript) | Decorator-driven REST API, modules, guards, DI *(see [backend.md](./backend.md) §1–2)* |
| ORM & migrations | Prisma 5 (`prisma-client-js`) | Type-safe data access, 10 migrations, retry middleware |
| Database | PostgreSQL (Neon serverless in prod, Docker Postgres 16 local) | 20 tables / 11 enums; same schema both environments *(see [data-model.md](./data-model.md))* |
| Auth | `@nestjs/jwt`, Passport JWT, bcrypt | 8h access JWT + SHA-256-hashed 30-day rotating refresh tokens *(see [infra.md](./infra.md) §d)* |
| File storage | `@aws-sdk/client-s3` + local-disk adapter | Result PDFs via pluggable `LabFileStorageAdapter` (S3 or disk) |
| Push notifications | `firebase-admin` (FCM) | Booking/result/review push; graceful no-op if unconfigured |
| Generative AI | `@google/genai`, model `gemini-2.5-flash` | Agentic, function-calling health assistant over SSE *(see [ai-agent.md](./ai-agent.md))* |
| Config & validation | `@nestjs/config` + Joi (backend), Zod (frontend) | Fail-fast env validation at boot/build |
| API docs | `@nestjs/swagger` | OpenAPI UI at `/api` |
| Web framework | Next.js 16 (App Router), React 19, TypeScript | Patient/Lab/Admin SPA + public storefront *(see [frontend.md](./frontend.md))* |
| Web styling | Tailwind CSS 4 (CSS-token theme), Radix UI, lucide-react | Design system, primitives, icons |
| Web charts | Recharts | Patient trends + admin analytics |
| Web auth edge | `jose` (JWT decode in Edge middleware) | Fast route-guard; same-origin `/api` rewrite for first-party cookie |
| Mobile framework | Flutter / Dart ≥ 3.5 | Native iOS/Android patient + lab app *(see [mobile.md](./mobile.md))* |
| Mobile state/DI | Riverpod | Providers, derived selectors, testable DI |
| Mobile networking | Dio (+ queued auth interceptor) | Shared client, silent refresh rotation |
| Mobile storage/security | `flutter_secure_storage`, `local_auth` | Keychain/Keystore token storage, biometric unlock |
| Mobile nav/i18n/charts | go_router, `flutter_localizations` (EN/AR), `fl_chart` | Role routing, RTL localization, trend charts |
| Mobile native | `firebase_messaging`, `geolocator`, `pdfx`, `share_plus` | Push, location, in-app PDF, native share |
| Backend hosting | Railway (primary) / Render (alternative), Nixpacks | API + auto Prisma migrate on deploy *(see [infra.md](./infra.md) §b)* |
| Web hosting | Vercel | Next.js build + `/api` reverse-proxy rewrite |
| Testing | Jest + Supertest (backend), Playwright (web), `flutter_test` + mocktail (mobile) | Per-layer test strategy *(see [infra.md](./infra.md) §e)* |

---

## Proposed Figures / Diagrams

The following figures are recommended for the project book. Each maps to material developed
in the subsystem chapters cited.

1. **System context / deployment diagram** — the three-host split (Vercel web, Railway/Render
   API, Neon DB) plus S3, FCM, Gemini, and the two clients; show the same-origin `/api` proxy.
   *(this chapter; [infra.md](./infra.md) §b–d)*
2. **High-level component / module architecture** — NestJS modules and the guard pipeline
   (JwtAuthGuard → RolesGuard → LabActiveGuard → ownership checks). *([backend.md](./backend.md)
   §2, §4)*
3. **Entity-Relationship Diagram (ERD)** — all 20 tables, with `Booking` as the hub and the
   structured-marker sub-graph. *([data-model.md](./data-model.md) "Relationships")*
4. **Use-case diagram — Patient** — browse, compare, book, pay, track, view results, view
   trends, review, chat. *([frontend.md](./frontend.md), [mobile.md](./mobile.md))*
5. **Use-case diagram — Lab Staff** — catalogue/schedule CRUD, process bookings, upload/deliver
   results, view patient context. *([backend.md](./backend.md) §7.2)*
6. **Use-case diagram — Admin** — review/activate/reject/suspend labs, view stats/analytics,
   manage users. *([backend.md](./backend.md) §10)*
7. **Sequence diagram — Booking + Payment** (online and cash branches), including the
   double-booking-prevention transaction. *([backend.md](./backend.md) §6)*
8. **Sequence diagram — Result upload → structured parsing → delivery → download.**
   *([backend.md](./backend.md) §7.3–7.4)*
9. **Sequence diagram — Agentic AI assistant** SSE function-calling loop (delta/tool/meta/done
   events; two-payload tool result). *([ai-agent.md](./ai-agent.md) "Overall Architecture")*
10. **State machine — Booking lifecycle** (Pending → Confirmed/Rejected → Completed/Cancelled)
    and the parallel `PaymentStatus` and `KitStatus` machines. *([data-model.md](./data-model.md)
    enums; [backend.md](./backend.md) §6.4)*
11. **State machine — Lab onboarding** (PendingReview → Active/Rejected/Suspended) with the
    5-point readiness gate. *([backend.md](./backend.md) §10)*
12. **Clinical-normalisation data-flow** — raw observation → canonical marker resolution → unit
    conversion → comparable trend point. *([backend.md](./backend.md) §7.4,
    [data-model.md](./data-model.md) marker stack)*
13. **Privacy-scope decision diagram** — `SAME_LAB_ONLY` vs `FULL_HISTORY_AUTHORIZED`, and why
    PDFs are always lab-private. *([data-model.md](./data-model.md) "Privacy Model")*
14. **Authentication & token-transport diagram** — web httpOnly cookie vs mobile Bearer, the
    two JWT extractors, and refresh-token rotation. *([backend.md](./backend.md) §4,
    [infra.md](./infra.md) §d)*
15. **Cross-platform parity matrix** — features × {web, mobile} (e.g. admin web-only, AI agent
    both, FAQ web-only). *([mobile.md](./mobile.md), [frontend.md](./frontend.md))*
16. **Screen-flow / navigation map** — public → auth → role dashboards for web and mobile.
    *([frontend.md](./frontend.md) route catalogue, [mobile.md](./mobile.md) screen
    catalogue)*

---

## Synthesis Summary

TesTly is a **curated, multi-actor medical lab-testing marketplace** delivered as a web app
and a native mobile app over a single NestJS/Prisma/PostgreSQL backend, with S3 storage, FCM
push, and a Gemini-powered agentic assistant as external services. Its three architectural
signatures — visible across every subsystem — are (1) **layered, defence-in-depth security**
appropriate to medical data (rotating hashed refresh tokens, stacked role/active guards,
ownership-checked PDF downloads, the same-origin cookie proxy); (2) a **clinical-normalisation
engine** that makes results comparable across labs while a patient-controlled privacy toggle
governs what labs may see; and (3) **graceful, configuration-driven flexibility** (pluggable
storage, optional push/AI, one API for two clients, local-or-Neon Postgres). The result is a
coherent, end-to-end system in which a patient can go from an AI conversation to a compared,
booked, paid, delivered, and trended test — and a lab can go from a gated registration to a
fully operational storefront — all on one curated platform.
