# TesTly — Issues & Remediation Plan

> **Purpose of this document.** The client tested the platform and reported a bad impression: search doesn't work for specific tests, searching a test shows labs instead of the test, location search does nothing, there is "a lot of demo data" everywhere, the home-vs-clinic choice is unclear, and "a lot of things are broken."
>
> This file is the result of a deep code audit (backend NestJS at `apps/backend`, frontend Next.js at `apps/frontend`). It is organized as **numbered, self-contained phases**. Each phase is written so it can be handed to a **separate Claude Code session** without needing the others. Each phase contains: the problem, the root cause (with exact file paths + line numbers), the suggested solution, the files to touch, and acceptance criteria.
>
> **Recommended order:** 6 → 1 → 2 → 3 → 4 → 5 → 8 → 7/9 → 10 → 11 → 12. (Seed first, so every other phase has realistic data to test against.) But each phase stands alone.

---

## System overview (read once)

- **Monorepo:** `apps/backend` (NestJS + Prisma + PostgreSQL/Neon), `apps/frontend` (Next.js App Router, React, Tailwind).
- **Public (unauthenticated) search APIs:**
  - `GET /public/labs` — lists/searches labs. `q` matches **lab name OR test catalog** (name/category/description). Filters: `labName`, `sort` (price|rating|distance), `minRating`, `maxDistanceKm`, `userLat`/`userLng`, `maxPriceEgp`, `homeCollection`, `accreditations`. **No address/city text filter.** File: `apps/backend/src/public/public-labs.controller.ts`.
  - `GET /public/tests` — searches/groups tests by `name`+`category`, returns cards with `labCount` and `minPriceEgp`. File: `apps/backend/src/public/public-tests.controller.ts`.
  - `GET /public/tests/:id` — single test detail (includes its lab). Same file.
- **Frontend API wrappers:** `apps/frontend/src/lib/publicApi.ts`. **Note: there is NO wrapper for `GET /public/tests` (the list/search endpoint) — it is never called by the UI.**
- **Seed data:** `apps/backend/prisma/seed.ts` — 6 labs, all in **Cairo/Giza only**, the **same 8 tests cloned to every lab**. Ratings/review counts are hardcoded. No "CPC", no Ismailia/Alexandria active labs.
- **Schema:** `apps/backend/prisma/schema.prisma`. `LabProfile` has `phone`, `address`, `latitude`, `longitude`, `rating_average`, `review_count`, `home_collection`, `home_test_kit`. The lab login email lives on the related `User.email` (there is no `email` on `LabProfile`). There is **no `city` field**.
- **Run:** `npm run dev` (both apps). Seed: `npm run db:seed`. Backend `http://localhost:3001` (Swagger `/api`), frontend `http://localhost:3000`.

---

# Phase 1 — Backend search: make test search work + add location/city filtering

**Client complaints addressed:** "search a specific test like CPC doesn't work"; "CPC " / "CPC Test" returns nothing; "search by location doesn't work."

### Problems & root causes
1. **Multi-word / phrase queries fail.** A query like `"CPC Test"` is forwarded verbatim and matched with a single `contains` against the stored test name. If the stored name is `"Complete Blood Count (CBC)"`, the phrase `"CPC Test"` (or even `"CBC Test"`) never matches because `contains` requires the whole phrase to be a substring. See `apps/backend/src/public/public-labs.controller.ts:113-119` and `apps/backend/src/public/public-tests.controller.ts:19-27`.
2. **No tokenization / per-word AND matching.** Searching `"thyroid panel"` only works if those exact characters appear contiguously. There is no splitting on whitespace, so word order and extra words break it.
3. **No location/city filter at all.** `GET /public/labs` has no `city`/`address` `contains` filter (`public-labs.controller.ts:71-83`). Typing "Cairo" or "Ismailia" goes into `q`, which only matches lab name or test catalog — never the address — so it returns nothing. Geolocation (`userLat`/`userLng`) only affects distance *sorting*, not filtering by city.
4. **Trailing-space** is handled (`.trim()` at controller level), so `"CPC "` alone is not the core issue — the phrase/word-matching is.

