# TesTly — Data Model & Database

This chapter documents the persistence layer of **TesTly**, the medical lab-testing
marketplace for Egypt. It is the authoritative description of every database table,
column, relationship, enumeration, and the demonstration data the system ships with.

All facts below are derived directly from the source of truth, the Prisma schema and
its seed script:

- Schema: `apps/backend/prisma/schema.prisma`
- Seed: `apps/backend/prisma/seed.ts`
- Migration history: `apps/backend/prisma/migrations/`
- Supporting service code (cited where behaviour is enforced in application logic):
  - `apps/backend/src/api/clinical-normalization.service.ts`
  - `apps/backend/src/api/lab-patient-context.service.ts`
  - `apps/backend/src/api/patient.service.ts`
  - `apps/backend/src/api/structured-results.service.ts`

## Technology and Conventions

The database is **PostgreSQL**, accessed through the **Prisma ORM** with the
`prisma-client-js` generator (`apps/backend/prisma/schema.prisma`, lines 4–11). The
`DATABASE_URL` environment variable supplies the connection string, so the same schema
can target a local Postgres instance during development and a managed Postgres in
production.

A few conventions hold across the whole schema and are worth stating once:

- **Primary keys** are `String` UUIDs generated with `@default(uuid())`. Using opaque
  UUIDs (rather than auto-increment integers) avoids leaking row counts, makes IDs safe
  to expose in URLs, and lets records be created client- or service-side without a
  round trip to reserve an ID.
- **Timestamps** are standardised: most tables carry `created_at DateTime @default(now())`
  and `updated_at DateTime @updatedAt`. The `@updatedAt` attribute makes Prisma stamp the
  modification time automatically on every write.
- **Snake_case** is used for column names (`patient_profile_id`, `total_price_egp`),
  while relation accessors keep readable names. This keeps the SQL schema idiomatic for
  Postgres while the TypeScript surface stays ergonomic.
- **Money** is always stored as integer **EGP** (Egyptian pounds) in fields suffixed
  `_egp` (e.g. `price_egp`, `total_price_egp`). Storing whole pounds as integers avoids
  floating-point rounding errors in pricing and is appropriate for a market where prices
  are quoted in round pound amounts.
- **Indexes** are declared with `@@index` on the columns the application filters or sorts
  by most often (city, rating, scheduled time, foreign keys used for trending). These are
  discussed per-model below.

The schema has evolved through ten migrations, which tell the story of the project's
phases: `20260326120000_init_full_schema` (the foundation), `..._phase5_structured_results`
(the cross-lab marker stack), `..._phase6_lab_history_sharing` (the privacy toggle),
`..._add_booking_payment_fields`, `..._add_lab_coordinates`, `..._add_home_test_kit`,
`..._add_city_to_lab_profile`, `..._add_search_indexes`, `..._add_chat_models`, and
`..._add_chat_message_metadata`. The `migration_lock.toml` pins the provider to
`postgresql`.

---

## Entity Catalogue

The schema defines **20 models** (tables) and **11 enums**. The models can be grouped
into six functional clusters:

1. **Identity & accounts** — `User`, `PatientProfile`, `LabProfile`
2. **Catalogue & scheduling** — `LabTest`, `LabScheduleSlot`
3. **Transactions** — `Booking`, `BookingStatusEvent`
4. **Results** — `ResultFile`, `ResultSummary`, and the structured-results stack
   `ResultPanel`, `ResultObservation`, `CanonicalMarker`, `MarkerAlias`
5. **Trust, content & auth plumbing** — `Review`, `FaqEntry`, `RefreshToken`, `DeviceToken`
6. **AI assistant** — `Conversation`, `ChatMessage`

Each model is described in full below.

### User (identity root)

`schema.prisma` lines 13–28. The central account table. Every human or organisation that
authenticates is a `User`.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `email` | `String @unique` | login identifier; uniqueness enforced at DB level |
| `password_hash` | `String` | bcrypt hash (never the plaintext password) |
| `role` | `Role @default(Patient)` | one of `Patient`, `LabStaff`, `Admin` |
| `created_at` / `updated_at` | `DateTime` | standard timestamps |

Relations (one-to-optional / one-to-many):

- `patient_profile PatientProfile?` — present when the user is a patient
- `lab_profile LabProfile?` — present when the user is lab staff
- `status_events BookingStatusEvent[]` — audit events this user authored (as actor)
- `result_files ResultFile[] @relation("ResultFilesUploadedBy")` — result PDFs this user uploaded
- `refresh_tokens RefreshToken[]` — issued JWT refresh tokens
- `device_tokens DeviceToken[]` — FCM push tokens for this user's devices
- `conversations Conversation[]` — AI assistant threads owned by the user

**Design intent.** A single `User` table with a `role` discriminator keeps authentication
uniform: one login flow, one password-hash column, one set of refresh tokens, regardless
of whether the account is a patient, a lab, or an admin. Role-specific data is pushed into
*profile* tables (`PatientProfile`, `LabProfile`) that are optional one-to-one extensions.
This is a clean separation between "who can log in" and "what kind of actor they are."

### PatientProfile

