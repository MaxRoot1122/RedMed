# RedMed

Local-first emergency medical ID for **iPhone**. No accounts. No backend. Profile data stays on your device and on the passive NFC tag you write.

<p align="center">
  <a href="ios/SETUP.md">iOS setup</a>
  ·
  <a href="privacy-policy.html">Privacy</a>
  ·
  <a href="terms-of-service.html">Terms</a>
</p>

## What it is

Fill in allergies, meds, contacts, and notes once in the **RedMed iOS app**. Save. Write the link to a **passive NTAG215/216** bracelet (no battery — your phone powers the chip on tap). Another **iPhone with RedMed** can scan the band to open the emergency card in-app.

**Product surface:** iOS only (`ios/`). Not a web app, not Android, not a desktop product.

## Surfaces

| Path | Role |
|------|------|
| [`ios/`](ios/) | **The RedMed app** (SwiftUI) — Keychain profile, NFC read/write, Aid, Find 911, Face ID lock |
| [`mac/`](mac/) | Mac helpers — Simulator launcher (`RedMed.app`, `RedMed.command`) |
| [`get.html`](get.html) | Packaging QR → App Store (iPhone only) |
| [`privacy-policy.html`](privacy-policy.html) / [`terms-of-service.html`](terms-of-service.html) | App Store / legal host |
| [`android/`](android/) | **Retired** — see [`android/RETIRED.md`](android/RETIRED.md) |
| [`index.html`](index.html) | Legacy HTTPS emergency card for older tags only — not the product UI |

## Quick start

1. Open [`ios/RedMed.xcodeproj`](ios/SETUP.md) in Xcode → Run on your iPhone
2. Fill in your info → save
3. **NFC** tab → write a blank NTAG bracelet
4. Scan with RedMed on an iPhone to open the native emergency card

NFC does not work in Simulator — use a physical iPhone.

## Docs

| Doc | Purpose |
|-----|---------|
| [`ios/SETUP.md`](ios/SETUP.md) | Xcode / device install |
| [`mac/SETUP.md`](mac/SETUP.md) | Mac Simulator launcher |
| [`docs/BRACELET.md`](docs/BRACELET.md) | NTAG216 spec, encoding SOP, QA |
| [`docs/IOS_APP_STORE.md`](docs/IOS_APP_STORE.md) | TestFlight / App Store checklist |
| [`docs/TRAUMA_FINDER.md`](docs/TRAUMA_FINDER.md) | Find 911 trauma centers |
| [`SECURITY.md`](SECURITY.md) | Threat posture & reporting |

New bracelet writes use hosted `card/#d=…` — any iPhone tap opens Safari (no app for passersby). Owners scan in native SwiftUI (see [`config/canonical-url`](config/canonical-url)).

## Privacy

- Tag data is **not encrypted** — intentional for emergency responders with RedMed.
- No cloud sync of profile data.
- Keep entries short; the app warns when the full URI exceeds tag capacity.

## License

Proprietary — © 2026 RedMed LLC. See [`LICENSE`](LICENSE) and [terms](terms-of-service.html).
