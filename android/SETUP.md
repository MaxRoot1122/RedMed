# RedMed — Android app (Google Play)

This wraps the same web app already hosted at
`https://www.redmed.com/index.html` as an installable Android
app — no separate codebase to maintain, and it updates automatically
whenever you update and redeploy `index.html`. It's a **Trusted Web
Activity (TWA)**: Google's official, supported way to publish a web app on
Play, using Chrome under the hood but with zero browser chrome (no address
bar) so it looks and feels like a native app.

I couldn't build or run this here — no Android SDK/Android Studio in this
environment. Everything below is the source Android Studio needs; the
actual build has to happen on your machine.

## Trade-off vs. the iOS app

The iOS app writes NFC tags directly (CoreNFC). A TWA can't do that —
Android's NFC write API needs to run in the foreground activity itself,
which a TWA doesn't give you easy access to. For now, treat **writing**
tags as an iOS-only capability (same as we already decided for the web
version), and the Android app as: view your card, edit your profile,
Basic Aid, Find 911 (GPS + offline trauma centers by state — see [`docs/TRAUMA_FINDER.md`](../docs/TRAUMA_FINDER.md)). **Android Chrome** can also program bracelets via
Web NFC on the hosted `index.html` (Bracelet sheet → Write to bracelet)
when the TWA wraps the same site.

**NFC any-device (current):** iOS writes tags as
`https://www.redmed.com/index.html#d=…` so **smartphones** can open the emergency
card in a browser (not card readers or other NFC devices). This Android TWA already wraps that hosted site — new bracelet taps work on Android without a native
NFC rewrite. Older `redmed://` tags and legacy GitHub Pages URLs still open the card.

## 1. Install Android Studio

Download from developer.android.com/studio (free). Open this `android/`
folder as an existing project (**File → Open**).

## 2. Create your signing key

Android Studio: **Build → Generate Signed Bundle / APK → Create new...**
Fill in the form (this generates a `.jks` keystore file — back it up
somewhere safe; if you lose it you can never update the app again under
the same listing).

## 3. Get your key's SHA-256 fingerprint

```
keytool -list -v -keystore /path/to/your.jks -alias your-key-alias
```

Copy the `SHA256:` fingerprint it prints.

## 4. Verify app ↔ website ownership (optional)

Edit [`.well-known/assetlinks.json`](../.well-known/assetlinks.json): replace
`REPLACE_WITH_PLAY_APP_SIGNING_SHA256` (from Play Console → App integrity → App
signing) and `REPLACE_WITH_UPLOAD_KEYSTORE_SHA256` (from step 3). See
[`android/assetlinks.json.example`](assetlinks.json.example) and
[`docs/ANDROID_PLAY.md`](../docs/ANDROID_PLAY.md). Deployed on each `main` push
via Pages workflow. Do not invent fingerprints.

**Stay on this one repo** (`MaxRoot1122/RedMed`). Do not create a separate
`MaxRoot1122.github.io` user-site just for Digital Asset Links.

GitHub project Pages serve under `/RedMed/...`, so Android cannot verify
`https://maxroot1122.github.io/.well-known/assetlinks.json` from this repo
alone. Skip full-screen verification for now — the TWA still works; Chrome may
show a thin address-bar strip instead of true full-screen. That is a
cosmetic downgrade only.

**Deployed asset links:** [`.well-known/assetlinks.json`](../.well-known/assetlinks.json) is copied to the site root on each `main` push (see [`.github/workflows/pages.yml`](../.github/workflows/pages.yml)). It takes effect for **custom domain** hosting per [`docs/DOMAIN.md`](../docs/DOMAIN.md).

Full Play checklist: [`docs/ANDROID_PLAY.md`](../docs/ANDROID_PLAY.md).

## 5. Build

**Build → Generate Signed Bundle / APK → Android App Bundle**, using the
keystore from step 2. This produces the `.aab` file Google Play wants.

## 6. Publish to Google Play

1. Create a [Google Play Console](https://play.google.com/console) account — **$25 one-time**, your own Google account.
2. **Create app** → fill in name ("RedMed"), category (Medical), free.
3. **App content** section: fill in the Data Safety form — **Location: Precise location**, used on **Find 911** for **App functionality** (emergency coordinates on screen, only while that screen is open), **not shared with third parties**, **not used for advertising or tracking**, **processed on-device only — not sent to developer servers**. User agreement is in `privacy-policy.html` and `terms-of-service.html` (download/install/use = consent to on-device use while the app is open; web shows a one-time first-open consent banner). Also declare on-device medical profile fields per the privacy policy, and paste the privacy policy URL: `https://www.redmed.com/privacy-policy.html`.
4. **Store listing**: short/full description, screenshots (take these from the running app — at least 2, phone-sized), the icon at `play/listing/play-store-icon-512.png`.
5. **Production → Create release**, upload the `.aab` from step 5, roll out.
6. Google reviews it — typically a few hours to a few days for a first submission.

## Updating later

Since this is a TWA, most updates (content, features, bug fixes) just
need `index.html` redeployed to GitHub Pages — no new Android build or
Play Store submission needed at all. Only bump `versionCode`/`versionName`
in `android/app/build.gradle` and re-submit if you change the native
wrapper itself (icon, permissions, app name).