`schema.prisma` lines 98–111. Extends a `User` with patient demographics and the
privacy preference.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `user_id` | `String @unique` | FK to `User`; `@unique` enforces strict one-to-one |
| `full_name` | `String?` | optional — filled during onboarding |
| `phone` | `String?` | optional |
| `address` | `String?` | optional default home address |
| `lab_history_sharing` | `LabHistorySharing @default(SAME_LAB_ONLY)` | privacy toggle (see Privacy Model) |
| `created_at` / `updated_at` | `DateTime` | |

Relations: `user` (back to `User`), `bookings Booking[]`, `reviews Review[]`.

**Design intent.** Demographics are nullable so a patient can register with just an
email/password and complete their profile later. The `lab_history_sharing` field defaults
to the most private setting (`SAME_LAB_ONLY`) — a privacy-by-default posture appropriate
for medical data.

### LabProfile

`schema.prisma` lines 113–140. The lab vendor's storefront record: identity, location,
capabilities, onboarding state, and denormalised rating.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `user_id` | `String @unique` | FK to `User`; one-to-one |
| `lab_name` | `String` | required display name |
| `phone` | `String?` | |
| `address` | `String` | required street address |
| `accreditation` | `String?` | e.g. "NABL, CAP, ISO, JCI" |
| `turnaround_time` | `String?` | human-readable, e.g. "24 hours" |
| `home_collection` | `Boolean @default(false)` | offers at-home sample collection |
| `home_test_kit` | `Boolean @default(false)` | offers mail-in self-collection kits |
| `onboarding_status` | `LabOnboardingStatus @default(PendingReview)` | admin moderation gate |
| `city` | `String?` | indexed; used for the city filter/search |
| `latitude` | `Float?` | geo coordinate for map / distance |
| `longitude` | `Float?` | geo coordinate |
| `rating_average` | `Float?` | denormalised mean of published review ratings |
| `review_count` | `Int @default(0)` | denormalised count of published reviews |
| `created_at` / `updated_at` | `DateTime` | |

Relations: `user`, `tests LabTest[]`, `schedule_slots LabScheduleSlot[]`,
`bookings Booking[]`, `reviews Review[]`.

Indexes: `@@index([city])` and `@@index([rating_average])`.

**Design intent.** Three points stand out:

- **Onboarding gate.** A lab cannot transact until an admin moves it from `PendingReview`
  to `Active`. `Rejected` and `Suspended` are terminal/punitive states. This makes the
  marketplace a *curated* one rather than open self-service — important for medical trust.
- **Geo fields.** `latitude`/`longitude` plus the indexed `city` support the two ways
  patients find labs: by city filter and by map proximity. The coordinates were added in
  the `add_lab_coordinates` migration.
- **Denormalised rating.** `rating_average` and `review_count` are *cached* aggregates so
  that lab listing and search do not have to aggregate the `Review` table on every read.
  The seed (and, in production, the review service) recomputes them from the source rows
  whenever reviews change — a classic read-optimisation trade-off. The
  `@@index([rating_average])` lets the listing page sort by rating cheaply.

### LabTest

`schema.prisma` lines 142–158. A single test offered by a specific lab, with that lab's
own price. Tests are **per-lab**, not global — the same conceptual test ("CBC") exists as
many `LabTest` rows, one per lab, each with its own price.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `lab_profile_id` | `String` | FK to `LabProfile` |
| `name` | `String` | e.g. "Complete Blood Count (CBC)" |
| `category` | `String` | e.g. "Blood Tests", "Diabetes", "Tumor Markers" |
| `price_egp` | `Int` | this lab's price in EGP |
| `description` | `String?` | patient-facing explanation |
| `preparation` | `String?` | e.g. "Fasting for 8-12 hours required" |
| `turnaround_time` | `String?` | per-test override of the lab default |
| `parameters_count` | `Int?` | number of analytes the test reports |
| `is_active` | `Boolean @default(true)` | soft enable/disable for the catalogue |
| `created_at` / `updated_at` | `DateTime` | |

Relations: `lab_profile`, `bookings Booking[]`.

**Design intent.** Modelling tests per-lab is the core of a *marketplace*: it lets each
lab set independent pricing and lets the comparison UI show "CBC at 5 labs, prices 280–440
EGP." `is_active` allows a lab to retire a test without deleting historical bookings that
reference it.

### LabScheduleSlot

`schema.prisma` lines 160–174. A bookable time window at a lab.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `lab_profile_id` | `String` | FK to `LabProfile` |
| `starts_at` | `DateTime` | slot start |
| `ends_at` | `DateTime` | slot end (seed uses 30-minute windows) |
| `capacity` | `Int @default(1)` | how many bookings the slot accepts |
| `is_active` | `Boolean @default(true)` | |
| `created_at` / `updated_at` | `DateTime` | |

Relation: `lab_profile`, and `booking Booking?` — a back-relation to the at-most-one
booking that claimed this slot.

Index: `@@index([lab_profile_id, starts_at])` — the exact shape of "show this lab's
available slots in time order."

**Design intent.** Slots decouple a lab's availability from individual bookings. The
one-to-one `Booking.schedule_slot` link (with `@unique` on the booking side) means a slot
can be claimed by at most one booking, giving simple, race-free reservation semantics for
the default `capacity = 1` case.

