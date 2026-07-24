# Plan: NFC bracelet commercial launch

**Source agent family:** `bc-e86e8012-c2bf-4d8c-b2b0-d965e5f8506a` (`*-506a`)  
**Branch:** `cursor/nfc-bracelet-commercial-launch-506a`  
**PR:** https://github.com/MaxRoot1122/RedMed/pull/16  
**Status:** Code/docs merged — remaining work is mostly owner ops outside the repo.

## Goal

Ship NFC bracelet commercial launch: universal HTTPS tags, commercial docs, deploy assets, store readiness.

## Todos (in-repo)

- [x] iOS/web NFC writes use hosted HTTPS card URL (`AppConfig.medicalCardBaseURL`); capacity checks on full URI
- [x] Doctor / insurance fields; iOS first-launch consent
- [x] `config/canonical-url` + `scripts/sync-canonical-url.sh`
- [x] Pages deploy for `.well-known/assetlinks.json` + `CNAME`
- [x] Docs: `BRACELET`, `DOMAIN`, store checklists, packaging, fulfillment
- [x] LICENSE, Play listing copy, legal pages in macOS wrapper
- [x] Passive NFC only + smartphone-only card gate (follow-on PRs #27 / related)

## Owner follow-ups (outside / config)

- [ ] Register domain + DNS per `docs/DOMAIN.md`; run `./scripts/sync-canonical-url.sh`
- [ ] Real App Store / Play / Galaxy / AppGallery listing IDs in `get.html` / `AppConfig`
- [ ] Order NTAG216 samples; run QA matrix in `docs/BRACELET.md`
- [ ] Store screenshots + feature graphic export
- [ ] Storefront per `docs/FULFILLMENT.md`

## Constraints

- Sole repo: `MaxRoot1122/RedMed` — no second `github.io` repo.
- Passive NTAG only; strangers open the card in a smartphone browser.
