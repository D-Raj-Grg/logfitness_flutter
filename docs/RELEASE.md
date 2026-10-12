# Releasing Gym Tross

Bundle id `com.gymtross.app` (iOS team `456X78R628`). Nothing here uploads by default: both
release scripts build and validate, and only send with `--upload`.

## Versioning

- `pubspec.yaml` is three-part (`1.2.0+10`); the App Store listing is two-part (1.0, 1.1, 1.2).
- A release with a user-visible feature is the next minor (1.2 -> 1.3); fixes only is a patch.
- Check the live history first (ASC), do not guess by semver instinct.
- pubspec's build number drifts from what is shipped (past builds used `--build-number`).
  Find the real highest number (ASC, or `unzip -p "<ipa>" 'Payload/*/Info.plist' | plutil -p -`)
  and bump above it:

```bash
scripts/bump_version.sh minor --shipped 10      # 1.2.0+10 -> 1.3.0+11
scripts/bump_version.sh build --shipped 12      # same x.y.z, new build
```

Xcode auto-increments the build on app-store export, so read CFBundleVersion from the exported IPA.
Play versionCode is the same build number and must also be strictly increasing.

## iOS / TestFlight

Needs `env/local.json` (never build without it: build 8 froze on launch), the ASC API key at
`~/.appstoreconnect/private_keys/AuthKey_<id>.p8`, and:

```bash
export ASC_KEY_ID=...      # see local notes
export ASC_ISSUER_ID=...
scripts/release_ios_testflight.sh            # build + verify supabase.co baked in + validate
scripts/release_ios_testflight.sh --upload   # then upload to TestFlight
```

After upload: wait for the build to be VALID, create the App Store version, set what's new, attach
the build, submit for review (manual in App Store Connect, or `~/.appstoreconnect/asc.py`).
Export compliance is preset (`ITSAppUsesNonExemptEncryption=false`).

Privacy manifest: `ios/Runner/PrivacyInfo.xcprivacy` (already in the Runner Resources phase). It
must agree with the App Store Connect privacy questionnaire. Re-audit it when adding plugins,
especially crash reporting or analytics.

## Android / Play internal

One-time, generate an upload keystore OUTSIDE the repo and back it up (losing it is recoverable
only through Play support if Play App Signing is enabled; enable it):

```bash
mkdir -p ~/.android-keystores
keytool -genkey -v -keystore ~/.android-keystores/gymtross-upload.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties   # then fill in; gitignored
```

Then:

```bash
scripts/release_android_internal.sh            # signed .aab at build/app/outputs/bundle/release/
scripts/release_android_internal.sh --upload   # needs fastlane + PLAY_JSON_KEY
```

Without `android/key.properties`, Gradle falls back to the debug key (so `flutter run --release`
works) and the script refuses to proceed. The first Play upload of an app must be done by hand in
Play Console (create the app, enable Play App Signing, upload the first .aab).

## GitHub Actions

`.github/workflows/release.yaml` is manual (`workflow_dispatch`). Android secrets needed:
`ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`,
`ENV_LOCAL_JSON`, `PLAY_JSON`. The workflow bumps pubspec on the runner only; it does not commit it
back, so write the new version into the repo yourself. The iOS job is disabled (`if: false`) until
cert/profile import and ASC key secrets are added.

## Not done yet

Crash reporting/analytics, push notifications (no usage string is needed on iOS for notifications,
the prompt is runtime; add the push entitlement + `UIBackgroundModes` and Android
`POST_NOTIFICATIONS` when push lands), icon/splash regeneration (assets already committed; do not
run flutter_launcher_icons, it would overwrite the hand-tuned set).