### Booking (the central transaction)

`schema.prisma` lines 176–213. The most important table: a patient's order for one test
at one lab, carrying the full payment and (for kits) shipment lifecycle.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `patient_profile_id` | `String` | FK to `PatientProfile` |
| `lab_profile_id` | `String` | FK to `LabProfile` |
| `lab_test_id` | `String` | FK to `LabTest` |
| `booking_type` | `BookingType` | `LabVisit` / `HomeCollection` / `HomeTestKit` |
| `status` | `BookingStatus @default(Pending)` | lifecycle state |
| `scheduled_at` | `DateTime` | appointment time |
| `home_address` | `String?` | required for home collection/kit delivery |
| `total_price_egp` | `Int` | price charged (test price + any fees, e.g. +100 home fee) |
| `payment_method` | `PaymentMethod @default(Online)` | how the patient pays |
| `payment_status` | `PaymentStatus @default(Pending)` | payment lifecycle |
| `payment_reference` | `String?` | gateway/transaction reference |
| `payment_paid_at` | `DateTime?` | when payment cleared |
| `payment_failed_at` | `DateTime?` | when payment failed |
| `payment_failure_reason` | `String?` | failure detail |
| `kit_status` | `KitStatus?` | only set for `HomeTestKit` bookings |
| `kit_tracking_number` | `String?` | courier tracking number |
| `kit_shipped_at` | `DateTime?` | |
| `kit_delivered_at` | `DateTime?` | |
| `sample_received_at` | `DateTime?` | when the lab received the returned sample |
| `created_at` / `updated_at` | `DateTime` | |

Relations:

- `patient_profile`, `lab_profile`, `lab_test` — the three parties to the order
- `status_events BookingStatusEvent[]` — the audit trail of status transitions
- `result_file ResultFile?` — at most one uploaded PDF
- `result_summary ResultSummary?` — at most one plain-language summary
- `result_panels ResultPanel[]` — structured, machine-readable results
- `review Review?` — at most one review (one review per booking)
- `schedule_slot_id String? @unique` + `schedule_slot LabScheduleSlot?` — the optional
  claimed slot (unique → one booking per slot)