### Suggested solution
1. **Add per-word (tokenized) AND matching** to both `public-labs` and `public-tests` search. Split `q` on whitespace into tokens; require **every** token to match (each token `contains` any of name/category/description). Prisma shape:
   ```ts
   const tokens = q.split(/\s+/).filter(Boolean);
   const tokenFilters = tokens.map((t) => ({
     OR: [
       { name: { contains: t, mode: 'insensitive' } },
       { category: { contains: t, mode: 'insensitive' } },
       { description: { contains: t, mode: 'insensitive' } },
     ],
   }));
   // where: { AND: tokenFilters }   (when tokens.length > 0)
   ```
   This makes `"CPC Test"` match a test literally named "CPC Test", and `"thyroid panel"` match "Thyroid Panel (TSH, T3, T4)".
2. **Add a stop-word / generic-word strip** so the word "Test"/"Tests"/"Panel" doesn't over-constrain (optional but recommended): drop tokens in a small ignore-list (`['test','tests']`) *only if* other tokens remain. This makes `"CPC Test"` behave like `"CPC"`.
3. **Add a `city` query param to `GET /public/labs`** that does `address: { contains: city, mode: 'insensitive' }`. (After Phase 6 adds a real `city` column you can filter on that column instead for precision — support both: if `city` column exists, prefer it.) Add it to `baseLabWhere` in `public-labs.controller.ts:71-83`.
4. **Optionally add a combined `q` → address match**: when `q` is present, also OR-match `address contains token`, so typing a city in the main box still finds labs there. Decide with the team whether city should be a separate field or fold into `q`. Recommended: **separate `city` param** (cleaner UX, see Phase 3) **and** include address in the `q` OR.

### Files to touch
- `apps/backend/src/public/public-labs.controller.ts` (search where-clause + new `city` param + address in OR)
- `apps/backend/src/public/public-tests.controller.ts` (tokenized matching)
- Tests: `apps/backend/src/public/public-labs.controller.spec.ts` (add cases)

### Acceptance criteria
- `GET /public/tests?q=CPC%20Test` returns the CPC test (once seeded — Phase 6) — and so does `q=cpc`, `q=CPC `.
- `GET /public/labs?q=thyroid%20panel` returns labs offering the thyroid panel.
- `GET /public/labs?city=Ismailia` returns only Ismailia labs; `city=Cairo` returns Cairo labs.
- Existing single-word searches still work.

---

# Phase 2 — Frontend: search a test → show the test (with its lab) → click → test detail page

**Client complaints addressed:** "when I search a test it gives labs not the test"; "it should show the test and in which lab; clicking goes to the test page, not the lab page."

### Problems & root causes
1. **The frontend never calls `GET /public/tests`.** There is no `fetchPublicTests` wrapper in `apps/frontend/src/lib/publicApi.ts` (it only has `fetchPublicLabs`, `fetchPublicLabDetail`, `fetchPublicTest` by id). The search results page (`apps/frontend/src/teslty/components/LabComparison.tsx`) renders **lab cards only** (lines ~400-473) by calling `fetchPublicLabs`.
2. **Every result links to the lab page.** `apps/frontend/src/app/labs/LabsClient.tsx:18` — `onLabSelect` always pushes `/labs/{lab.id}`. Both the result name button and "Book Now" call it.
3. **There is no test detail route.** Routes under `apps/frontend/src/app`: `(auth)`, `admin`, `booking`, `lab`, `labs`, `labs/[labId]`, `patient`, `unauthorized`. No `tests/[id]`. `fetchPublicTest` (by id) is currently only used inside `apps/frontend/src/app/booking/BookingClient.tsx`.

### Suggested solution
1. **Add `fetchPublicTests(params)`** to `apps/frontend/src/lib/publicApi.ts` calling `GET /public/tests` (returns `{ items: [{ name, category, minPriceEgp, labCount }], pagination }`). Add a TS type for the response.
2. **Add a results "mode" or a dedicated tests results view.** Decide on UX:
   - **Recommended:** On the results page, show **two tabs/sections**: "Tests" (from `/public/tests`) and "Labs" (from `/public/labs`). When the query looks like a test, default to the Tests tab.
   - Each **test card** shows: test name, category, "from EGP X", and "Available at N labs". Clicking the card goes to the **test detail page** (next step), not a lab.
