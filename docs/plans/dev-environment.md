# Plan: Development environment setup (Cursor Cloud)

**Source agent:** `bc-b3048808-2d8b-4ce4-9fe5-9a487c02ecc0`  
**Branch:** `cursor/setup-dev-environment-ecc0`  
**PR:** https://github.com/MaxRoot1122/RedMed/pull/21 (also early #5)  
**Status:** Merged into `main`.

## Goal

Make RedMed runnable/verifiable for Cursor Cloud agents with zero package installs.

## Todos

- [x] Document Cloud workflow in `AGENTS.md`
- [x] Update script = `true` (no deps)
- [x] `scripts/verify-web.sh` — CSP hash, `node --check`, www mirror, HTTP smoke `:8934`
- [x] Fix `initLang()` boot order (after highlight helpers)
- [x] Dev serve: `python3 -m http.server 8934 --bind 127.0.0.1`

## Multi-agent git habit (same owner)

- One repo only.
- One `cursor/<task>-…` branch per agent task.
- Merge to `main` when finished; don’t share one long-lived feature branch across concurrent AIs.
