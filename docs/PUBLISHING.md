# Publishing Yugal

## 1. Android (Google Play)
1. Create a Play Console developer account (one-time registration fee).
2. Create an upload keystore **once** and back it up safely:
   ```bash
   keytool -genkey -v -keystore ~/yugal-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
3. Create `android/key.properties` (never commit it) and wire it into
   `android/app/build.gradle(.kts)` as in Flutter's "Build and release an Android app" guide.
4. Set a unique `applicationId`, version in `pubspec.yaml` (`1.0.0+1` → bump `+N` each release), app icon and splash.
5. Build the bundle: `flutter build appbundle --release` → upload `build/app/outputs/bundle/release/app-release.aab`.
6. Start with **internal testing**, then closed testing, then production.

## 2. iOS (App Store) — needs a Mac
1. Apple Developer Program membership; create the app in App Store Connect.
2. `flutter create --platforms=ios .`, set bundle id and signing in Xcode.
3. `flutter build ipa --release` → upload with Transporter, test via TestFlight.

## 3. Store listing checklist
- Title, short + full description (English + Hindi at minimum), screenshots, feature graphic, icon.
- **Privacy policy URL** and **Terms of service** (host on your website).
- **Age rating 18+**; confirm age at sign-up (already in the login flow).
- **Data safety / privacy labels**: location, photos/videos, phone number, ID verification data, messages, purchases.
- **User-generated content**: in-app report and block, moderation process, safety tips (present in this app).
- **Account deletion**: in-app option plus a web URL for deletion requests (required by Play for apps with accounts).
- Support email and a grievance contact (India).

## 4. Payments — check before launch
Both stores have rules on how **digital subscriptions and in-app items** (premium plans, boosts, super likes)
may be sold inside the app. Selling them through Razorpay/UPI alone may not be allowed on
Google Play or the App Store, depending on current policy and region. Before launch, read the current
Google Play Payments policy / user-choice billing options and Apple's App Store Review Guidelines
(section 3.1), and decide between store billing, an approved alternative-billing program, or web checkout.
Plan the Razorpay integration around that decision.

## 5. Pre-launch hardening
- Replace every demo stub (OTP, verification, payments, AI, chat) with the real backend.
- Penetration test, load test, DPDP Act review, content-moderation drill, SOS flow test.
- Crash reporting and analytics enabled; staged rollout (5% → 20% → 100%).