3. **Create the test detail route** `apps/frontend/src/app/tests/[testId]/page.tsx` + a client component. But note: `GET /public/tests/:id` takes a **LabTest id**, and the grouped search returns test **names**, not ids (because the same test exists at many labs). Two options:
   - **Option A (recommended): test-by-name detail page.** Add a backend endpoint `GET /public/tests/by-name?name=...&category=...` (or `GET /public/test-offers?name=...`) that returns the test's shared info (description, preparation, parameters) **plus the list of labs offering it** with each lab's price, rating, distance, home options. The test detail page shows the test at the top and a list of labs underneath; clicking a lab row → booking for that lab+test, or → lab page. This directly matches the client's ask: "show the test and in which lab."
   - **Option B:** keep `:id` and make the search return a representative `labTestId`; the detail page then shows that one offering. Less ideal (loses the multi-lab view).
4. **Wire navigation:** test card → `/tests/[idOrName]`; from test detail, "Book" → `/booking?labId=...&testId=...` (existing booking flow). Keep lab cards linking to `/labs/[labId]` as today.

### Files to touch
- `apps/frontend/src/lib/publicApi.ts` (new `fetchPublicTests`, maybe `fetchTestOffers`)
- `apps/frontend/src/teslty/components/LabComparison.tsx` (add tests view/tab + test cards) — or a new `TestComparison.tsx`
- `apps/frontend/src/app/labs/LabsClient.tsx` (route both test and lab selections)
- New: `apps/frontend/src/app/tests/[testId]/page.tsx` (+ client)
- Backend (if Option A): new endpoint in `apps/backend/src/public/public-tests.controller.ts` (`by-name` / offers)

### Acceptance criteria
- Searching "CPC" shows a **test result** card (not just labs), labeled with which/how many labs offer it.
- Clicking a test result opens a **test detail page** showing the test and the labs that offer it (with prices), **not** a lab page.
- From the test page the user can proceed to book at a chosen lab.

---

# Phase 3 — Location search UI + real distance (kill the fake distance)

**Client complaints addressed:** "search by location doesn't work"; (and the pervasive fake "X km away").

### Problems & root causes
1. **No city/location input exists anywhere in the UI.** The landing search (`apps/frontend/src/teslty/components/LandingPage.tsx`) and results search (`LabComparison.tsx`) only have a test-name box. Geolocation is requested only when `sort === 'distance'` (`LabComparison.tsx:27-39`) and only feeds `userLat`/`userLng` for sorting.
2. **Distance is faked.** `apps/backend/src/public/public-utils.ts:38-43` `placeholderDistanceKm(labId)` hashes the lab id to a 0.8–12.0 km number. Used at `public-labs.controller.ts:159` (list, when no user location) and **always** at `:288` (detail). Shown as "X km away" at `LandingPage.tsx`, `LabComparison.tsx:423`, `LabDetailsPage.tsx`. It can even wrongly filter labs out via `maxDistanceKm` (`public-labs.controller.ts:182`).

### Suggested solution
1. **Add a location input** (city dropdown or free-text) next to the search box on both the landing and results pages. Populate the city list from a real source (after Phase 6, the seed has real Egyptian cities). Pass it as the `city` param added in Phase 1.
2. **Keep the "use my location" geolocation** option for distance sorting, but only compute/show distance when **real** `userLat`/`userLng` are present AND the lab has real `latitude`/`longitude`.
3. **Remove `placeholderDistanceKm` usage.** When there is no real distance, **omit** `distanceKm` (return `null`) and **hide** the "km away" label in the UI rather than fabricating it. Do not filter by `maxDistanceKm` for labs lacking coordinates (or only apply the filter when user location is known).
4. Update `public-labs.controller.ts` (both list `:159` and detail `:288`) and frontend renderers to handle `distanceKm: null`.

