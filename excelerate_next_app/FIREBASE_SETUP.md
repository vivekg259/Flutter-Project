# 🔥 Firebase Setup Guide — Excelerate Next App

This guide walks you through connecting the Excelerate Next App to a **real Firebase backend**. Once done, all authentication, programs, announcements, registrations, and feedback will use live data.

> **Estimated time:** 10–15 minutes
> **Cost:** Free (Spark plan is enough)

---

## 📋 Prerequisites

- A Google account
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed
- [Node.js](https://nodejs.org/) installed (for the FlutterFire CLI)
- The app should already `flutter pub get` successfully

---

## Step 1 — Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project**.
3. Enter a project name (e.g., `excelerate-next-app`).
4. (Optional) Disable Google Analytics — not required for this app.
5. Click **Create project** and wait for it to provision.

---

## Step 2 — Enable Authentication

1. In the Firebase Console, open your project.
2. From the left sidebar, click **Build → Authentication → Get started**.
3. Go to the **Sign-in method** tab.
4. Click on **Email/Password** and **enable** it.
5. Click **Save**.

> ✅ Users can now sign up with email/password from the app.

---

## Step 3 — Create the Firestore Database

1. From the left sidebar, click **Build → Firestore Database → Create database**.
2. Choose **Start in production mode** (we'll add security rules below).
3. Pick a location close to your users (e.g., `asia-south1` for India).
4. Click **Enable** and wait ~1 minute for provisioning.

> ✅ Firestore is now ready to store users, programs, registrations, etc.

---

## Step 4 — Install the FlutterFire CLI

Open a terminal (in the project root) and run:

```bash
# Install the FlutterFire CLI globally (one-time)
dart pub global activate flutterfire_cli

# Make sure the dart bin directory is on your PATH.
# On Windows, this is usually: %LOCALAPPDATA%\Pub\Cache\bin
```

Verify the install:

```bash
flutterfire --version
```

If `flutterfire` is not recognized, add `%LOCALAPPDATA%\Pub\Cache\bin` to your PATH and restart the terminal.

---

## Step 5 — Connect the App to Firebase

From the project root, run:

```bash
flutterfire configure --project=excelerate-next-app
```

**What this does:**
- Detects the platforms in `pubspec.yaml` (Android, iOS, Web, etc.)
- Asks which platforms to configure (press Enter to accept defaults)
- Downloads config values and **overwrites `lib/firebase_options.dart`** with real values
- Sets `isConfigured = true` automatically (handled by our custom file — see note below)

> ⚠️ **Note:** Our `lib/firebase_options.dart` is a hand-written placeholder. After running `flutterfire configure`, the CLI will **overwrite** it with the generated version. That's expected — just verify the generated file still has `isConfigured = true` (see Step 6).

If the CLI doesn't automatically set `isConfigured`, manually edit `lib/firebase_options.dart` and change:

```dart
static const bool isConfigured = false;  // ← change to true
```

to:

```dart
static const bool isConfigured = true;
```

---

## Step 6 — Verify the Configuration

Open `lib/firebase_options.dart`. You should see:

- Real `apiKey`, `appId`, `messagingSenderId`, `projectId` values (no more `PLACEHOLDER-` strings)
- `isConfigured = true`

If `isConfigured` is missing, add it manually:

```dart
static const bool isConfigured = true;
```

---

## Step 7 — Deploy Firestore Security Rules

The app uses role-based access control. The authoritative rules live in the
repository — do not copy a separate rule set into the console.

1. Install the Firebase CLI once: `npm install -g firebase-tools`
2. From the project root, run:
   ```bash
   firebase login
   firebase deploy --only firestore:rules,firestore:indexes
   ```
   This deploys the checked-in `firestore.rules` and `firestore.indexes.json`
   via the project mapping in `firebase.json`.

> ⚠️ If you previously pasted an older copy of the rules into the console, the
> deploy above will overwrite it with the repository version. Keep the console
> rules in sync with `firestore.rules` — they are the single source of truth.

---

## Step 8 — Make Yourself an Admin (Console Promotion)

Every new signup is a **learner** and must verify their email before their first
sign-in. There is no client-side admin whitelist — admin access is granted
manually in the Firebase Console:

1. **Sign up** in the app with your admin email (e.g., `admin@excelerate.org`).
2. **Verify your email** and sign in — you will land on the Learner Home.
3. Go to the Firebase Console → **Firestore Database** → **Data** tab.
4. Open the `users` collection, then the document matching your UID.
5. Edit the `role` field from `learner` to `admin`.
6. Click **Save**.
7. In the app, sign out and sign back in — you'll now see the **Admin Home** dashboard.

> 🔒 **Security:** Only someone with Firebase Console access can change roles.
> There is **no in-app way** to elevate a learner to admin — this is by design
> (defense in depth). The app's security rules also block clients from creating
> anything other than `PENDING` registrations or changing their own role.

---

## Step 9 — (Optional) Add Seed Data

To see real programs on the Home and Programs screens, add a few program documents:

1. Firebase Console → Firestore → **Start collection** → name it `programs`.
2. Add documents with this structure:

| Field | Type | Value |
|-------|------|-------|
| `title` | string | `Flutter Mobile Development Masterclass` |
| `description` | string | `Master cross-platform mobile development...` |
| `instructor` | string | `Dr. Alex Rivera` |
| `duration` | string | `6 Weeks` |
| `level` | string | `Intermediate` |
| `skills` | array | `["Flutter", "Dart", "Mobile UI", "State Management"]` |
| `rating` | number | `4.8` |
| `reviewsCount` | number | `120` |
| `capacity` | number | `50` |
| `registeredCount` | number | `0` |
| `status` | string | `open` |
| `eligibility` | string | `Basic programming knowledge` |
| `schedule` | string | `Mon & Wed, 6:00–8:00 PM IST` |
| `createdBy` | string | `<your-admin-uid>` |
| `createdAt` | timestamp | (server timestamp) |

Repeat for 3–5 programs. The Home and Programs screens will update live.

To add announcements, create an `announcements` collection:

| Field | Type | Value |
|-------|------|-------|
| `title` | string | `Week 3 API Prep session starts in 30 minutes` |
| `body` | string | `Join via the Zoom link in your dashboard.` |
| `type` | string | `reminder` |
| `priority` | string | `high` |
| `createdBy` | string | `<your-admin-uid>` |
| `createdAt` | timestamp | (server timestamp) |

---

## Step 10 — Run the App

```bash
flutter run
```

**What you should see:**
- Splash screen (2 seconds) → Login screen
- Sign up → creates a Firebase Auth user in staging (no Firestore document yet)
- Verify email → first sign-in creates the `users/{uid}` doc with `role: learner`
- Sign in → routes to Learner Home (or Admin Home once the role is promoted in the console)
- Programs, Announcements, and Registrations all pull live data from Firestore

---

## 🧪 Troubleshooting

### `MissingPluginException` or Firebase not initializing
- Run `flutter clean && flutter pub get`
- On Android: ensure `minSdkVersion` is ≥ 23 in `android/app/build.gradle`
- On iOS: run `cd ios && pod install`

### `isConfigured` is still false
- Open `lib/firebase_options.dart` and set `static const bool isConfigured = true;`

### `[firebase_auth/invalid-credential]` on login
- Make sure Email/Password sign-in is enabled (Step 2)
- Verify the email/password is correct

### `[cloud_firestore/permission-denied]`
- Re-check the security rules (Step 7) are published
- Confirm the user is signed in before accessing Firestore

### Bottom nav or routes not working
- Run `flutter clean && flutter pub get && flutter run`

---

## ✅ Checklist

- [ ] Firebase project created
- [ ] Email/Password auth enabled
- [ ] Firestore database created (production mode)
- [ ] `flutterfire configure` run successfully
- [ ] `lib/firebase_options.dart` has `isConfigured = true`
- [ ] Security rules published
- [ ] At least one admin user whitelisted (role = `admin`)
- [ ] Seed data added (programs + announcements)
- [ ] App runs and shows live data

---

**Next:** Once Firebase is live, we move to **Phase 2–4** — deep feature implementation with real data. The foundation is now complete. 🚀
