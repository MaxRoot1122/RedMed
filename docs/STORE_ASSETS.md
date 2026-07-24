# Store listing assets

Templates and requirements for App Store Connect and Google Play. Raster screenshots must be captured on real devices or simulators — not generated in-repo.

## App icon

Source: [`assets/icon.svg`](../assets/icon.svg). Regenerate PNGs with `./scripts/generate-icons.sh` (requires Inkscape or `rsvg-convert`).

| Platform | Location |
|----------|----------|
| iOS | [`ios/RedMed/Assets.xcassets/AppIcon.appiconset/AppIcon.png`](../ios/RedMed/Assets.xcassets/AppIcon.appiconset/AppIcon.png) — **single 1024×1024** (Xcode scales) |
| Play | [`play/listing/play-store-icon-512.png`](../play/listing/play-store-icon-512.png) |

## Google Play

| Asset | Size | File |
|-------|------|------|
| Feature graphic | 1024 × 500 | Export [`play/listing/feature-graphic.svg`](../play/listing/feature-graphic.svg) to PNG |
| Phone screenshots | Min 2, 16:9 or 9:16 | Capture from device — My ID, emergency card (`#d=`), Find 911, Aid |
| Short description | ≤ 80 chars | [`play/listing/short-description.txt`](../play/listing/short-description.txt) |
| Full description | ≤ 4000 chars | [`play/listing/full-description.txt`](../play/listing/full-description.txt) |

## Apple App Store

| Asset | Requirement |
|-------|-------------|
| iPhone 6.7" screenshots | Required (e.g. iPhone 15 Pro Max) |
| iPhone 6.1" screenshots | Required |
| iPad | Optional (iPhone-only app) |
| Promotional text | Optional — emphasize NFC bracelet, no account, local-first |

### Suggested screenshot set

1. **My ID** — profile form with allergies highlighted
2. **Card preview** — responder view with `#d=` card
3. **NFC Write** — Write Tag screen with capacity note
4. **Find 911** — GPS + trauma hospitals (transport context; state picker; county only if 30+)
5. **Aid** — topic list + CPR timer

## Keywords (iOS)

medical ID, emergency, NFC, bracelet, allergies, first aid, 911, ICE, wristband

## Support URL

Use hosted privacy/contact: `https://www.redmed.com/privacy-policy.html`.

## Review messaging

- Not a medical device; not medical advice
- Tag data unencrypted by design for responder access
- No backend; no account required for bracelet taps