### Files to touch
- `apps/backend/src/public/public-labs.controller.ts`, `apps/backend/src/public/public-utils.ts` (remove/retire placeholder)
- `apps/frontend/src/teslty/components/LandingPage.tsx`, `LabComparison.tsx`, `LabDetailsPage.tsx`
- `apps/frontend/src/lib/publicApi.ts` (add `city` param; make `distanceKm` nullable in types)

### Acceptance criteria
- A city selector exists; choosing "Ismailia" returns only Ismailia labs (works with Phase 1 + Phase 6).
- "X km away" appears **only** when the user shared location and the lab has coordinates; otherwise the label is hidden — never a hashed fake number.
- No lab is filtered out due to a fabricated distance.

---

# Phase 4 — Booking: make the Home-vs-Clinic choice clear, and fix booking bugs

**Client complaints addressed:** "when the patient decides to take the test he should choose: at home or go to the lab."

### Findings (the choice mostly exists but is hidden/confusing + has bugs)
The booking page (`apps/frontend/src/teslty/components/BookingPage.tsx`) *does* render a "Choose Collection Type" card grid (lines ~258-296), but:
1. **Home options are silently hidden** when the lab's flags are false: Home Collection card is gated on `lab.homeCollection` (`:271`), Home Test Kit on `lab.homeTestKit` (`:283`). If a lab offers neither, the user sees only "Visit Lab" with **no explanation**. Default is always Lab Visit (`:54`).
2. **No-op confirmation bug (medium).** In `apps/frontend/src/app/booking/BookingClient.tsx:85`, if `labId`/`testId` are missing the submit **returns early without throwing**, but `BookingPage.handleBooking` then still flips to the success/confirmation screen (`BookingPage.tsx:170-171`). The patient sees "Booking received" for a booking that was never created.
3. **LabVisit stores the patient's home address** in `home_address` (`apps/backend/src/bookings/bookings.service.ts:234-237`) — harmless but confusing in lab dashboards.
4. **Dead `capacity` field** — `LabScheduleSlot.capacity` exists but the slot↔booking relation is 1:1 (`schema.prisma:158,201`), so capacity > 1 is ignored.
5. **No client-side maxlength on address** (backend enforces 500; UI gives only a generic error).

