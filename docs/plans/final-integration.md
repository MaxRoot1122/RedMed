# Plan: Final codebase integration

**Source agent:** `bc-019f83cc-ba7c-7abf-88a1-d21f5c664af8`  
**Branch:** `cursor/final-integration-4af8`  
**PR:** https://github.com/MaxRoot1122/RedMed/pull/25  
**Status:** Merged into `main`.

## Goal

One trunk: merge outstanding draft feature PRs into `main` with conflicts resolved.

## Todos

- [x] Fold in verify-web / `initLang` fix, emergency SMS, bracelet live link, modern UI, RedMed nav, trauma hospitals, commercial launch assets
- [x] Prefer current `main` schema where conflicts (3-contact accordion, local-only privacy, condition chips)
- [x] Close / supersede obsolete drafts
- [x] `./scripts/verify-web.sh` + Swift brace/paren checks

## Constraints

- Stay on one repo / one `main`.
- Google Maps API only as Find 911 exception; never send profile/NFC data to RedMed servers.
