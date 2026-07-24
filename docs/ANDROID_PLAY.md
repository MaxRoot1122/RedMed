# Google Play submission checklist

Requires Android Studio on your machine. TWA wraps the hosted web app — most updates deploy via GitHub Pages without a new Play build.

## Prerequisites

- [ ] [Google Play Console](https://play.google.com/console) account ($25 one-time)
- [ ] Android Studio installed
- [ ] Hosted app live at canonical URL ([`config/canonical-url`](../config/canonical-url))

## Signing

1. Open [`android/`](../android/) in Android Studio (generates Gradle wrapper on first open)
2. **Build → Generate Signed Bundle / APK → Create new...** → save `.jks` keystore **securely**
3. `keytool -list -v -keystore your.jks` → copy **SHA-256** fingerprint (upload key)

## Digital Asset Links (full-screen TWA)

Play App Signing uses a **different** cert than your upload keystore. List both.

1. Play Console → your app → **Setup → App integrity → App signing** → copy **App signing key certificate** SHA-256
2. Paste that as `REPLACE_WITH_PLAY_APP_SIGNING_SHA256` in [`.well-known/assetlinks.json`](../.well-known/assetlinks.json)
3. Paste the upload-keystore SHA-256 from step 3 above as `REPLACE_WITH_UPLOAD_KEYSTORE_SHA256`
4. Remove any leftover `REPLACE_WITH_*` placeholders — do not invent fingerprints
5. Push to `main` — workflow deploys to Pages
6. For custom domain: complete [`docs/DOMAIN.md`](DOMAIN.md) first (GitHub project Pages path alone cannot satisfy `/.well-known/assetlinks.json` at the github.io apex)
7. Verify with [Statement List Tester](https://developers.google.com/digital-asset-links/tools/generator)

On GitHub Pages path only, TWA works but may show a thin address bar — cosmetic only.

## Build release

```text
Build → Generate Signed Bundle / APK → Android App Bundle (.aab)
```

Bump `versionCode` / `versionName` in [`android/app/build.gradle`](../android/app/build.gradle) when changing native wrapper.

## Play Console

| Section | Notes |
|---------|-------|
| Category | Medical |
| Data Safety | Precise location (Find 911, on-device, not sent to developer); on-device medical profile fields per privacy policy |
| Privacy policy | `https://www.redmed.com/privacy-policy.html` |
| Store listing | Copy in [`play/listing/`](../play/listing/); screenshots per [`docs/STORE_ASSETS.md`](STORE_ASSETS.md) |
| Feature graphic | `play/listing/feature-graphic.svg` → export 1024×500 PNG |

## NFC scope (v1)

- **Writing tags:** iOS app or NFC Tools + web link — not in Android TWA
- **Reading tags:** Any phone browser opens HTTPS bracelet taps

## Post-launch updates

- Web-only changes: push `index.html` to `main` → Pages redeploys → users get updates without new `.aab`
- Native changes (permissions, icon, manifest): new signed `.aab` + Play release

See also [`android/SETUP.md`](../android/SETUP.md).
