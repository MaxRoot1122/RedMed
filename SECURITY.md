# Security

RedMed is a **local-first** emergency medical ID band. The chip holds plaintext
medical data; any smartphone tap opens the hosted card page. There is no
operator backend, no accounts, and no cloud sync. Security work focuses on
**hosted page integrity** and **safe rendering of untrusted `#d=` payloads**.

## Reporting

Open a private GitHub security advisory on
[`RedmMed/RedMed`](https://github.com/RedmMed/RedMed) for vulnerabilities
in the hosted card page or XSS in `#d=` rendering. Do not file public issues
with live API keys or real medical payloads.

## Trust root (Cloudflare Pages)

Every band tap opens the Cloudflare Pages deploy of `card/`, pushed by GitHub
Actions on every merge to `main`. Treat `main` as production:

1. Enable **branch protection** on `main` (required PR reviews, no force-push).
2. Restrict who can edit [`.github/workflows/pages.yml`](.github/workflows/pages.yml)
   and repository secrets — `CLOUDFLARE_API_TOKEN` in particular grants Pages deploy
   access.
3. Actions are pinned to **commit SHAs** (not mutable tags) in the deploy workflow.

## Google Maps API key (optional, Find 911 only — iOS in-app)

When `GOOGLE_MAPS_API_KEY` is set, the Pages workflow writes it to a
**world-readable** `config/google-api-key` file. Assume the key is public.

| Restriction | Value |
|-------------|--------|
| APIs | Geocoding + Places only |
| Web referrer (live Pages host) | `https://redmed.pages.dev/*` |
| iOS | Bundle ID `com.redmed.app` (**separate key** preferred) |
| Quotas | Hard daily caps + billing alerts |

Never commit a real key. The bracelet card (`card/`) stays offline-only — no Google calls.

## Active NFC card host

`https://redmed.pages.dev/card/` (see [`config/canonical-url`](config/canonical-url)).
New writes use HTTPS `card/#d=…` so passersby open Safari/Chrome without RedMed.

## What we deliberately do not encrypt

Passive NFC medical payloads are **plaintext** (`#d=` base64url JSON) so any
smartphone can open the emergency card. Cloning a tag is like photocopying a
wallet medical card.

## Logging

Do not log `location.hash`, NFC URLs, profile JSON, or PIN material.

## Dependencies

Almost no runtime deps (no npm, no CocoaPods). Do **not** add analytics or
crash SDKs that phone home profile or location without an explicit product decision.
