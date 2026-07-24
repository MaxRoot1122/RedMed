# RedMed

Local-first emergency medical ID app. See `.cursorrules` for architecture, invariants, and conventions, and `README.md` for product context.

**One repo, one trunk:** all product work lives on `main` in `MaxRoot1122/RedMed`. Do not keep long-lived feature forks; land changes on `main`.

### RedMed group agent prompts
Other Cursor agents’ transcripts are often **not API-accessible** from a later cloud run. Opened prompts/plans for the RedMed Agents group live in-repo:

- [`docs/AGENT_PROMPTS.md`](docs/AGENT_PROMPTS.md) — catalog + recovered prompts
- [`docs/plans/`](docs/plans/) — executable plan copies for re-runs

Paste new prompts there (and/or add a plan file) instead of relying on another agent’s `bc-…` id.

## Cursor Cloud specific instructions

### What runs here
Only the **web app** (`index.html`) is runnable in this Linux environment. It is a single, self-contained static file — no build step, no framework, no package manager, no dependencies. The iOS (`ios/`) and Android (`android/`) targets require Xcode / the Android SDK and **cannot be built or run here**; the macOS wrapper (`RedMed.app/`) is a bash launcher for macOS only.

### Dependencies / update script
There are **no installable dependencies**. The Cloud Agent update script is a no-op (`true`). Do not add `npm install`, package managers, or service startup to it.

### Run the native iOS app (Cursor on Mac — preferred)
Double-clicking `RedMed.app` in the file tree does nothing useful — it is an app bundle (folder). Use one of:

1. **Cmd+Shift+P** → **Tasks: Run Task** → **RedMed: Launch iOS Simulator**
2. Terminal: `./scripts/run-ios-simulator.sh`
3. Ask the agent: "launch RedMed"

Edits to the product UI live in `ios/RedMed/` (SwiftUI), not `index.html`. Physical iPhone + NFC: **RedMed: Open in Xcode**, pick your device, **⌘R**.

Build output stays at `~/Library/Developer/Xcode/DerivedData/RedMed-local` (outside iCloud). Log: `~/Library/Logs/RedMed/launch.log`.

### Run the web app (dev)
Serve over localhost (not `file://` — geolocation on Find 911 requires a secure context, which localhost provides):

```
python3 -m http.server 8934 --bind 127.0.0.1
```

Then open `http://127.0.0.1:8934/index.html`. Port `8934` matches the macOS wrapper launcher; any port works. Start this yourself when needed — it does not belong in the update script.

If the Desktop browser shows CSP errors but `curl http://127.0.0.1:8934/index.html` has the correct `sha256-` hash, hard-refresh or confirm you are on **localhost** (not the GitHub Pages URL).

### Public host (any-phone NFC)
Bracelet taps open `https://maxroot1122.github.io/RedMed/`. That requires GitHub Pages (Source: GitHub Actions). Deploy workflow: `.github/workflows/pages.yml`. QR onboarding lands on `get.html`, which routes iOS → App Store, Samsung → Galaxy Store, Huawei → AppGallery, other Android → Play, with web fallback. Canonical URL config: `config/canonical-url` + `scripts/sync-canonical-url.sh`. Commercial launch docs: `docs/`.

### NFC / passive chip only
RedMed programs a **passive** bracelet chip (NDEF URI + `#d=` payload) — no battery, no broadcast. The phone energizes the chip on tap. **Passive NFC only:** do not add BLE, active RFID, UHF, or battery-powered tags. iOS uses CoreNFC with post-write read-back verify; Android Chrome can write via Web NFC in the Bracelet sheet when `NDEFReader` is available. See [`docs/BRACELET.md`](docs/BRACELET.md).

### Lint / test / build
There is **no build step** and **no automated test or lint suite** in this repo. The established verification pattern is:

```bash
./scripts/verify-web.sh
```

That checks CSP hash ↔ inline script, `node --check` on the extracted script, `index.html` mirror sync, and HTTP smoke on port **8934** (skipped with a warning if the server is not running).

Optional manual E2E (headless Chromium via Playwright in `/tmp` — not a repo dependency): save a profile on My ID, open Aid and Find 911 tabs, confirm no CSP errors in the console.

Legacy one-liners still work: extract `<script>` → `node --check`; load the page and confirm no console/CSP errors.

### Find 911 trauma hospitals

Offline bundled **trauma hospital** list on the **NFC emergency card** (`#d=` → `#viewView`, **first screen priority**) and **Find 911**. **Transport context:** verified Level I/II centers for when waiting for a closer hospital may not be survivable — user tells 911 they need trauma-center transport. **Not** GPS-based or routine ER lookup.

| Step | Behavior |
|------|----------|
| User picks state | If &lt; 30 centers in that state → show list immediately |
| 30+ in state | Show county dropdown; list after county chosen |

**Agent reference:** [`docs/TRAUMA_FINDER.md`](docs/TRAUMA_FINDER.md) — file map, JSON schema (`co` = county), i18n keys, sync checklist, optional Google API on 911 only.

**Google exception (911 only):** `connect-src https://maps.googleapis.com` in CSP; coordinates sent to Google when API key is configured — not to RedMed servers.

**Key paths:** `assets/trauma-hospitals.{json,js}`, trauma UI in `index.html` inline script (CSP hash!), `ios/RedMed/Models/TraumaHospitalFinder.swift`, `ios/RedMed/Views/LocationView.swift`, `ios/RedMed/trauma-hospitals.json`.

### Gotchas (also in `.cursorrules`)
- Editing anything inside the inline `<script>...</script>` invalidates the `sha256-` hash pinned in the CSP `<meta>` tag, which **silently disables all JS** (blocked by CSP, no error in a static read). Recompute the UTF-8 byte-for-byte SHA-256 of the exact script text and update `script-src`. CSS-only edits don't affect it.
- After any web edit, run `./scripts/sync-www-mirror.sh` to keep `RedMed.app/Contents/Resources/www/` byte-identical to root (`index.html`, `get.html`, trauma assets). Or `cp` + `diff` manually.
- If you change trauma hospital data or `assets/trauma-hospitals.js`, also copy into `RedMed.app/Contents/Resources/www/assets/` and `ios/RedMed/trauma-hospitals.json`. See **`docs/TRAUMA_FINDER.md`** or `./scripts/sync-trauma-data.sh`.
