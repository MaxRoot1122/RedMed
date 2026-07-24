# Custom domain for RedMed

**Active canonical host (live):** `https://maxroot1122.github.io/RedMed/` — see [`config/canonical-url`](../config/canonical-url).

**`www.redmed.com` is NOT live yet.** As of 2026-07-24 it returns a registrar parking `/lander` page, not this app. Do not write NFC tags to that host until DNS points at GitHub Pages and `index.html` / AASA serve correctly. Repo [`CNAME`](../CNAME) is the intended future target only.

**Do not use `redmed.app`** — unrelated third-party storefront (see [`SECURITY.md`](../SECURITY.md)).

## Why switch to a custom domain later

- Shorter NDEF URI → more medical data fits on NTAG215/216
- Professional URL on packaging and bracelets
- Enables full-screen Android TWA via `/.well-known/assetlinks.json` at the **domain root**
- One canonical URL for manufacturing SOP ([`docs/BRACELET.md`](BRACELET.md))

## Steps (when you own a domain)

### 1. Register the domain

Register your apex (e.g. `yourbrand.com`) at any registrar (~$12–30/yr). **Do not use `redmed.app`** unless you have verified ownership.

### 2. GitHub Pages custom domain

1. Repo **Settings → Pages → Custom domain** → enter `www.redmed.com` (matches [`CNAME`](../CNAME))
2. At registrar, add DNS records GitHub shows (typically `CNAME` `www` → `maxroot1122.github.io`, plus apex redirect if desired)
3. Enable **Enforce HTTPS** in Pages settings after DNS propagates

### 3. Update canonical URL in code

Edit [`config/canonical-url`](../config/canonical-url) to the new HTTPS card URL, then:

```bash
./scripts/sync-canonical-url.sh
./scripts/sync-www-mirror.sh
```

### 4. iOS Universal Links (open RedMed app on tap)

Bracelet taps stay **HTTPS** so any phone without the app still gets the emergency card in Safari. When RedMed is installed, iOS should open the native `ScannedCardView` instead.

1. Confirm `https://www.redmed.com/.well-known/apple-app-site-association` returns JSON (deployed from this repo via Pages)
2. Xcode signing team must match AASA `appID` prefix (`33F9FQ4VBU` in [`.well-known/apple-app-site-association`](../.well-known/apple-app-site-association) — update if your Team ID changes)
3. Entitlement `applinks:www.redmed.com` is in [`ios/RedMed/RedMed.entitlements`](../ios/RedMed/RedMed.entitlements)
4. On a physical iPhone: delete/reinstall RedMed after AASA is live, then tap a written bracelet — should open the app, not Safari
5. Validate with Apple’s [CDN checker](https://search.developer.apple.com/cdn/services/v1/app-site-association/?path=www.redmed.com) once DNS/HTTPS are solid

### 5. Android TWA

1. Build signed `.aab` and get **Play App Signing** SHA-256 (Play Console → App integrity) plus upload-keystore SHA-256 (`keytool -list -v`)
2. Replace `REPLACE_WITH_PLAY_APP_SIGNING_SHA256` and `REPLACE_WITH_UPLOAD_KEYSTORE_SHA256` in [`.well-known/assetlinks.json`](../.well-known/assetlinks.json) — do not invent fingerprints
3. Push to `main` — GitHub Actions deploys `.well-known/assetlinks.json` (see [`.github/workflows/pages.yml`](../.github/workflows/pages.yml))
4. Uncomment/add your domain intent-filter in [`android/app/src/main/AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml)
5. Update `asset_statements` site in [`android/app/src/main/res/values/strings.xml`](../android/app/src/main/res/values/strings.xml) via sync script

### 6. Verify

- `https://your-domain/index.html` loads the app
- `https://your-domain/.well-known/assetlinks.json` returns JSON
- [Google Statement List Tester](https://developers.google.com/digital-asset-links/tools/generator) passes for `local.redmed.app`
- Write a test tag; tap on iPhone + Android

## Until custom domain is live

Confirm before flipping `config/canonical-url` off GitHub Pages:

```bash
curl -sI https://www.redmed.com/index.html   # must be this app, not a /lander redirect
curl -s  https://www.redmed.com/.well-known/apple-app-site-association  # must be JSON
```

Until then, new tags use `https://maxroot1122.github.io/RedMed/index.html`. Keep `legacy:https://www.redmed.com/index.html` so pairing still recognizes the domain once it goes live.

**Universal Links caveat:** Apple’s AASA must sit at the **domain apex** `/.well-known/…`. A GitHub *project* Pages site (`username.github.io/RedMed/`) cannot publish that apex file without a custom domain (or a forbidden second user-site repo). So “tap opens the iOS app” needs `www.redmed.com` → Pages + AASA from this repo — not github.io alone.

## Single repo rule

All hosting stays in **this** repo (`MaxRoot1122/RedMed`). Do not create a separate `github.io` user-site repo.
