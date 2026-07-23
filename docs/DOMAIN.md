# Custom domain for RedMed

GitHub project Pages (`https://maxroot1122.github.io/RedMed/`) is the **current** NFC card host once Pages is enabled (repo **Settings → Pages → Build and deployment → GitHub Actions**). Until that URL loads, do not manufacture bracelets.

**Custom domain (future):** register a domain **you control** — not `redmed.app` (see [`SECURITY.md`](../SECURITY.md): that name is an unrelated third-party storefront as of 2026-07-23).

## Why switch later

- Shorter NDEF URI → more medical data fits on NTAG215/216
- Professional URL on packaging and bracelets
- Enables full-screen Android TWA via `/.well-known/assetlinks.json` at the **domain root**
- One canonical URL for manufacturing SOP ([`docs/BRACELET.md`](BRACELET.md))

## Steps (when you own a domain)

### 1. Register the domain

Register your apex (e.g. `yourbrand.com`) at any registrar (~$12–30/yr). **Do not use `redmed.app`** unless you have verified ownership.

### 2. GitHub Pages custom domain

1. Repo **Settings → Pages → Custom domain** → enter your apex or `www` host
2. At registrar, add DNS records GitHub shows (typically `A` records to GitHub Pages IPs and/or `CNAME` `www` → `maxroot1122.github.io`)
3. Add a [`CNAME`](../CNAME) file in this repo **only after** you choose the host (e.g. `www.yourbrand.com`) — there is **no** `CNAME` in the repo today
4. Enable **Enforce HTTPS** in Pages settings after DNS propagates

### 3. Update canonical URL in code

Edit [`config/canonical-url`](../config/canonical-url) to the new HTTPS card URL, then:

```bash
./scripts/sync-canonical-url.sh
./scripts/sync-www-mirror.sh
```

### 4. Android TWA

1. Build signed `.aab` and get **Play App Signing** SHA-256 (Play Console → App integrity) plus upload-keystore SHA-256 (`keytool -list -v`)
2. Replace `REPLACE_WITH_PLAY_APP_SIGNING_SHA256` and `REPLACE_WITH_UPLOAD_KEYSTORE_SHA256` in [`.well-known/assetlinks.json`](../.well-known/assetlinks.json) — do not invent fingerprints
3. Push to `main` — GitHub Actions deploys `.well-known/assetlinks.json` (see [`.github/workflows/pages.yml`](../.github/workflows/pages.yml))
4. Uncomment/add your domain intent-filter in [`android/app/src/main/AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml)
5. Update `asset_statements` site in [`android/app/src/main/res/values/strings.xml`](../android/app/src/main/res/values/strings.xml) via sync script

### 5. Verify

- `https://your-domain/index.html` loads the app
- `https://your-domain/.well-known/assetlinks.json` returns JSON
- [Google Statement List Tester](https://developers.google.com/digital-asset-links/tools/generator) passes for `local.redmed.app`
- Write a test tag; tap on iPhone + Android

## Until domain is live

Keep `config/canonical-url` on the GitHub Pages URL. **Enable Pages first**, confirm the URL loads, then manufacture.

## Single repo rule

All hosting stays in **this** repo (`MaxRoot1122/RedMed`). Do not create a separate `github.io` user-site repo.