Indexes: `@@index([lab_profile_id, scheduled_at])` (lab calendar / dashboard) and
`@@index([patient_profile_id, scheduled_at])` (patient's booking history in time order).

**Design intent.** The `Booking` table deliberately carries three parallel concerns in
one row:

1. **The order itself** — who, which lab, which test, when, how much.
2. **Payment tracking** — method, status, and a set of dedicated timestamp/reason fields
   so that a failed online payment (`payment_status = Failed`, `payment_failure_reason`,
   `payment_failed_at`) is fully auditable. Added in the `add_booking_payment_fields`
   migration. The four `PaymentMethod` values cover both online (Paymob-style) and the
   three cash-settlement modes common in Egypt (cash at the lab, cash to the home
   collector, cash on kit delivery).
3. **Kit logistics** — the `kit_*` and `sample_received_at` fields form a mini shipping
   workflow that only applies when `booking_type = HomeTestKit`. They are all nullable so
   that lab-visit and home-collection bookings simply leave them empty. Added in the
   `add_home_test_kit` migration.

Keeping these in one table (rather than separate Payment and Shipment tables) is a
pragmatic choice for a project of this size: a booking always has exactly one payment and
at most one kit shipment, so a 1:1 split would add joins without adding flexibility.

### BookingStatusEvent (audit trail)

`schema.prisma` lines 280–292. An append-only log of every status change on a booking.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `booking_id` | `String` | FK to `Booking` |
| `status` | `BookingStatus` | the status the booking moved *into* |
| `note` | `String?` | human note, e.g. "Lab confirmed booking" |
| `actor_user_id` | `String?` | who performed the transition (null = system) |
| `created_at` | `DateTime @default(now())` | when |

Relations: `booking`, `actor_user User?`. Index: `@@index([booking_id, created_at])` —
fetch a booking's history in chronological order.

**Design intent.** This is an immutable event log. `Booking.status` holds the *current*
state for fast reads; `BookingStatusEvent` preserves *how it got there* and *who did it*,
which matters for dispute resolution and accountability in a medical/payment context. A
`null actor_user_id` records automatic transitions — e.g. the seed's failed-payment
booking is cancelled by the system with `actor_user_id: null`.

### ResultFile (the official PDF)

`schema.prisma` lines 294–307. The lab's uploaded result document for a booking.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `booking_id` | `String @unique` | one file per booking |
| `status` | `ResultStatus @default(Pending)` | `Pending` / `Uploaded` / `Delivered` |
| `file_name` | `String` | original filename |
| `file_url` | `String` | storage URL/path |
| `mime_type` | `String` | e.g. `application/pdf` |
| `size_bytes` | `Int` | |
| `uploaded_at` | `DateTime @default(now())` | |
| `uploaded_by_user_id` | `String?` | the lab-staff user who uploaded |

Relations: `booking`, `uploaded_by_user User?` (named relation `ResultFilesUploadedBy`).

**Design intent.** `booking_id @unique` enforces one canonical result file per order.
The file is served through an authorised endpoint (the application maps a download URL of
the form `/results/files/{resultFile.id}`, see `lab-patient-context.service.ts`), not by
exposing the raw `file_url`, which is central to the privacy model below (other labs never
get another lab's PDF).

### ResultSummary (plain-language summary)

`schema.prisma` lines 309–318. A human-readable summary of a booking's results, plus
optional structured highlights.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `booking_id` | `String @unique` | one summary per booking |
| `summary` | `String` | prose summary, e.g. "CBC within normal ranges." |
| `highlights` | `Json?` | optional key/value highlights, e.g. `{ hemoglobin: "13.4 g/dL" }` |
| `created_at` / `updated_at` | `DateTime` | |

Relation: `booking`.

**Design intent.** This is the patient-friendly layer over a raw PDF — a short narrative
plus a flexible `Json` bag of headline numbers. The `Json` type is chosen for `highlights`
precisely because the salient values differ from test to test (a thyroid panel and a CBC
highlight different markers).

---

## The Structured-Results / Cross-Lab Marker Stack

This is the most architecturally interesting part of the schema, introduced in the
`phase5_structured_results` migration. Its purpose: **let a patient (and authorised labs)
see trends for a marker — say fasting glucose — across results from *different* labs,
even though every lab names and units its analytes slightly differently.** A PDF alone
can't be trended; structured observations can.

Four tables collaborate: `ResultPanel`, `ResultObservation`, `CanonicalMarker`,
`MarkerAlias`.

### CanonicalMarker (the normalisation anchor)

`schema.prisma` lines 215–229. *"Canonical analyte for cross-lab trending (one
patient-centered code, many raw names)."*

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `code` | `String @unique` | stable internal code, e.g. `GLUCOSE_FASTING`, `HBA1C`, `TSH` |
| `display_name` | `String` | patient-facing name, e.g. "Fasting glucose" |
| `category` | `String?` | e.g. "chemistry", "thyroid", "diabetes" (indexed) |
| `default_unit` | `String?` | the canonical unit, e.g. "mg/dL", "%", "mIU/L" |
| `loinc_code` | `String?` | optional LOINC standard code for interoperability |
| `created_at` | `DateTime` | |

Relations: `aliases MarkerAlias[]`, `observations ResultObservation[]`. Index:
`@@index([category])`.

**Design intent.** A `CanonicalMarker` is the *single identity* of a clinical analyte
inside TesTly. Its `code` is the join key that ties together observations from many labs.
`default_unit` defines the unit everything is normalised *to*. The optional `loinc_code`
field anchors each marker to **LOINC** (Logical Observation Identifiers Names and Codes),
the international standard for identifying lab observations — present so the platform can
later interoperate with external health systems even though the seed does not populate it.

### MarkerAlias (raw-name → canonical mapping)

`schema.prisma` lines 231–240. *"Maps normalized raw names from lab reports to a
canonical marker."*

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `canonical_marker_id` | `String` | FK to `CanonicalMarker` (`onDelete: Cascade`) |
| `alias_normalized` | `String @unique` | a normalised raw name, e.g. "fasting blood sugar", "fbs" |

Relation: `canonical_marker`. Index: `@@index([canonical_marker_id])`.

**Design intent.** Different labs print "Fasting glucose", "Fasting Blood Sugar", or
"FBS" for the same analyte. `MarkerAlias` is the lookup table that collapses all of these
to one `CanonicalMarker`. The aliases are stored already *normalised*: lowercased, accent-
stripped, punctuation-collapsed to single spaces. The normalisation function lives in
`clinical-normalization.service.ts` (`normalizeKey`), and the resolution order
(`resolveCanonicalMarker`) is: (1) explicit canonical code if provided, then (2) exact
alias match on the normalised name, then (3) match against a canonical marker's normalised
`display_name`. The `@unique` on `alias_normalized` guarantees each spelling maps to
exactly one marker.

### ResultPanel (a grouping of observations under a booking)

`schema.prisma` lines 242–255. *"A logical panel (e.g. chemistry, thyroid) under one
booking; holds structured observations."*

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `booking_id` | `String` | FK to `Booking` (`onDelete: Cascade`) |
| `name` | `String?` | e.g. "Metabolic panel", "Chemistry" |
| `test_date` | `DateTime` | the date the sample was analysed (drives trending) |
| `sort_order` | `Int @default(0)` | display ordering |

Relations: `booking`, `observations ResultObservation[]`. Indexes: `@@index([booking_id])`
and `@@index([booking_id, test_date])`.

**Design intent.** A panel is the structured counterpart of a section in the PDF. Its
`test_date` (separate from `Booking.scheduled_at`) is the temporal axis for trend charts.
`onDelete: Cascade` means deleting a booking automatically removes its panels and
(transitively) observations.

### ResultObservation (one measured value)

`schema.prisma` lines 257–278. A single analyte reading, holding both the raw lab value
and its normalised, comparable form.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `panel_id` | `String` | FK to `ResultPanel` (`onDelete: Cascade`) |
| `canonical_marker_id` | `String?` | FK to `CanonicalMarker` (`onDelete: SetNull`); null if unmatched |
| `raw_name` | `String` | the analyte name exactly as the lab wrote it |
| `value_numeric` | `Decimal? @db.Decimal(18,6)` | raw numeric value |
| `value_text` | `String?` | for non-numeric results (e.g. "Negative") |
| `unit` | `String?` | the lab's reported unit |
| `ref_low` | `Decimal? @db.Decimal(18,6)` | reference-range low |
| `ref_high` | `Decimal? @db.Decimal(18,6)` | reference-range high |
| `ref_text` | `String?` | textual reference range |
| `value_in_canonical_unit` | `Decimal? @db.Decimal(18,6)` | value converted to the canonical unit |
| `comparable_unit` | `String?` | the unit `value_in_canonical_unit` is expressed in |
| `is_comparable` | `Boolean @default(true)` | false if the unit couldn't be mapped |
| `comparability_note` | `String?` | explanation, e.g. "Converted from mmol/L to mg/dL." |

Relations: `panel`, `canonical_marker`. Indexes: `@@index([panel_id])` and
`@@index([canonical_marker_id])`.

**Design intent — this is where cross-lab comparability is realised.** Each observation
stores *two* representations of the same reading:

- The **raw** form (`raw_name`, `value_numeric`/`value_text`, `unit`, `ref_*`) — exactly
  what the lab reported, never lost.
- The **canonical** form (`canonical_marker_id`, `value_in_canonical_unit`,
  `comparable_unit`, `is_comparable`, `comparability_note`) — the value re-expressed in
  the canonical marker's unit so it can be plotted against readings from other labs.

The conversion logic lives in `clinical-normalization.service.ts` (`toCanonicalValue`).
Concrete examples baked into that service and demonstrated in the seed:

- **Glucose:** `mmol/L` is multiplied by 18 to get `mg/dL`. The seed's past booking stores
  a 5.4 mmol/L reading with `value_in_canonical_unit = 5.4 × 18` and the note "Converted
  from mmol/L to mg/dL."
- **HbA1c:** IFCC `mmol/mol` is converted to NGSP `%` via `(value + 23.5) / 10.93`.
- **TSH:** several equivalent unit spellings (`mIU/L`, `µIU/mL`, `uIU/mL`, `mU/L`) are all
  accepted as the same canonical `mIU/L`.

When a unit is *not* recognised, `is_comparable` is set to `false` and a
`comparability_note` explains why — so the UI can still show the raw value but knows not to
put it on a shared trend line. `Decimal(18,6)` is used (rather than float) for clinical
precision; `onDelete: SetNull` on `canonical_marker_id` means deleting a marker definition
does not destroy the underlying observations, it merely un-links them.

---

## Reviews, Content, Auth Plumbing, and the AI Assistant

### Review

`schema.prisma` lines 320–334. A patient's rating of a lab, tied to a specific completed
booking.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `booking_id` | `String @unique` | one review per booking |
| `patient_profile_id` | `String` | FK to author |
| `lab_profile_id` | `String` | FK to reviewed lab |
| `rating` | `Int` | 1–5 stars |
| `comment` | `String?` | optional prose |
| `status` | `ReviewStatus @default(Pending)` | moderation: `Pending` / `Published` / `Rejected` |
| `created_at` / `updated_at` | `DateTime` | |

Relations: `booking`, `patient_profile`, `lab_profile`.

**Design intent.** `booking_id @unique` ties every review to a real, completed
transaction — you cannot review a lab you never used, and you cannot review it twice for
the same booking. This is the anti-spam / authenticity guarantee for the rating system.
Reviews start `Pending` and only `Published` ones feed the lab's `rating_average` and
`review_count` (the seed explicitly aggregates only `status: Published` rows).

### FaqEntry

`schema.prisma` lines 336–345. Static help content.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `question` | `String` | |
| `answer` | `String` | |
| `category` | `String?` | e.g. "Preparation", "Results", "Privacy" |
| `tags` | `String[]` | Postgres text array for keyword filtering |
| `is_active` | `Boolean @default(true)` | |
| `created_at` / `updated_at` | `DateTime` | |

**Design intent.** A standalone, relationless content table powering an FAQ/help page and
feeding the AI assistant's knowledge. `tags String[]` uses Postgres native arrays for
lightweight keyword search.

### RefreshToken

`schema.prisma` lines 347–358. Server-side record of issued JWT refresh tokens for
rotation/revocation.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `user_id` | `String` | FK to `User` (`onDelete: Cascade`) |
| `token_hash` | `String @unique` | hash of the refresh token (never the token itself) |
| `expires_at` | `DateTime` | |
| `revoked` | `Boolean @default(false)` | supports logout / forced invalidation |
| `created_at` | `DateTime` | |

Relation: `user`. Index: `@@index([user_id])`.

**Design intent.** Storing only a **hash** of the refresh token means a database leak does
not hand attackers usable tokens. `revoked` enables logout-everywhere and token rotation.
`onDelete: Cascade` cleans up tokens when a user is deleted.

### DeviceToken

`schema.prisma` lines 360–371. Push-notification registration.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `user_id` | `String` | FK to `User` (`onDelete: Cascade`) |
| `fcm_token` | `String @unique` | Firebase Cloud Messaging token |
| `platform` | `String` | e.g. "ios", "android", "web" |
| `created_at` / `updated_at` | `DateTime` | |

Relation: `user`. Index: `@@index([user_id])`.

**Design intent.** One row per device, keyed by a unique FCM token, so the backend can
push booking/result notifications to all of a user's devices.

### Conversation & ChatMessage (AI assistant)

Added in the `add_chat_models` and `add_chat_message_metadata` migrations.

`Conversation` (`schema.prisma` lines 379–390) — *"A single AI assistant conversation
thread owned by a user."*

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `user_id` | `String` | FK to `User` (`onDelete: Cascade`) |
| `title` | `String?` | optional auto/derived title |
| `created_at` / `updated_at` | `DateTime` | |

Relation: `user`, `messages ChatMessage[]`. Index: `@@index([user_id, updated_at])`
(list a user's threads, most recently active first).

`ChatMessage` (`schema.prisma` lines 393–406) — *"One message (from the patient or the
assistant) within a conversation."*

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, PK) | |
| `conversation_id` | `String` | FK to `Conversation` (`onDelete: Cascade`) |
| `role` | `ChatRole` | `User` or `Assistant` |
| `content` | `String` | the message text |
| `metadata` | `Json?` | structured agentic payload, shaped `{ tools: ToolResult[] }` |
| `created_at` | `DateTime` | |

