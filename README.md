# RedMed

Local-first emergency medical ID for NFC bracelets. No accounts. No backend. Profile data stays on your device and on the tag you write.

<p align="center">
  <a href="https://maxroot1122.github.io/RedMed/">Live demo</a>
  ·
  <a href="privacy-policy.html">Privacy</a>
  ·
  <a href="terms-of-service.html">Terms</a>
</p>

## What it is

Fill in allergies, meds, contacts, and notes once. Save. Write the link to a **passive NTAG215/216** bracelet (no battery — your phone powers the chip on tap). Only a **smartphone** that taps sees the emergency card — no app required for them.

The standard RedMed bracelet is a **passive NFC tag** with no battery. It does not need charging; the reader phone powers it briefly during a tap.

**Out of the box:** print a QR code to `https://maxroot1122.github.io/RedMed/get.html` — it detects iPhone vs Android and opens the right app store. Only the **purchaser** needs RedMed to fill the form and write the bracelet (My ID → **Bracelet**, top right).

Your data lives in:

- the browser's **local storage** on this device, and
- the **URL itself** (`#d=` base64), which is what goes on the tag

## Surfaces

| Path | Role |
|------|------|
| [`ios/`](ios/) | **Primary owner app** (SwiftUI) — Keychain profile, NFC read/write, Aid, Find 911, first-launch consent |
| [`index.html`](index.html) | NFC emergency card (any phone that taps the band) + Android/web owner fallback |
| [`android/`](android/) | Trusted Web Activity wrapper around the hosted page |
| [`RedMed.app/`](RedMed.app/) | macOS launcher — builds/runs native iOS in Simulator (`scripts/run-ios-simulator.sh`) |
| [`assets/`](assets/) | **App cover** `icon.svg` (+ PNGs/ICNS); web `wordmark.svg`; iOS `wordmark-ios.svg`. See [`docs/BRAND.md`](docs/BRAND.md). |
| [`docs/`](docs/) | Commercial launch, brand, trauma finder, stores, fulfillment |

## Quick start

**iPhone (preferred):** open [`ios/RedMed.xcodeproj`](ios/SETUP.md) → Run, or double-click [`RedMed.app`](RedMed.app/) on a Mac (Simulator).

1. Fill in your info → save
2. **Write Tag** / Bracelet setup → blank NTAG bracelet
3. Tap the band — emergency card opens in the phone's browser (`index.html#d=…`)

**Web / Android fallback:** [hosted card](https://maxroot1122.github.io/RedMed/) · [`android/SETUP.md`](android/SETUP.md)

iOS: [`ios/SETUP.md`](ios/SETUP.md) · Android: [`android/SETUP.md`](android/SETUP.md)

## Commercial bracelet launch

| Doc | Purpose |
|-----|---------|
| [`docs/BRACELET.md`](docs/BRACELET.md) | NTAG216 spec, encoding SOP, QA matrix |
| [`docs/DOMAIN.md`](docs/DOMAIN.md) | Custom domain + Android asset links |
| [`docs/IOS_APP_STORE.md`](docs/IOS_APP_STORE.md) | TestFlight / App Store checklist |
| [`docs/ANDROID_PLAY.md`](docs/ANDROID_PLAY.md) | Play Console checklist |
| [`docs/STORE_ASSETS.md`](docs/STORE_ASSETS.md) | Screenshots & listing copy |
| [`docs/PACKAGING.md`](docs/PACKAGING.md) | Box insert & checkout disclaimers |
| [`docs/FULFILLMENT.md`](docs/FULFILLMENT.md) | E-commerce & support workflow |
| [`docs/TRAUMA_FINDER.md`](docs/TRAUMA_FINDER.md) | Find 911 trauma centers — agent handoff (state/county UX, bundled data) |
| [`SECURITY.md`](SECURITY.md) | Secrets, Pages trust root, Maps key locks, reporting |
| [`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md) | What we protect / deliberately do not |

Canonical NFC URL: [`config/canonical-url`](config/canonical-url) — run `./scripts/sync-canonical-url.sh` after changes.

## Privacy

- Tag data is **not encrypted** — anyone who taps can read (intentional for responders).
- No cloud sync of profile data.
- Keep entries short; the UI warns when the full URI exceeds tag capacity.

## License

Proprietary — © 2026 RedMed LLC. See [`LICENSE`](LICENSE) and [terms](terms-of-service.html).
