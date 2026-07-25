# RedMed

Local-first emergency medical ID **iPhone app**. See `.cursorrules` for
architecture, invariants, and conventions, and `README.md` for product context.

**One repo, one trunk:** all product work lives on `main` in `MaxRoot1122/RedMed`.
Do not keep long-lived feature forks; land changes on `main`.

**Product is iOS-only** (`ios/`). Web / Android / desktop are not product surfaces.

## Cursor Cloud specific instructions

### What runs here
The **iOS app cannot be built or run** in this Linux environment (needs Xcode / a Mac).
There is no installable dependency for the product. Optional static files
(`get.html`, legal pages, legacy `index.html`) can be served with:

```
python3 -m http.server 8934 --bind 127.0.0.1
```

### Dependencies / update script
There are **no installable dependencies**. The Cloud Agent update script is a
no-op (`true`). Do not add `npm install`, package managers, or service startup.

### Run the native iOS app (Cursor on Mac)
1. **Cmd+Shift+P** → **Tasks: Run Task** → **RedMed: Launch iOS Simulator**
2. Terminal: `./scripts/run-ios-simulator.sh`
3. Physical iPhone + NFC: open `ios/RedMed.xcodeproj`, pick your device, **⌘R**

**Product UI** lives in `ios/RedMed/` (SwiftUI) — Face ID app lock, Keychain,
CoreNFC, native emergency card (`ScannedCardView`). New bracelet writes use
`redmed://card#d=…` (`AppConfig.medicalCardBaseURL`).

### NFC / passive chip only
RedMed programs a **passive** bracelet chip (NDEF URI + `#d=` payload) — no
battery, no broadcast. **Passive NFC only:** do not add BLE, active RFID, UHF,
or battery-powered tags. iOS uses CoreNFC with post-write read-back verify.
See [`docs/BRACELET.md`](docs/BRACELET.md).

### Lint / test / build
No automated iOS test suite in this environment. For Swift edits:

```bash
# brace/paren balance
python3 - <<'PY'
from pathlib import Path
for p in Path('ios/RedMed').rglob('*.swift'):
    t = p.read_text()
    assert t.count('{') == t.count('}'), p
    assert t.count('(') == t.count(')'), p
print('ok')
PY
```

Optional legacy web check (only if you edited `index.html`):

```bash
./scripts/verify-web.sh
```

### Find 911 trauma hospitals
Offline bundled trauma list in the iOS app. See [`docs/TRAUMA_FINDER.md`](docs/TRAUMA_FINDER.md).
Keep `assets/trauma-hospitals.json` and `ios/RedMed/trauma-hospitals.json` in sync.

### Gotchas
- Editing Swift here is unverified until built on a Mac with Xcode.
- Do not revive Android/Play or web owner UI without an explicit ask.
- `android/` is retired — see `android/RETIRED.md`.
