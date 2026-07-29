# RedMed

**Tap the band. Phone opens your emergency card.**

RedMed is a **passive NFC medical bracelet**. Your allergies, meds, contacts, and blood type live on the chip. If you're found incapacitated — roadside, crash, collapse — a stranger taps the band with **any smartphone**. Their browser opens your emergency card instantly. **No app for readers.**

The **iPhone app** programs the band once (CoreNFC). No accounts. No backend. Data stays on the chip and on your phone.

<p align="center">
  <a href="ios/SETUP.md">iOS setup</a>
  ·
  <a href="privacy-policy.html">Privacy</a>
  ·
  <a href="terms-of-service.html">Terms</a>
</p>

## What you get

| What | Role |
|------|------|
| **The band** | Passive NTAG chip — tap opens emergency card in any phone's browser |
| [`card/`](card/) | Hosted emergency card (`#d=`) — Call 911, allergies, meds, contacts |
| [`ios/`](ios/) | **Setup app** — fill profile, write chip once, optional in-app scan |
| [`get.html`](get.html) | Box QR → App Store (program your band on iPhone) |
| [`ios/RedMed.app`](ios/RedMed.app) | Dev only — Simulator launcher |

## Owner setup (once)

```bash
git clone https://github.com/RedmMed/RedMed.git
cd RedMed
./scripts/setup.sh --skip-build
```

1. Install RedMed on **iPhone** (open `ios/RedMed.xcodeproj` in Xcode, or App Store when live)
2. Fill **My ID** → Save
3. **NFC** tab → hold band to phone once
4. Done — anyone who taps the band sees your card. No RedMed install needed.

NFC requires a physical iPhone (not Simulator).

## Docs & scripts

| Path | Purpose |
|------|---------|
| [`ios/SETUP.md`](ios/SETUP.md) | Xcode, device install, Simulator launcher |
| [`docs/GUIDE.md`](docs/GUIDE.md) | Band spec, App Store checklist, trauma finder |
| [`SECURITY.md`](SECURITY.md) | Threat posture & reporting |
| [`scripts/sync.sh`](scripts/sync.sh) | URLs, trauma data, www mirror |
| [`scripts/dev.sh`](scripts/dev.sh) | `clean`, `build`, `verify`, `icons` |

New writes use hosted `card/#d=…` (see [`config/canonical-url`](config/canonical-url)).

## Privacy

- Chip data is **not encrypted** — intentional so any phone can read it in an emergency.
- No cloud sync of profile data.
- Keep entries short; the app warns when the URI exceeds tag capacity.

## AI agents (Cursor Cloud)

**One repo, one trunk:** `main` in `RedmMed/RedMed`.

The iOS app needs Xcode on a Mac. Static hosting: `python3 -m http.server 8934 --bind 127.0.0.1`.

After `get.html` / `card/` edits: `./scripts/dev.sh verify`. Trauma data: `./scripts/sync.sh trauma`.

## License

Proprietary — © 2026 RedMed LLC. See [`LICENSE`](LICENSE) and [terms](terms-of-service.html).