> Good news (already correct, don't break): backend **enforces** booking_type against lab capabilities (`bookings.service.ts:151-157`), requires `home_address` for home/kit (`:159-165`), cross-checks payment method vs type (`:167-176`), recomputes price server-side (+100 home / +150 kit, `:220-223`), and prevents double-booking via `schedule_slot_id @unique` + a runtime conflict check.

### Suggested solution
1. **Always present the choice explicitly and legibly.** Show all three options (Lab Visit / Home Collection / Home Test Kit) but **disable** the ones the lab doesn't offer with a short note ("This lab doesn't offer home collection"), instead of hiding them. This makes the home-vs-clinic decision unmistakable — which is exactly what the client wants. Consider making it a required, un-defaulted radio (force an explicit pick) so users don't accidentally confirm Lab Visit.
2. **Fix the no-op confirmation bug:** in `BookingClient.onSubmit`, throw a user-visible error (toast) when `labId`/`testId` are missing, and do **not** show the confirmation screen unless the API call actually succeeded (await + only then `setShowConfirmation(true)`).
3. Don't write `home_address` for LabVisit (set null) — `bookings.service.ts:234-237`.
4. Add client-side `maxLength={500}` to the address textarea (`BookingPage.tsx` ~413-423).
5. (Optional) Remove or implement `capacity` honestly.

### Files to touch
- `apps/frontend/src/teslty/components/BookingPage.tsx` (choice UI, disabled states, maxlength)
- `apps/frontend/src/app/booking/BookingClient.tsx` (submit error handling, confirmation gating)
- `apps/backend/src/bookings/bookings.service.ts` (LabVisit address)

### Acceptance criteria
- On every lab's booking page the user sees a clear, explicit Home vs Clinic (vs Kit) choice; unavailable options are visibly disabled with a reason.
- A booking with missing lab/test never shows a false success screen; it shows an error.
- The confirmation screen appears only after a real successful booking.

---

# Phase 5 — Remove all demo / hardcoded / fake data from the frontend

**Client complaint addressed:** "a lot of demo data inside the website — it should all be real data, not hardcoded."

For each item: what's fake, where, and what it should be. (Backend-faked distance/emoji are covered in Phase 3 and noted below.)

### High severity (obviously fake to the user)
1. **CBC "Test Preparation / Commonly Detects" sidebar is hardcoded** and shown for *every* search. `apps/frontend/src/teslty/components/LabComparison.tsx:69-79` (`testInfo` object: always CBC description, fixed preparations, "Anemia/Infections/..."). Rendered at `:155-181`. → Should come from the actual test record (`description`, `preparation`, `parameters_count`) once the tests view exists (Phase 2). If no specific test is selected, hide the sidebar.
2. **Fake lab phone** `+20 2 1234 5678` for every lab — `apps/frontend/src/teslty/components/LabDetailsPage.tsx:173`. → Use the real `LabProfile.phone` (must be exposed by the public detail API — see Phase 7).
3. **Fake lab email** synthesized as `info@<labname>.com` — `LabDetailsPage.tsx:180`. → Use a real contact email (expose `User.email` or add `LabProfile.contact_email`; Phase 7).
4. **Fake "Available Time Slots Today"** on lab detail — generated by hashing `labId` in `apps/frontend/src/app/labs/[labId]/page.tsx:35-41`, rendered at `LabDetailsPage.tsx:184-194`. → Fetch real `LabScheduleSlot` availability (reuse `/bookings/availability` or add a public slots endpoint), or remove the section.

### Medium / low
5. **Fake "N slots today" on each lab card** — `LabComparison.tsx:137-143` (`getPlaceholderTimeSlots`), shown at `:461`. → Real availability count, or remove.
6. **Hardcoded accreditation filter list** `['NABL','CAP','ISO','JCI']` — `LabComparison.tsx:112`. → Derive distinct accreditations from the DB (small endpoint or include in a facets response).
7. **Hardcoded "Popular:" search chips** `['CBC Test','Lipid Profile','Thyroid Panel','Diabetes Screening']` — `LandingPage.tsx:185`. Note these append "Test", which triggers the search bug. → Replace with top tests from the API (or at least make them match real test names).
8. **Hardcoded surcharge constants** +EGP 100 / +EGP 150 in the UI — `BookingPage.tsx:280,292,437,443,449`. Server uses the same numbers, but they should come from config/lab so UI and server never diverge. → Source from API/config.
9. **Vague marketing claim** "Join thousands of patients…" — `LandingPage.tsx:359`. → Use a real stat or soften.
10. **Backend-faked distance + emoji avatar** — `placeholderDistanceKm` (Phase 3) and `pickEmoji` (`public-labs.controller.ts:42-46`). Emoji → replace with a real logo field or neutral initial.

### Dead mock files to delete (no live importers — verified)
- `apps/frontend/src/teslty/data/labs.ts` (205 lines of fake labs/tests — `labs`, `labTests`, `getLabById`, `getTestById`, zero importers).
- `apps/frontend/src/teslty/App.tsx`, `apps/frontend/src/teslty/components/LabDashboard.tsx`, `apps/frontend/src/teslty/components/UserDashboard.tsx` (neutered deprecated guards returning null).

### Acceptance criteria
- No screen shows hardcoded labs, tests, phone, email, slot counts, or test-prep text. Every displayed value traces to an API call.
- The dead mock files are removed and the app still builds (`npm run build` in `apps/frontend`).

---

# Phase 6 — Real seed data: Egyptian cities, real lab catalogs, real tests (incl. CPC)

**Client complaints addressed:** "all real data not demo"; "add locations like Ismailia and Cairo and a lot of Egypt labs and a lot of real tests."

### Problems & root causes
`apps/backend/prisma/seed.ts`:
- Only **6 labs, all Cairo/Giza** (`labSeedData:17-96`). No Ismailia, Alexandria, Mansoura, etc.
- The **same 8 tests are cloned to every lab** (`testCatalog:98-171`, applied at `:412-426`) — so price/availability don't vary realistically and there is no "CPC".
- `rating_average`/`review_count` are **hardcoded** per lab (`:394-395`) rather than derived (they self-correct only when a new review is added — `patient.service.ts`).
- Lab phone is the same placeholder `+20 11 0000 0000` for all (`:389`).
- Result file URLs are fake `https://example.com/...` (`:529,668`) — see Phase 8.

### Suggested solution
1. **Expand labs across many Egyptian cities** with real coordinates. Include at least: Cairo, Giza, Alexandria, **Ismailia**, Port Said, Suez, Mansoura, Tanta, Zagazig, Assiut, Luxor, Aswan. Add real, recognizable Egyptian lab brands (e.g. Al Borg, Alfa Laboratories, Cairo Scan, El Mokhtabar, Royal Lab, etc.) with proper addresses and lat/lng per city. Aim for 15–30 labs.
2. **Build a realistic, large test catalog** (30–60 tests) with correct categories, prices (EGP), preparation, turnaround, and `parameters_count`. **Include the tests the client expects, including "CPC"** (clarify with client whether CPC = a specific panel; add it explicitly), plus CBC, Lipid Profile, Thyroid Panel, LFT, KFT, HbA1c, Vitamin D/B12, CRP, ESR, Urine Analysis, Stool Analysis, PCR/COVID, Hepatitis panels, etc.
3. **Vary catalogs per lab** — give each lab a realistic subset of the catalog with **per-lab pricing** (not identical), so search results and "starting from" prices differ meaningfully.
4. **Add a `city` field** (recommended) to `LabProfile` (`schema.prisma`) via a migration, and set it per lab — enables precise city filtering (Phase 1/3). Keep `address` as the full street address.
5. **Set distinct, realistic lab phones** and decide the contact-email source (Phase 7).
6. **Generate real reviews** so `rating_average`/`review_count` are computed from actual `Review` rows (use the existing recompute logic), instead of hardcoded numbers — or at least make the hardcoded values consistent with seeded reviews.
7. **Add schedule slots for all labs** across the next several days (the current seed adds a few near-future slots only for the original 6).

### Files to touch
- `apps/backend/prisma/seed.ts` (major expansion)
- `apps/backend/prisma/schema.prisma` + new migration (if adding `city`)
- Re-run `npm run db:seed`.

### Acceptance criteria
- Labs exist in Ismailia, Cairo, Alexandria, and several other Egyptian governorates with real coordinates.
- A large, varied test catalog exists; "CPC" (and other expected tests) are searchable.
- Per-lab pricing varies; "starting from" and "from EGP X" differ across labs.
- City filtering returns the right labs.

---

# Phase 7 — Expose real lab contact info via the public API + schema additions

**Supports Phase 5 (#2/#3) and Phase 3 (#3).**

### Problem
`GET /public/labs/:id` (`apps/backend/src/public/public-labs.controller.ts:211-309`) does not return `phone`, contact email, `city`, or a logo. The frontend therefore fabricates them.

### Suggested solution
1. Return `phone` (from `LabProfile.phone`) and a **contact email** from the public lab detail endpoint. For email, either expose the related `User.email` or add a dedicated `LabProfile.contact_email` column (preferred, so login email and public email are separable) via migration.
2. Return `city` (Phase 6) and, if added, a `logo_url`.
3. Update the `PublicLabCard`/`PublicLabDetail` types in `public-labs.controller.ts` and the frontend `publicApi.ts` types accordingly. Render real values in `LabDetailsPage.tsx`.

### Acceptance criteria
- Lab detail shows the lab's **real** phone and email (no `1234 5678`, no synthesized `info@…`).

---

# Phase 8 — Result files: security + real URLs + upload limits

**Client impression: "a lot is broken" — seeded results don't open; also a real security hole.**

### Problems & root causes
1. **Seeded result PDFs point to fake URLs** `https://example.com/results/...` (`seed.ts:529,668`). Every "Open PDF" on demo results 404s. (HIGH for demo impression.)
2. **All uploaded PDFs are served publicly with no auth.** `apps/backend/src/main.ts:19` mounts `app.use('/uploads', express.static(...))`; filenames are guessable (`Date.now()-<8 chars>.pdf`, `apps/backend/src/api/lab-storage.service.ts:56`). Anyone with the URL can read another patient's medical results. (CRITICAL — security.)
3. **Upload has no size limit and trusts client mime-type.** `apps/backend/src/api/lab.controller.ts:118` uses bare `FileInterceptor('file')`; `lab.service.ts:287` checks only `mimetype.includes('pdf')` (spoofable). (HIGH.)

### Suggested solution
1. Serve result files through an **authenticated controller** that verifies the requester owns the booking (patient) or issued it (lab), instead of `express.static`. Use signed, expiring URLs if/when on S3.
2. Add `limits: { fileSize: 10*1024*1024 }` to the `FileInterceptor` and validate the file's **magic bytes** (PDF `%PDF`), not just the client mime-type.
3. Seed real, openable PDFs (bundle a sample PDF served by the app, or generate one) so demo results open.

### Files to touch
- `apps/backend/src/main.ts`, new authenticated download controller, `apps/backend/src/api/lab.controller.ts`, `apps/backend/src/api/lab-storage.service.ts`, `apps/backend/prisma/seed.ts`, frontend result links (`patient/dashboard/page.tsx:91-94`, `lab/dashboard/page.tsx:41-44`).

### Acceptance criteria
- Result PDFs open for the owning patient/lab and are **rejected (401/403)** for others.
- Oversized / non-PDF uploads are rejected with a clear error.
- Demo results open successfully.

---

# Phase 9 — Auth / route protection

### Problems & root causes
1. **Route-protection middleware never runs.** `apps/frontend/src/proxy.ts` exports `proxy()` + a matcher, but Next.js only runs middleware from `middleware.ts` at the project root. It's named `proxy.ts` and is imported nowhere (confirmed). So none of the server-side redirects for `/lab`, `/patient`, `/admin`, `/booking` execute; protection is client-side only. (HIGH — protected page shells load for unauthenticated users; data is still protected by backend guards.)
2. **Short token lifetime, no refresh.** Cookie `maxAge` 1h (`auth.controller.ts:75`) and JWT `expiresIn: '1h'` (`auth.module.ts:16`); after 1h the user is silently logged out mid-session. (MEDIUM.)
3. **Hardcoded JWT secret fallback** `|| 'super_secret'` in `auth.module.ts:16` (latent risk; env is required elsewhere). (MEDIUM.)
4. **Confusing login error** when a lab user picks "Patient" role → "Invalid credentials" instead of "wrong account type" (`auth.service.ts:94,102`). (LOW.)

### Suggested solution
1. Rename `apps/frontend/src/proxy.ts` → `apps/frontend/src/middleware.ts` and export `middleware` (verify the matcher and redirect logic still apply).
2. Add token refresh or extend lifetime, and show a "session expired" message on 401 → redirect to login.
3. Remove the `|| 'super_secret'` fallback.
4. Distinguish "wrong role for this account" from a bad password.

### Acceptance criteria
- Visiting `/admin` (etc.) while logged out redirects to login server-side.
- Sessions don't silently die mid-use without explanation.

---

# Phase 10 — Admin dashboard correctness

### Problems & root causes
`apps/frontend/src/app/admin/dashboard/page.tsx`:
1. **Totals are computed from only the most recent 60 payments.** `fetchAdminRecentPayments()` defaults to `limit=60` (`apps/backend/src/admin/admin.service.ts:123`); the dashboard derives `Total Bookings = paymentRows.length` (`:201`), `Platform Revenue` (`:160,202`), and labels the table "All Platform Bookings" (`:579`). With >60 bookings these are silently wrong. (HIGH.)
2. **"User Management" list is derived from those capped payments**, not real users (`:124-135`): patients without a recent booking never appear; "Joined" = booking date, not signup; counts are wrong. (HIGH.)
3. **Security tab is non-functional theater** — 2FA / rate-limiting toggles are local state (`:70-71`), "AES-256/OWASP/Encrypted Backups" are static claims, "View Security Logs" (`:721`) and per-user "View" (`:563`) are dead buttons. (MEDIUM — misleading.)

### Suggested solution
1. Add a backend **aggregate stats endpoint** (total bookings + revenue over ALL bookings) and a properly **paginated** bookings list; stop deriving platform totals from a capped list.
2. Add an **admin users endpoint** returning real patient accounts with true signup dates and total booking counts.
3. Remove or actually implement the Security tab; at minimum drop dead buttons and unfounded claims.

### Acceptance criteria
- Admin totals match the real DB regardless of booking count.
- User Management lists real users with correct signup dates and counts.
- No dead buttons or fake security claims.

---

# Phase 11 — Reviews are write-only; make them visible

### Problem
Patients can submit reviews (`apps/backend/src/api/patient.service.ts:192`, which correctly recomputes `rating_average`/`review_count`), but **no endpoint returns review text** and no UI shows reviews. `GET /public/labs/:id` returns only the numeric rating and count; `LabDetailsPage` renders no review list. Review comments are invisible.

### Suggested solution
1. Add published reviews (rating + comment + date, patient first name/initials) to the public lab detail response (`public-labs.controller.ts`).
2. Render a reviews section on `LabDetailsPage.tsx`.

### Acceptance criteria
- A lab's published reviews (text + rating) are visible on its detail page.

---

# Phase 12 — Misc bugs & cleanup

Lower-priority but contribute to the "broken" impression:

1. **Dead footer links** — 9 `<a href="#">` on the landing page (`apps/frontend/src/teslty/components/LandingPage.tsx:386-404`: Search Tests, Book Appointment, View Results, Register Your Lab, Dashboard, Analytics, Help Center, Privacy Policy, Terms). → Point to real routes or remove. (MEDIUM)
2. **Lab analytics "Capacity Usage" can exceed 100%** — `apps/backend/src/api/lab.service.ts:455-473` compares past+future bookings against only future active slots. → Use the same time window for numerator and denominator. (MEDIUM)
3. **Duplicate login/register components** — `(auth)/login/page.tsx` & `(auth)/register/page.tsx` differ only by `defaultMode`. → Optional dedupe. (LOW)
4. **`canReview` client/server drift** — frontend `canReview = !review && !!result_file` vs backend also requiring result status ∈ {Uploaded, Delivered} (`patient.service.ts:143,222-227`). Aligns today; mirror the status check to be safe. (LOW)
5. **`updatePatientProfile` lets blank strings overwrite** saved phone/address (`patient.service.ts:176-178`). → Decide intended behavior; guard against accidental wipe. (LOW)
6. **Dead `LabScheduleSlot.capacity`** — exists but ignored (1:1 slot↔booking). → Remove or implement. (LOW)
7. **Demo credentials block on login** (`LoginPage.tsx:409-419`, gated by env/non-prod). → Confirm production hides it (`NEXT_PUBLIC_SHOW_DEMO_CREDENTIALS=false`). (LOW)

### Acceptance criteria
- No dead links/buttons in the main user flows; analytics figures are sane; demo credentials hidden in production.

---

## Cross-cutting acceptance test (run after the relevant phases)
1. Seed the new data (`npm run db:seed`).
2. Search "CPC" → see a test result that names the labs offering it → click → land on a **test** page → book at a chosen lab, explicitly choosing **Home vs Clinic**.
3. Filter by city "Ismailia" → only Ismailia labs.
4. Open a lab detail → real phone/email, real (or hidden) distance, real reviews, real/availability slots.
5. As patient, open a result PDF (works); as a different user, the same URL is **denied**.
6. Admin dashboard totals match the DB.
7. No screen shows hardcoded/placeholder data; `apps/frontend` builds clean.
