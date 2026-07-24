# Security

RedMed is a **local-first** emergency medical ID. There is no operator backend, no
accounts, and no cloud sync of profile data. Security work focuses on **hosted
page integrity**, **safe rendering of untrusted `#d=` payloads**, and **optional
Google Maps key hygiene** — not identity systems.

See also [`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md).

## Reporting

Open a private GitHub security advisory on
[`MaxRoot1122/RedMed`](https://github.com/MaxRoot1122/RedMed) if you find a
vulnerability in the hosted card page, XSS in `#d=` rendering, or credential
exposure. Do not file public issues that include live API keys or real medical
payloads.

## Trust root (GitHub Pages)

Every bracelet tap opens the Pages deploy of `index.html`. Treat `main` as
production:

1. Enable **branch protection** on `main` (required PR reviews, no force-push).
2. Restrict who can edit [`.github/workflows/pages.yml`](.github/workflows/pages.yml)
   and repository secrets.
3. Actions are pinned to **commit SHAs** (not mutable tags) in the Pages workflow.

## Google Maps API key (optional, Find 911 only)

When `GOOGLE_MAPS_API_KEY` is set, the Pages workflow writes it to a
**world-readable** `config/google-api-key` file. Assume the key is public.

Before enabling the secret:

| Restriction | Value |
|-------------|--------|
| APIs | Geocoding + Places only |
| Web referrer (live Pages host) | `https://maxroot1122.github.io/RedMed/*` |
| Web referrer (custom domain, later) | `https://YOUR.DOMAIN/*` when that host serves this app |
| Local dev (optional) | `http://127.0.0.1:*/*` |
| iOS | Bundle ID `local.redmed.app` (**separate key** preferred) |
| Quotas | Hard daily caps + billing alerts |

Never commit a real key. Use [`config/google-api-key.example`](config/google-api-key.example)
locally (gitignored path `config/google-api-key`). The web client rejects empty keys and
`YOUR_GOOGLE…` placeholders. CSP `connect-src` allows `https://maps.googleapis.com`
for Find 911 only.

## Android Digital Asset Links

[`.well-known/assetlinks.json`](.well-known/assetlinks.json) must list the
**Play App Signing** certificate SHA-256 (and optionally the upload key). Until
those fingerprints are pasted, App Links verification is incomplete — see
[`docs/ANDROID_PLAY.md`](docs/ANDROID_PLAY.md). Do not invent fingerprints.

GitHub **project** Pages (`username.github.io/RedMed/`) cannot publish
`/.well-known/assetlinks.json` at the github.io **apex**. Full-screen TWA App Links
need a custom domain (or equivalent) serving this file at the domain root — see
[`docs/DOMAIN.md`](docs/DOMAIN.md).

## Known gap: Universal Links need a custom domain you control

**Active NFC card host today:** `https://maxroot1122.github.io/RedMed/index.html`
(see [`config/canonical-url`](config/canonical-url)). No marketing website / custom
domain in production yet. Support contact is email only.

Apple requires AASA at the **domain apex**. A project Pages path alone cannot satisfy
that. When you add a domain (see [`docs/DOMAIN.md`](docs/DOMAIN.md)):

1. Browser taps without the app still open Safari (correct).
2. Installed iPhone users can get the native emergency card via Universal Links.
3. In-app **Scan emergency bracelet** always shows native `ScannedCardView`.

Do **not** switch tag writes to `redmed://` only — that bricks Android and
any phone without RedMed installed. Do **not** use `redmed.app` (unrelated third-party).

## What we deliberately do not encrypt

Passive NFC medical payloads are **plaintext** (`#d=` base64url JSON) so any
smartphone can open the emergency card. Cloning a tag is like photocopying a
wallet medical card. Optional bracelet PIN locks SOS/unlock UX on the owner
device only — it does **not** protect NFC reads.

## Logging

Do not log `location.hash`, NFC URLs, profile JSON, or PIN material. Prefer UI
status text over `console.*` for user-facing failures.

## Dependencies

Almost no runtime deps (no npm, no CocoaPods). On Android release bumps, re-check
`androidbrowserhelper` / AppCompat advisories in
[`android/app/build.gradle`](android/app/build.gradle). Do **not** add analytics or
crash SDKs that phone home profile or location without an explicit product decision.
