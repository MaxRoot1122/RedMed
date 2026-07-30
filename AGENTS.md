# AGENTS.md

## Cursor Cloud specific instructions

### What this repo is
RedMed is a passive NFC medical-ID band. Two surfaces live here:
- **Static hosted web** — the runnable/testable product on this Linux VM. `card/` is the emergency card that opens when a band is tapped; `get.html` (mirrored to `/get`) is the owner band-setup page; `privacy-policy.html` / `terms-of-service.html` are legal pages. Assets in `assets/`.
- **iOS SwiftUI setup app** — `ios/` plus the root `*.swift` files and `RedMed.xcodeproj`. This is the one-time band programmer (CoreNFC). It needs macOS + Xcode (`xcodebuild`) and cannot be built or run on this Linux cloud VM. NFC writes require a physical iPhone (Simulator can't do NFC).

### Tooling / dependencies
No dependency install step is required. This is a pure static site plus Python-stdlib and `node` (used only for JS syntax checks). There is no package manager, lockfile, `package.json`, or `requirements.txt`. `python3` and `node` are already present in the base image.

### Run the web app (dev)
Serve from the repo root:

```bash
python3 -m http.server 8934 --bind 127.0.0.1
```

`http://127.0.0.1:8934/get.html` renders the owner setup page (its JS auto-detects the device and populates the CTA).

Gotcha: the repo root is **not** the full deployed site root. The deployable site is assembled by `.github/workflows/pages.yml` into `_site/` (it generates `/get/index.html`, copies legal pages, `assets/`, and `card/`). Serving the raw repo root therefore 404s on `/get/`, `/privacy-policy.html`, and `/terms-of-service.html` (the legal pages live under `ios/` and `docs/`, not root; `/get/` is build-generated). To preview a full site locally, replicate the `pages.yml` build steps into a `_site/` dir and serve that, or use `./scripts/sync.sh www`.

### Lint / verify
```bash
./scripts/dev.sh verify   # == scripts/verify-web.sh
```
This checks inline-script CSP `sha256` hashes, runs `node --check` on inline scripts + `card/sw.js`, verifies required assets, checks `config/canonical-url` is synced into `ios/RedMed/AppConfig.swift`, and does an HTTP smoke test against `:8934`. It only `WARN`s (does not fail) on the missing `ios/RedMed.app/...` mirror because that dev-only launcher bundle was removed from the repo. After editing any inline `<script>` in `get.html` or `card/index.html` you must recompute the CSP hash or `verify` fails with a "CSP hash mismatch"; if it fails on `card/index.html`, first check for unresolved git merge-conflict markers inside `card/`.

### iOS
`./scripts/dev.sh build` runs `xcodebuild` (macOS only). On this VM it will error with "xcodebuild not found" — expected, not an environment fault.
