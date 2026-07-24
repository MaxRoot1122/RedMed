# Plan: Bracelet emergency system (SOS + PIN + devices)

**Source agent:** `bc-019f83d5-cb63-7a1b-b405-4f700d444560`  
**Branch:** `cursor/bracelet-sos-pin-4560`  
**PR:** https://github.com/MaxRoot1122/RedMed/pull/28  
**Status:** Merged into `main` — re-runs should verify, not re-implement unless gaps remain.

## Goal

Bracelet v2 industrial design spec + SOS auto-call countdown, PIN lock, disconnect/reconnect, and product catalog shell.

## Todos

- [x] Document Industrial Design v2 + SOS/PIN semantics in `docs/BRACELET.md`
- [x] SOS 30s countdown overlay; dial contacts 1 & 2 via `tel:`; skip doctor
- [x] 4-digit PIN lock/unlock (hashed `localStorage`); PIN required to cancel SOS when locked
- [x] Disconnect / reconnect in bracelet sheet; reflect in header
- [x] My devices sheet + RedMed Band + “Add new / Coming soon”
- [x] CSP hash + `RedMed.app` www mirror + EN/ES i18n

## Constraints

- Passive NFC product rules still apply for the chip; do not add BLE/active radios.
- No backend; no profile uploads.
- After any `index.html` script edit: recompute CSP `sha256-` and run `./scripts/sync-www-mirror.sh` / `./scripts/verify-web.sh`.
