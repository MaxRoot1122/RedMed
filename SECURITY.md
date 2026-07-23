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
| Web referrer | `https://maxroot1122.github.io/RedMed/*` (and `http://127.0.0.1:*/*` for local dev if needed) |
| iOS | Bundle ID `local.redmed.app` (separate key preferred) |
| Quotas | Hard daily caps + billing alerts |

Never commit a real key. Use [`config/google-api-key.example`](config/google-api-key.example)
locally (gitignored path `config/google-api-key`).

## Android Digital Asset Links

[`.well-known/assetlinks.json`](.well-known/assetlinks.json) must list the
**Play App Signing** certificate SHA-256 (and optionally the upload key). Until
those fingerprints are pasted, App Links verification is incomplete — see
[`docs/ANDROID_PLAY.md`](docs/ANDROID_PLAY.md). Do not invent fingerprints.

## What we deliberately do not encrypt

Passive NFC medical payloads are **plaintext** (`#d=` base64url JSON) so any
smartphone can open the emergency card. Cloning a tag is like photocopying a
wallet medical card. Optional bracelet PIN locks SOS/unlock UX on the owner
device only — it does **not** protect NFC reads.

## Logging

Do not log `location.hash`, NFC URLs, profile JSON, or PIN material. Prefer UI
status text over `console.*` for user-facing failures.
