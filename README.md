# TesTly Monorepo (Backend + Frontend)

## Prerequisites
- Node.js + npm

## 1) Install dependencies
```bash
npm install
```

## 2) Configure backend environment variables
Create `apps/backend/.env` from the example:
```bash
cp apps/backend/.env.example apps/backend/.env
```
On Windows (PowerShell):
```powershell
Copy-Item apps\\backend\\.env.example apps\\backend\\.env
```

Then update `apps/backend/.env` with your Neon database URL:
```env
DATABASE_URL="postgresql://user:password@ep-xxx.region.aws.neon.tech/neondb?sslmode=require"
JWT_SECRET="your-super-secure-jwt-secret-key"
```

> Get your connection string from the [Neon dashboard](https://console.neon.tech). Use the **pooled** connection string.

## 3) Push schema to database
```bash
cd apps/backend && npx prisma migrate deploy
```

Or for a fresh database with no migration history:
```bash
cd apps/backend && npx prisma db push
```

## 4) Seed demo data
```bash
npm run db:seed
```

## 5) Run the app (backend + frontend)
```bash
npm run dev
```

## URLs
- Frontend: `http://localhost:3000`
- Backend: `http://localhost:3001`
- Swagger: `http://localhost:3001/api`

## Demo Accounts & QA Scenarios (Password: `password123`)

After running `npm run db:seed`, your database will be seeded with comprehensive demo data to test different user journeys.

> **All accounts share the same password: `password123`**

### 1. Admin Flow
- **Login page**: `/admin/login` — dedicated dark-themed page, not linked from anywhere. Admins navigate there directly by URL.
- **Email**: `admin@testly.com`
- **What to test**:
  - Navigate to `/admin/dashboard` to view the Admin Workspace overview.
  - Review the pending labs list. You will see `Pending Lab (Demo)` (`pendinglab@testly.com`). You can click to **Approve** or **Reject** the onboarding application.
  - Review recent platform transactions, including cash and online payments.

### 2. Lab Administration Flow
- **Active Lab Login (primary demo)**: `alborglaboratories@testly.com`
  - Navigate to `/lab` (Dashboard). Experience the schedule view where there is an existing booking assigned to "Mazen Amir".
  - You can manage test catalogs, update pricing, and upload PDF results for upcoming patient visits.
- **Pending Lab Login**: `pendinglab@testly.com`
  - Login to witness the restricted pending-review state.
- **Rejected Lab Login**: `rejectedlab@testly.com`
  - Login to witness the rejected application state (useful for QAing restricted access).

#### All 21 Active Lab Accounts

Lab emails are derived from the lab name (lowercase, no spaces). All use password `password123`.

| # | Lab Name | Email |
|---|---|---|
| 1 ⭐ | Al Borg Laboratories | `alborglaboratories@testly.com` |
| 2 | El Mokhtabar | `elmokhtabar@testly.com` |
| 3 | Cairo Scan Medical Lab | `cairoscanmedicallab@testly.com` |
| 4 | Alfa Laboratories | `alfalaboratories@testly.com` |
| 5 | Royal Lab | `royallab@testly.com` |
| 6 | Pyramids Medical Lab | `pyramidsmedicallab@testly.com` |
| 7 | Giza Central Diagnostics | `gizacentraldiagnostics@testly.com` |
| 8 | Al Borg Alexandria | `alborgalexandria@testly.com` |
| 9 | Nile Delta Diagnostics | `niledeltadiagnostics@testly.com` |
| 10 | Alexandria Medical Center Lab | `alexandriamedicalcenterlab@testly.com` |
| 11 | Canal Medical Lab | `canalmedicallab@testly.com` |
| 12 | Ismailia Diagnostics Center | `ismailiadiagnosticscenter@testly.com` |
| 13 | Port Said Medical Lab | `portsaidmedicallab@testly.com` |
| 14 | Suez Canal Diagnostics | `suezcanaldiagnostics@testly.com` |
| 15 | Delta Medical Lab | `deltamedicallab@testly.com` |
| 16 | Mansoura Diagnostics Center | `mansouradiagnosticscenter@testly.com` |
| 17 | Tanta Central Lab | `tantacentrallab@testly.com` |
| 18 | Zagazig Medical Diagnostics | `zagazigmedicaldiagnostics@testly.com` |
| 19 | Upper Egypt Diagnostics | `upperegyptdiagnostics@testly.com` |
| 20 | Pharaohs Medical Lab | `pharaohsmedicallab@testly.com` |
| 21 | Nubia Medical Center | `nubiamedicalcenter@testly.com` |

### 3. Patient Flow

| Patient | Email |
|---|---|
| Mazen Amir (primary demo) | `patient@testly.com` |
| Ahmed Khalil | `ahmed.khalil@testly.com` |
| Fatima Hassan | `fatima.hassan@testly.com` |
| Omar Samir | `omar.samir@testly.com` |

- **Login**: `patient@testly.com` (Profile name: Mazen Amir)
- **What to test**:
  - **Search & Book**: Go to `/` and search for "Blood" to filter active labs. Proceed to book a home collection or a clinic visit.
  - **Result History**: Navigate to `/patient` (Patient Dashboard) then click on **My Results**. The system is seeded with a historical structured CBC exam snippet comparing past vs current glucose values.
  - **Payment Handling**: The patient history includes a simulated failed/cancelled booking due to a failed PayMob online payment, which you can observe in the bookings list.

---

## Technical Docs

| Topic | File |
|---|---|
| Search (fuzzy matching, pg_trgm) | [`docs/SEARCH.md`](docs/SEARCH.md) |
| Environment variables | [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md) |
| Deployment checklist | [`docs/DEPLOYMENT_CHECKLIST.md`](docs/DEPLOYMENT_CHECKLIST.md) |

---

## Running the Mobile App (Flutter)

### Prerequisites

| Tool | Version | Install |
|---|---|---|
| Flutter SDK | 3.44+ | https://flutter.dev/docs/get-started/install |
| Xcode | 15+ | Mac App Store (iOS simulator) |
| Android Studio | Hedgehog+ | https://developer.android.com/studio (Android emulator) |
| CocoaPods | 1.15+ | `sudo gem install cocoapods` |

Verify your setup:
```bash
flutter doctor
```

### Mobile environment

The Flutter app reads `API_BASE_URL` at build time. No `.env` file is needed — the default values are already correct for local development:

| Platform | Default base URL |
|---|---|
| iOS Simulator | `http://localhost:3001` |
| Android Emulator | `http://10.0.2.2:3001` |

To override, pass `--dart-define` when running:
```bash
# iOS (default already correct)
flutter run --dart-define=API_BASE_URL=http://localhost:3001

# Android emulator (default already correct)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001
```

### Step 1 — Start the backend first

```bash
cd apps/backend
npm run start:dev
```

Wait until you see:
```
[NestApplication] Nest application successfully started
[NotificationsService] Firebase Admin SDK initialised — push notifications enabled.
```

The backend must be running before launching the app, or the login screen will fail to connect.

### Step 2 — Launch an emulator

**iOS Simulator (Mac only):**
```bash
# List available simulators
flutter emulators

# Launch the iOS simulator
flutter emulators --launch apple_ios_simulator
```

**Android Emulator:**
```bash
# List available emulators
flutter emulators

# Launch (replace with your emulator id from the list above)
flutter emulators --launch Medium_Phone_API_36.1
```

Or open the emulator from Android Studio: **Device Manager → Play button**.

### Step 3 — Install dependencies & run

```bash
cd apps/mobile

# Install Dart packages
flutter pub get

# Confirm your device/emulator is detected
flutter devices

# Run on iOS Simulator
flutter run -d <simulator-device-id>

# Run on Android Emulator
flutter run -d <emulator-device-id>
```

To find the device id, copy it from `flutter devices` output (e.g. `5B1D1389-4893-4F28-8C09-F0C56CAF43C6` for iOS or `emulator-5554` for Android).

### Mobile demo accounts

Use the same accounts listed in the Patient Flow section above. Primary demo:

| Field | Value |
|---|---|
| Email | `patient@testly.com` |
| Password | `password123` |

On first login the app will show a **notification permission sheet** (Phase 5). Tap **Enable notifications** to grant FCM permission.

### Push notifications (FCM) setup

Push notifications require real Firebase credentials. Add this to `apps/backend/.env`:
```env
FCM_SERVICE_ACCOUNT_JSON='{ ...paste your firebase-adminsdk service account JSON here as a single line... }'
```

Get the file from [Firebase Console](https://console.firebase.google.com) → Project Settings → Service Accounts → Generate new private key. Minify it to a single line before pasting (the value must not contain literal newlines).

> **Note:** The iOS Simulator does not support APNs (Apple Push Notifications), so FCM tokens are not issued on simulator. Push notifications can only be end-to-end tested on a real device. All other app features work normally on the simulator.

### Run mobile tests

```bash
cd apps/mobile
flutter test
```

---

## (Optional) Frontend API base URL
By default the frontend uses `http://localhost:3001`. To override, create `apps/frontend/.env.local` using `apps/frontend/.env.local.example`.

## Phase 7 Guided Assistant + Production Readiness
- Guided FAQ assistant endpoints:
  - `GET /faq/intents`
  - `GET /faq/search`
  - `POST /faq/ask`
- Chatbot in frontend now calls the FAQ API (curated, non-LLM).
- Standardized backend error response payload is enabled globally.
- Audit logs are emitted for auth and booking/result status operations.

## Useful Commands
```bash
npm run db:seed
npm run db:bootstrap
```

## Docs
- Environment variables: `docs/ENVIRONMENT.md`
- Deployment checklist: `docs/DEPLOYMENT_CHECKLIST.md`
