# RedMed — iOS app

**The product is the band.** RedMed on iPhone programs your passive NFC bracelet once. After that: **tap the band → any phone opens your emergency card.** No app for readers.

`mac/RedMed.app` is **dev-only** Simulator launcher — not a product surface.

**Double-click to open:** `ios/RedMed.xcodeproj` · **Simulator:** `ios/RedMed.app` or `ios/RedMed.command`

| File | What it does |
|------|----------------|
| **`ios/RedMed.app`** | Double-click — builds (if needed) and runs on iPhone Simulator |
| **`ios/RedMed.command`** | Same, with Terminal build output |
| **`build/RedMed-Simulator.app`** | Drag onto Simulator to reinstall (created after first launch) |

| Setting | Value |
|--------|--------|
| Bundle ID | `com.redmed.app` |
| URL scheme | `redmed://` — in-app deep links only; **new NFC writes** use HTTPS `card/#d=…` on the chip |
| Deployment | iOS 16.0+ · iPhone only |
| NFC | Read + write NDEF tags (NTAG213+) — profile rides in the URL `#d=` on the chip |

---

## Install on your iPhone (3 steps)

1. **Open** `ios/RedMed.xcodeproj` in Xcode (double-click in Finder).
2. **Plug in your iPhone** → select it in the toolbar → **RedMed** target → **Signing & Capabilities** → choose your **Team**.
3. **Run** (⌘R). First launch: **Settings → General → VPN & Device Management** → trust your developer certificate.

NFC does **not** work in Simulator — use a physical iPhone.

---

## Tabs

| Tab | What it does |
|-----|----------------|
| **My ID** | Read-only summary; **Edit** opens the form. Face ID required to edit after first save. |
| **Find 911** | Call 911, scan emergency bracelet, live GPS, trauma hospitals. |
| **Aid** | Offline first-aid topics + CPR timer. |
| **NFC** | **Program your band** — writes HTTPS `card/#d=…` to the chip. Anyone who taps sees the browser card. |

**Readers** tap the band — browser opens the card, no RedMed. **Owners** use this app once to program and optionally scan in-app.

---

## Command-line build (optional)

```bash
./scripts/dev.sh build
```

Compile-check without signing. Device install: Xcode → Run.

---

## Publishing to TestFlight / App Store

See [`docs/GUIDE.md`](../docs/GUIDE.md#ios-app-store-submission). Privacy policy: hosted `privacy-policy.html`.

`AppConfig.medicalCardBaseURL` is HTTPS `card/` (band tap → Safari). Keep in sync with [`config/canonical-url`](../config/canonical-url).

---

## Mac helpers

Desktop hub: `./scripts/setup.sh --skip-build` → `~/Desktop/RedMed/`

After editing hosted files: `./scripts/sync.sh www` and `./scripts/dev.sh verify`.
