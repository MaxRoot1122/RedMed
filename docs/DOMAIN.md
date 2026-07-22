# Custom domain for RedMed

GitHub project Pages (`https://maxroot1122.github.io/RedMed/`) works today but is **long for NFC tags** and cannot host Android Digital Asset Links at `/.well-known/` on the `github.io` origin for this repo layout.

**Recommended commercial host:** `https://redmed.app/index.html` (or your registered domain).

## Why switch

- Shorter NDEF URI → more medical data fits on NTAG215/216
- Professional URL on packaging and bracelets
- Enables full-screen Android TWA via `/.well-known/assetlinks.json`
- One canonical URL for manufacturing SOP ([`docs/BRACELET.md`](BRACELET.md))

## Steps

### 1. Register the domain

Register `redmed.app` (or alternative) at any registrar (~$12–30/yr).

### 2. GitHub Pages custom domain

1. Repo **Settings → Pages → Custom domain** → enter `redmed.app`
2. At registrar, add DNS records GitHub shows (typically `A` records to GitHub Pages IPs and/or `CNAME` `www` → `maxroot1122.github.io`)
3. [`CNAME`](../CNAME) in this repo is set to `redmed.app` — keep in sync with your chosen apex host
4. Enable **Enforce HTTPS** in Pages settings after DNS propagates

### 3. Update canonical URL in code

Edit [`config/canonical-url`](../config/canonical-url) to the new HTTPS card URL, then:

```bash
./scripts/sync-canonical-url.sh
cp index.html RedMed.app/Contents/Resources/www/index.html
```

### 4. Android TWA

1. Build signed `.aab` and get keystore **SHA-256** fingerprint
2. Replace placeholder in [`.well-known/assetlinks.json`](../.well-known/assetlinks.json)
3. Push to `main` — GitHub Actions deploys it (see [`.github/workflows/pages.yml`](../.github/workflows/pages.yml))
4. Uncomment/add `redmed.app` intent-filter in [`android/app/src/main/AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml)
5. Update `asset_statements` site in [`android/app/src/main/res/values/strings.xml`](../android/app/src/main/res/values/strings.xml) via sync script

### 5. Verify

- `https://redmed.app/index.html` loads the app
- `https://redmed.app/.well-known/assetlinks.json` returns JSON
- [Google Statement List Tester](https://developers.google.com/digital-asset-links/tools/generator) passes for `local.redmed.app`
- Write a test tag; tap on iPhone + Android

## Until domain is live

Keep `config/canonical-url` on the GitHub Pages URL. **Do not manufacture bracelets** with `redmed.app` on the chip until DNS and HTTPS work.

## Single repo rule

All hosting stays in **this** repo (`MaxRoot1122/RedMed`). Do not create a separate `github.io` user-site repo.
