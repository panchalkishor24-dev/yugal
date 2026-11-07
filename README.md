# Yugal 🪷 — dating & matchmaking app for India

Flutter (Android + iOS) client with a complete, working UI flow. This build runs
**offline on sample data** so every screen can be demoed; the server pieces are
described in `docs/ARCHITECTURE.md`.

## Get the APK (pick one)

**A. GitHub Actions (no installs, ~10 min)**
1. Create a new GitHub repo and upload this folder's contents (keep `.github/`).
2. Open the repo → **Actions → Build Yugal APK → Run workflow**.
3. When it finishes, download the **yugal-apk** artifact → unzip → `app-release.apk`.
4. Copy to your phone and install (allow "install unknown apps").

**B. On your computer**
```bash
flutter create --platforms=android --org in.yugal --project-name yugal .
# add <uses-permission android:name="android.permission.INTERNET"/> to
# android/app/src/main/AndroidManifest.xml (optional for this offline demo)
flutter pub get
flutter run                 # test on a device/emulator
flutter build apk --release # → build/app/outputs/flutter-apk/app-release.apk
```

**C. Codemagic** — connect the repo, choose Flutter, build for Android.

> The APK from the steps above is signed with a debug key: fine for testing and
> sideloading, **not** for the Play Store. See `docs/PUBLISHING.md`.

## What works in this build

| Area | Status |
|---|---|
| Onboarding, 8-language UI strings (en/hi/mr/te/ta/kn/bn/gu), light + dark theme | Working |
| Phone + OTP flow, Google/Apple/Facebook buttons | UI only (any 6-digit OTP accepted) |
| Selfie / ID / LinkedIn verification + authenticity score | Simulated |
| Profile creation (all requested fields, optional income/caste) | Working (local) |
| Swipe discovery, rewind, Super Like, boost, filters (For You / Nearby / Trending / New) | Working on sample profiles |
| AI compatibility report, AI bio writer, photo analyzer, dating coach, icebreakers | Templated stubs (`lib/ai.dart`) |
| Chat: typing indicator, read receipts, voice-note + photo bubbles, translate toggle | Simulated replies, no network |
| Audio/video call screen, virtual date room + icebreaker games | UI only (no media stream) |
| Free / Premium / VIP plans, boosts, checkout sheet (UPI, GPay, PhonePe, Paytm, cards, Razorpay) | Demo checkout, **no real payment** |
| Safety center, SOS, report/block, trusted contacts | UI only (no SMS sent) |
| Admin dashboard | Demo screen with sample data |

## Not in this repo yet (needs real services)

- Backend: Node/Express, PostgreSQL, Redis, WebSocket chat → schema, API list and
  deployment plan are in `docs/ARCHITECTURE.md`.
- Real SMS OTP, social sign-in, DigiLocker/e-KYC, liveness SDK.
- Razorpay order creation + webhook verification, FCM push, WebRTC calls.
- AI calls must go through **your backend** (never put an OpenAI key in the app).
- Screenshot detection needs native Android/iOS code (Android: `FLAG_SECURE`; iOS
  can only detect after the fact).
- Photos/videos upload, real translation (e.g. Bhashini), profile moderation.

## Layout

```
lib/
  main.dart  theme.dart  i18n.dart  data.dart  ai.dart  widgets.dart
  screens/  onboarding login verify setup home discover likes chat call
            premium safety profile admin
docs/       ARCHITECTURE.md  PUBLISHING.md
.github/workflows/build-apk.yml
```

⚠️ **Not compiled yet.** This source was written without a Flutter toolchain, so
expect to fix a few small compile errors on the first build. Paste the error log
and they are quick to resolve.
