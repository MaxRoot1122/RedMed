# Find 911 — trauma hospital lookup (agent reference)

**Status:** on `main` (merged with `get.html` QR routing, Bracelet sheet, Aid panes, and Google API verification on Find 911).

## Purpose (product copy)

**NFC bracelet priority:** When anyone taps the bracelet (`#d=` emergency card), **Call 911** and **trauma hospital transport** appear **first** — before allergies and profile fields. Same picker on Find 911 for owners.

Bundled list of **verified trauma hospitals** (Level I/II), not every ER. For **transport decisions** when the responder believes the patient **may not survive if they wait** for a closer non-trauma hospital. User picks state (county only if 30+ in state), then tells **911** they need trauma-center transport with location.

**Not:** live ER wait times, nearest hospital by GPS scan, or routine care routing.

**Google Maps Platform (Find 911 only, optional):** When `config/google-api-key` is set, GPS coordinates are sent to **Google Geocoding API** to auto-select state/county, and each listed hospital may be checked via **Places API** (`findplacefromtext`). Offline bundled data is still the source list; Google authenticates region + place match. No RedMed server. Bracelet card (`viewTrauma*`) stays offline-only manual pick.

Offline on **Find 911** and the **NFC emergency card** (`#viewView` / `viewTrauma*` pickers). No `fetch` to RedMed servers. GPS is **not** used to search hospitals — only to filter the offline index (and optional Google geocode on 911).

## UX (progressive disclosure)

1. User picks **State**.
2. If that state has **fewer than 30** centers in the bundled list → show hospitals **immediately** (no county step).
3. If **30 or more** → show **County** dropdown; list appears after county is chosen.

**Current data (112 US centers):** max **10** per state (CA, NY). With today's dataset, **state alone is always enough** — county UI is hidden unless the threshold is crossed after a data expansion.

Threshold constant: **30** (`TRAUMA_COUNTY_THRESHOLD` web, `TraumaHospitalFinder.countyThreshold` iOS).

## Files — edit together

| Area | Path | Notes |
|------|------|--------|
| Web UI + logic | [`index.html`](../index.html) | `#locView` trauma under GPS (`trauma*`); optional Google via `config/google-api-key` |
| Google API key | [`config/google-api-key.example`](../config/google-api-key.example) | Geocoding + Places; gitignored `config/google-api-key`; Pages secret `GOOGLE_MAPS_API_KEY`. Key is public on Pages — lock referrer/bundle + quotas first ([`SECURITY.md`](../SECURITY.md)) |
| Bundled data (web) | [`assets/trauma-hospitals.json`](../assets/trauma-hospitals.json) | Source JSON |
| Bundled data (web load) | [`assets/trauma-hospitals.js`](../assets/trauma-hospitals.js) | `window.REDMED_TRAUMA_HOSPITALS = [...]` — keep byte-synced with `.json` |
| iOS model | [`ios/RedMed/Models/TraumaHospitalFinder.swift`](../ios/RedMed/Models/TraumaHospitalFinder.swift) | `needsCountyPicker`, `resolvedHospitals`, `hospitals(in:)` |
| iOS UI | [`ios/RedMed/Views/TraumaHospitalsSection.swift`](../ios/RedMed/Views/TraumaHospitalsSection.swift) | Shared section — [`ScannedCardView`](../ios/RedMed/Views/ScannedCardView.swift) (bracelet) + [`LocationView`](../ios/RedMed/Views/LocationView.swift) |
| iOS bundle data | [`ios/RedMed/trauma-hospitals.json`](../ios/RedMed/trauma-hospitals.json) | Must match web `.json` |
| Xcode project | [`ios/RedMed.xcodeproj/project.pbxproj`](../ios/RedMed.xcodeproj/project.pbxproj) | `TraumaHospitalFinder.swift` + `trauma-hospitals.json` in target |
| macOS mirror | [`RedMed.app/Contents/Resources/www/`](../RedMed.app/Contents/Resources/www/) | `index.html` byte-identical to root; copy `assets/trauma-hospitals.*` after data edits |
| iOS setup blurb | [`ios/SETUP.md`](../ios/SETUP.md) | Feature summary for Mac/Xcode agents |

## JSON record schema

Each object in `trauma-hospitals.json`:

| Key | Meaning |
|-----|---------|
| `n` | Hospital name |
| `lat`, `lng` | Coordinates (maps links only) |
| `l` | Trauma level (1 or 2) |
| `c` | City |
| `s` | State (2-letter) |
| `co` | County (used for narrowing when state ≥ 30 centers) |
| `p` | Phone (digits, optional formatting in UI) |

When adding rows: include **`co`** (county). One-time Census geocoder was used to backfill existing rows; new rows need a county or the county filter will not work for large states.

## Persistence (on-device only)

| Platform | Key / storage |
|----------|----------------|
| Web | `localStorage.redMedTraumaRegion` → `{ s: "TX", co: "" }` or `{ s, co }` when county used |
| iOS | `@AppStorage("redMedTraumaState")`, `@AppStorage("redMedTraumaCounty")` |

## i18n keys (web)

`locTraumaTitle`, `locTraumaLead`, `locTraumaHint`, `locTraumaState`, `locTraumaCounty`, `locTraumaPickState`, `locTraumaPickCounty`, `locTraumaVerify`, `locTraumaMaps` — English and Spanish in `STRINGS`; other langs fall back to English.

## Sync scripts

```bash
./scripts/sync-trauma-data.sh    # assets/ → ios/ + RedMed.app mirror
./scripts/sync-www-mirror.sh     # index.html, get.html, trauma assets → RedMed.app
./scripts/sync-google-api-key.sh # config/ → ios bundle (local dev)
```

```bash
# JS syntax (inline script only — external trauma-hospitals.js is separate)
python3 -c "import re; h=open('index.html').read(); m=re.search(r'<script>(.*?)</script>',h,re.DOTALL); open('/tmp/s.js','w').write(m.group(1))"
node --check /tmp/s.js

# CSP hash after inline script edit
python3 -c "
import re, hashlib, base64
s=re.search(r'<script>(.*?)</script>', open('index.html').read(), re.DOTALL).group(1)
print('sha256-'+base64.b64encode(hashlib.sha256(s.encode()).digest()).decode())
"

# Swift brace check
python3 -c "s=open('ios/RedMed/Views/LocationView.swift').read(); print(s.count('{'), s.count('}'))"
```

Manual: open Find 911 → pick a state → list appears without county (current data). Pick CA or NY → should show ≤10 cards instantly.

## What other agents should **not** do

- Do **not** reintroduce GPS-nearest scan across all US centers (removed for ease/speed).
- Do **not** add `fetch`/XHR for hospital data — keep bundled offline list.
- Do **not** move trauma UI below profile fields on the NFC card — responders see it first by design.
- Do **not** move trauma UI to My ID only unless product explicitly asks.
- Do **not** edit only one copy of `trauma-hospitals.json` — sync web `assets/`, `assets/trauma-hospitals.js`, `ios/RedMed/`, and `RedMed.app/.../assets/`.

## Store / screenshot agents

Find 911 screenshots may show: Call 911, GPS card, **Trauma hospitals** (transport context + state picker + list), satellite disclosure. See [`docs/STORE_ASSETS.md`](STORE_ASSETS.md).