Relation: `conversation`. Index: `@@index([conversation_id, created_at])` (replay a thread
in order).

**Design intent.** This is a standard conversational-memory model. The notable field is
`metadata Json?`: when the assistant surfaces *agentic* results — e.g. lab cards or test
cards it pulled from the catalogue — those structured payloads ride along in `metadata` as
`{ tools: ToolResult[] }`, while plain replies leave it null. This lets the frontend re-
render rich cards from history rather than only flat text.

---

## The Privacy Model (SAME_LAB_ONLY vs FULL_HISTORY_AUTHORIZED)

This is a defining feature of TesTly and is implemented by the `LabHistorySharing` enum on
`PatientProfile.lab_history_sharing` (`schema.prisma` lines 90–96, 104). The schema even
documents it inline:

- **`SAME_LAB_ONLY`** (the default): *"Only bookings and results from this lab (default,
  privacy-first)."* A lab a patient is currently transacting with can see **only** that
  patient's bookings and results **at that same lab** — nothing from any other lab.
- **`FULL_HISTORY_AUTHORIZED`**: *"Patient opted in: labs with any booking may see cross-
  lab structured summaries and history (not other labs' PDFs)."* The patient has chosen to
  let any lab they have a booking with see their *cross-lab structured history and
  summaries* — but crucially **never another lab's raw PDF document**.

**How it is enforced (HOW).** The logic lives in
`apps/backend/src/api/lab-patient-context.service.ts`. When a lab requests a patient's
context:

1. The service reads `patient.lab_history_sharing` and sets
   `fullHistory = (sharing === FULL_HISTORY_AUTHORIZED)`.
2. It builds the booking query's `where` clause conditionally
   (`lab-patient-context.service.ts` ~lines 65–69): if `fullHistory`, it filters by
   `patient_profile_id` only (all labs); otherwise it adds
   `lab_profile_id: labProfile.id`, hard-limiting the result set to *this lab's* bookings
   at the database level.
3. For each prior booking, prose summaries and structured marker summaries are only
   included when `fullHistory || isThisLab`.
4. **PDFs are always restricted.** A download link is produced *only* when
   `pdfAvailable = isThisLab && ...` — i.e. a lab can fetch the official PDF only for its
   *own* uploads, even in full-history mode. Other labs' documents are never exposed.
5. The response carries an explicit `privacyNotice` string and an
   `effectiveScopeForThisLab` of `'full_history'` or `'same_lab'`, so the UI is honest
   with the lab about what it is and isn't seeing.

**Why it is designed this way.** Medical data is sensitive, and the natural default for a
multi-lab marketplace is leakage between competitors. TesTly inverts that: privacy-by-
default (`SAME_LAB_ONLY`), patient-controlled opt-in, and even when the patient opts in,
the platform shares only *normalised structured trends and summaries* (which is what's
clinically useful for cross-lab comparison) while keeping each lab's *original document* to
itself. The patient toggles this from their profile; the write path is in
`patient.service.ts` (the `labHistorySharing` field is read and updated there). This is
exactly why the structured-results stack exists — it produces a comparable, shareable
representation that does not require handing over another lab's PDF.

---

## Enumerations (complete list)

All 11 enums from `schema.prisma`:

| Enum | Values | Used by | Meaning |
|---|---|---|---|
| `Role` | `Patient`, `LabStaff`, `Admin` | `User.role` | account type / authorisation level |
| `LabOnboardingStatus` | `PendingReview`, `Active`, `Rejected`, `Suspended` | `LabProfile.onboarding_status` | admin moderation state of a lab; only `Active` labs can transact |
| `BookingType` | `LabVisit`, `HomeCollection`, `HomeTestKit` | `Booking.booking_type` | how the sample is collected (`HomeTestKit` added later, triggers the kit-tracking fields) |
| `KitStatus` | `AwaitingShipment`, `Shipped`, `Delivered`, `SampleReceived` | `Booking.kit_status` | shipping lifecycle of a mail-in test kit |
| `BookingStatus` | `Pending`, `Confirmed`, `Rejected`, `Cancelled`, `Completed` | `Booking.status`, `BookingStatusEvent.status` | order lifecycle |
| `PaymentMethod` | `Online`, `CashHomeCollection`, `CashLabVisit`, `CashOnDelivery` | `Booking.payment_method` | settlement channel (one online, three cash modes) |
| `PaymentStatus` | `Pending`, `Paid`, `Failed`, `Refunded` | `Booking.payment_status` | payment lifecycle |
| `ResultStatus` | `Pending`, `Uploaded`, `Delivered` | `ResultFile.status` | result-file delivery state |
| `ReviewStatus` | `Pending`, `Published`, `Rejected` | `Review.status` | review moderation; only `Published` feeds ratings |
| `LabHistorySharing` | `SAME_LAB_ONLY`, `FULL_HISTORY_AUTHORIZED` | `PatientProfile.lab_history_sharing` | cross-lab privacy scope (see Privacy Model) |
| `ChatRole` | `User`, `Assistant` | `ChatMessage.role` | author of an assistant-chat message |

---

## Relationships (for drawing an ERD)

The following list captures every foreign-key relationship with its cardinality, enough to
draw a complete entity-relationship diagram.

**Identity cluster**

- `User` 1 — 0..1 `PatientProfile` (via `PatientProfile.user_id @unique`)
- `User` 1 — 0..1 `LabProfile` (via `LabProfile.user_id @unique`)
- `User` 1 — 0..N `RefreshToken`, `DeviceToken`, `Conversation` (all cascade-delete with user)
- `User` 1 — 0..N `BookingStatusEvent` (as `actor_user`, optional)
- `User` 1 — 0..N `ResultFile` (as `uploaded_by_user`, optional, named `ResultFilesUploadedBy`)

**Catalogue & scheduling**

- `LabProfile` 1 — 0..N `LabTest`
- `LabProfile` 1 — 0..N `LabScheduleSlot`
- `LabProfile` 1 — 0..N `Booking`
- `LabProfile` 1 — 0..N `Review`

**Transactions**

- `PatientProfile` 1 — 0..N `Booking`
- `PatientProfile` 1 — 0..N `Review`
- `LabTest` 1 — 0..N `Booking`
- `LabScheduleSlot` 1 — 0..1 `Booking` (via `Booking.schedule_slot_id @unique`)
- `Booking` 1 — 0..N `BookingStatusEvent`
- `Booking` 1 — 0..1 `ResultFile` (via `ResultFile.booking_id @unique`)
- `Booking` 1 — 0..1 `ResultSummary` (via `ResultSummary.booking_id @unique`)
- `Booking` 1 — 0..N `ResultPanel` (cascade delete)
- `Booking` 1 — 0..1 `Review` (via `Review.booking_id @unique`)

**Structured results**

- `ResultPanel` 1 — 0..N `ResultObservation` (cascade delete)
- `CanonicalMarker` 1 — 0..N `MarkerAlias` (cascade delete)
- `CanonicalMarker` 1 — 0..N `ResultObservation` (via `canonical_marker_id`, `onDelete: SetNull`)

**AI assistant**

- `Conversation` 1 — 0..N `ChatMessage` (cascade delete)

**Junction-of-three note for the ERD:** `Booking` is the hub of the diagram. It points to
three parents (`PatientProfile`, `LabProfile`, `LabTest`), optionally claims one
`LabScheduleSlot`, and owns five child clusters (status events, result file, result
summary, result panels, review). `PatientProfile` and `LabProfile` each hang off a single
`User`. The marker stack is its own small sub-graph that connects back to the booking only
through `ResultPanel → Booking`.

---

## Seed / Demo Data Overview

`apps/backend/prisma/seed.ts` is a destructive, idempotent seed: `main()` first deletes
every table in dependency order (lines 932–946) and then rebuilds a complete, realistic
demonstration dataset. (The accompanying `seed.js`, `seed.d.ts`, `seed.js.map` files are
just compiled artefacts of this TypeScript source.) Every account uses the same bcrypt-
hashed password, `password123` (line 948). What it creates:

### Accounts

- **1 Admin** — `admin@testly.com` (lines 951–953).
- **1 primary demo patient — "Mazen Amir"** — `patient@testly.com`, with a full
  `PatientProfile` (lines 956–970). Mazen is the protagonist of the demo bookings.
- **3 additional review patients** — Ahmed Khalil (`ahmed.khalil@testly.com`), Fatima
  Hassan (`fatima.hassan@testly.com`), Omar Samir (`omar.samir@testly.com`) (lines
  973–1019), each with a profile, used to seed realistic reviews.
- **2 non-active demo labs** to showcase the onboarding gate: "Pending Lab (Demo)"
  (`pendinglab@testly.com`, `PendingReview`) and "Rejected Lab Example"
  (`rejectedlab@testly.com`, `Rejected`) (lines 1022–1060).
- **21 active labs** across **11 Egyptian cities** (lines 1062–1097, data at 23–351):
  Cairo (5), Giza (2), Alexandria (3), Ismailia (2), Port Said (1), Suez (1), Mansoura
  (2), Tanta (1), Zagazig (1), Assiut (1), Luxor (1), Aswan (1). Each lab carries a real
  street address, phone, latitude/longitude, accreditation string, turnaround time, and
  home-collection / home-test-kit capability flags, and is set to `onboarding_status =
  Active`. Lab login emails are derived by slugifying the lab name (e.g.
  `alborglaboratories@testly.com`).

### Catalogue, pricing tiers, and schedule

- **A 49-test master catalogue** (`testCatalog`, lines 360–806) ordered from most
  essential to specialist, spanning categories like Blood Tests, Diabetes, Hormone Tests,
  Tumor Markers, Hepatitis, Immunology, and more, each with description, preparation,
  turnaround, parameter count, and a base price in EGP.
- **Catalogue tiers.** Each lab has a `catalogTier` of `basic` / `standard` / `extended` /
  `full`, which slices the catalogue: basic gets tests 0–13 (14 tests), standard 0–27
  (28), extended 0–38 (39), full all 49 (`getTestsForTier`, lines 808–818). This models
  smaller labs offering fewer tests than flagship labs.
- **Per-lab pricing.** Each lab has a `priceMultiplier` (0.8–1.3); `tieredPrice` multiplies
  the base price and rounds to the nearest 10 EGP (lines 820–822), so the same test costs
  different amounts at different labs — the marketplace comparison story.
- **Schedule slots for the next 7 days.** For every active lab and each of its configured
  `timeSlots`, the seed creates 30-minute slots for days 1–7 (lines 1119–1137). The seed
  prints the total slot count it created.

### Canonical markers and aliases

`seedCanonicalMarkers()` (lines 884–923) upserts **7 canonical markers** —
`GLUCOSE_FASTING`, `GLUCOSE_RANDOM`, `HBA1C`, `TSH`, `FT4`, `FT3`, `CREATININE` — with
categories and default units, and **6 aliases** mapping raw spellings (e.g. "fasting blood
sugar", "fbs", "glycated hemoglobin", "thyroid stimulating hormone") to those markers.
This is the seed of the cross-lab normalisation dictionary.

### Demo bookings, results, and the full lifecycle

For **Mazen** the seed creates four bookings illustrating every branch of the lifecycle:

1. **bookingOne** — `LabVisit` at Al Borg Cairo, `Confirmed`, paid by `CashLabVisit`
   (`Paid`, reference `SEED-DEMO-CASH-LAB`), claims a real schedule slot. It receives a
   `ResultFile` (`Uploaded`), a `ResultSummary` ("CBC within normal ranges") with `Json`
   highlights, and a structured `ResultPanel` "Metabolic panel" containing two
   observations (fasting glucose 102 mg/dL, HbA1c 5.4 %), both normalised and comparable.
   Mazen also leaves a 5★ published review on it (lines 1158–1255, 1510–1519).
2. **bookingTwo** — `HomeCollection` at El Mokhtabar, `Pending`, `CashHomeCollection`
   (`Pending`), `total_price_egp = test price + 100` (the home-collection fee), with a
   `home_address` (lines 1175–1189).
3. **bookingPast** — a `Completed` `LabVisit` ~200 days ago, demonstrating historical data
   and unit conversion: its `ResultPanel` "Chemistry" stores a glucose reading of
   5.4 **mmol/L** with `value_in_canonical_unit = 5.4 × 18 = 97.2 mg/dL` and the note
   "Converted from mmol/L to mg/dL." (lines 1258–1325).
4. **failedBooking** — a `Cancelled` `LabVisit` paid `Online` with `payment_status =
   Failed` (reference `SEED-FAILED-PAYMOB`), whose final status event is authored by the
   *system* (`actor_user_id: null`) — the automatic cancellation path (lines 1328–1349).

Each booking gets a chronological `BookingStatusEvent` trail (created → confirmed →
completed, etc.). The three secondary patients (Ahmed, Fatima, Omar) each get several
completed past bookings at named labs, each with a delivered `ResultFile` and a
**published `Review`** carrying realistic 3–5★ comments (lines 1351–1507).

### Derived data and content

- **Ratings are recomputed from real reviews.** After seeding reviews, the script
  aggregates published reviews per lab and writes back `rating_average` and `review_count`
  on each `LabProfile` (lines 1521–1535) — so the cached aggregates match the actual review
  rows.
- **6 FAQ entries** are inserted (lines 827–864, 1538–1546), covering fasting, turnaround,
  home collection, the CPC bundle, thyroid prep, and a privacy answer.
- **A minimal valid sample PDF** is generated on disk (`ensureSamplePdf` /
  `buildMinimalPdf`, lines 1553–1587) and every seeded `ResultFile.file_url` points at the
  served path `/results/files/sample-result.pdf`, so result downloads work end-to-end in
  the demo.

In short, the seed produces a fully exercisable system: an admin, a curated marketplace of
21 active labs (plus pending/rejected examples for the moderation demo), a tiered test
catalogue with per-lab pricing, a week of bookable slots, four lifecycle-spanning bookings
for the main patient (including a cross-lab unit-converted historical result), realistic
multi-patient reviews feeding live ratings, the canonical-marker normalisation dictionary,
and FAQ content.
