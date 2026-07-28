# RedMed guide

### NFC bracelet — hardware & encoding

> **Product is the band.** Passive NFC bracelet holds your emergency ID on the chip. **Tap the band → any smartphone opens your emergency card in the browser.** No app for readers. The **iPhone app** (`ios/RedMed/`) programs the chip once (CoreNFC). Side-of-the-road scenario: stranger taps band → Call 911 + allergies/meds/contacts instantly.

Manufacturing spec for RedMed commercial bracelets. Software writes the same NDEF URI everywhere; this doc is the factory/QA source of truth.

### Passive NFC only (product rule)

RedMed bracelets and the app use **passive NFC only** — ISO/IEC 14443 Type A tags (NTAG21x) with NDEF URI records.

| In scope | Out of scope — do not add |
|----------|---------------------------|
| Passive NTAG215/216 inlay (no battery) | Active NFC tags, BLE beacons, UHF RFID |
| Phone powers chip on tap; chip stores data | Battery-powered wristbands, GPS trackers |
| iOS CoreNFC write once (setup app) | Continuous broadcast, "always-on" RFID |
| Data on chip until next write | Cloud-linked live tags, remote wipe radios |

The bracelet **does not transmit**. A smartphone's NFC field energizes the chip for the moment of contact; then the chip goes idle again. Effective read range is **under 6 inches (0.50 ft)** — the phone must be held within about 1–2 inches of the band for a reliable tap. Beyond 3–6 inches, the field is too weak to power the chip.

### Hardware spec (v1)

| Component | Requirement |
|-----------|-------------|
| NFC chip | **NTAG216** (NXP, 888 bytes user memory). NTAG215 acceptable for minimal profiles only. **Passive only** — reject battery-assisted or active tags. |
| Protocol | ISO/IEC 14443 Type A, NDEF read/write (13.56 MHz HF) |
| Form factor | Silicone wristband with embedded PVC inlay **or** metal/medical-style ID plate |
| Antenna | Full-size coil — avoid micro tags that fail through silicone. Read range ≤ 6 in (0.50 ft / ~15 cm); typical tap is 1–2 in (3–5 cm). |
| Durability | Target IP67 if marketed for active/outdoor use; document operating temperature |
| UID-only tags | **Reject** — must support NDEF URI records |

### Smartphone-only card (software)

Passive NFC chips cannot tell a phone from a card reader at the hardware level — any ISO 14443 device can read the URI bytes. RedMed's hosted emergency card (`#d=` view) **only renders medical data on smartphones** (iPhone/Android phone user-agents). Card readers, payment terminals, badge scanners, tablets, desktops, and other NFC gear that open the URL see a "Smartphone required" screen instead. Most fixed card readers never open a browser — they only read chip data; this gate protects the web card when something tries to load the link.

Owners can still preview on a computer using **Preview** (`?preview=1` on the link). The URI on the chip is unchanged.

**Not for:** wallet tap-to-pay terminals, hotel key encoders, retail card readers, USB NFC dongles used as scanners, or general RFID inventory wands — bracelet is for **phone tap → browser** only.

### Industrial design (v2)

| Attribute | Spec |
|-----------|------|
| Body | Medical-grade silicone, wrap-around wrist form factor, slim profile |
| Screen | LED ledger-style display — long vertically, thin horizontally (similar to Ledger hardware wallet screen) |
| Input | Single side button, glossy flat polished finish (Apple Watch crown reference); flush-mount |
| Sizes | 38 mm, 40 mm, 41 mm wrist circumference bands |
| Charging | Wireless (Qi-compatible); no exposed ports |
| Finish | Glossy polished exterior on button and bezel; matte silicone body |
| NFC chip | Same as v1 — NTAG216 embedded in silicone body |
| Durability | IP67 minimum; medical-grade hypoallergenic silicone |

#### SOS button behavior

The single side button is the hardware SOS trigger. When pressed:

1. Bracelet screen shows a **30-second countdown**.
2. Wearer has 30 seconds to press the button again (or cancel in-app) to abort.
3. If not cancelled, the paired phone app auto-dials emergency contacts #1 and #2 (skipping contact #3 / doctor).
4. If the bracelet is PIN-locked, cancelling the SOS requires entering the PIN in-app first.

#### PIN lock

The owner can lock the bracelet with a 4-digit PIN via the app. When locked:
- The bracelet NFC data remains readable (responders can still tap).
- SOS cancel requires PIN entry in the app.
- Unlock via the app with the same PIN.

### What goes on the tag

Single **NDEF Well-Known URI** record. **New bracelets** use the hosted HTTPS
target — any smartphone tap opens the browser (`card/index.html`), no app required:

```
https://<canonical-host>/card/#d=<base64url JSON profile>
```

Canonical host is defined in [`config/canonical-url`](../config/canonical-url). Run `scripts/sync.sh canonical` after changing it.

**Legacy** tags may carry `redmed://card#d=…` — RedMed installed opens native
SwiftUI (`ScannedCardView`); without the app those tags do not open in Safari.

Profile JSON schema matches [`ios/RedMed/Models/MedicalProfile.swift`](../ios/RedMed/Models/MedicalProfile.swift): `name`, `dob`, `blood`, `donor`, `allergies`, `meds`, `conditions`, `contacts` (up to 4 slots), `updated`.

**Not encrypted** — intentional so any responder's phone can read the card without an app.

### Bracelet tap experience (responder priority)

**Passerby (no RedMed):** tap → browser opens [`card/index.html`](../card/index.html) with:

1. **Call 911**
2. Patient allergies, medications, conditions, emergency contacts (tap-to-call)
3. Copy medical summary (plain text, for handing off to dispatch)

**Owner (RedMed installed):** use **Scan emergency bracelet** or NFC tab scan → native SwiftUI `ScannedCardView` (Find 911 trauma picker, richer in-app UX).

`card/index.html` registers [`card/sw.js`](../card/sw.js), a small service worker
that caches the page shell after its first successful load — repeat taps on
the same phone render fully offline after that, even with no signal. The
profile itself is never fetched from a server either way: it's encoded
entirely in the URL fragment (`#d=…`), which browsers never send over the
network. `card/index.html` has no trauma-hospital finder or GPS — that's an
in-app-only feature (owner or a phone with the app). See
[`docs/GUIDE.md#find-911--trauma-hospitals`](TRAUMA_FINDER.md).

### Encoding SOP

#### Blank bracelet (recommended v1)

1. Ship **blank** NTAG216 bracelets.
2. Owner fills profile in the **iOS app** → **Save**.
3. Write tag via **iOS Write Tag** tab or third-party app (NFC Tools) using the HTTPS card link.
4. Owner taps bracelet to verify the browser opens the card (passerby path) and in-app scan shows `ScannedCardView` on iPhone.

#### Pre-encoded at fulfillment (optional)

1. Customer completes profile at checkout (with explicit consent to encode medical data on the tag).
2. Encode NDEF URI on NTAG216 at fulfillment station.
3. QA tap on iPhone (locked and unlocked) — browser opens card without RedMed installed.
4. Ship with insert card; do **not** lock tag read-only unless you provide a clear re-write policy.

#### Capacity

The app shows byte count for the **full URI** (base URL + `#d=` + payload). NTAG216 limit ≈ **888 bytes** total on chip. Shorter canonical URLs (custom domain) leave more room for medical data.

### QA matrix (every batch)

| Scenario | Pass criteria |
|----------|----------------|
| iPhone, RedMed not installed | Browser opens `card/` emergency card (Call 911 + profile) |
| iPhone, RedMed installed | In-app scan → native SwiftUI; bare tap still opens browser (HTTPS tag) |
| Android phone, Chrome | Card renders all fields — no RedMed install |
| Locked screen | NFC opens URL (OS-dependent; test both platforms) |
| Profile near NTAG216 limit | Write succeeds; card shows all sections |
| Wet / flexed band | Tag still reads after 10 soak/flex cycles (if claiming water resistance) |
| Legacy `redmed://` tag | iOS app opens scanned card view only |

### Supplier checklist

- [ ] Samples are **NTAG216**, **passive** NDEF-capable (not UID-only, not active/BLE)
- [ ] MOQ, lead time, custom logo/molding quoted
- [ ] No **medical device** claims on supplier marketing (see terms)
- [ ] Serial or lot marking for support lookups

### Ordering samples

Budget ~$20–80 for 5–10 sample units. Search: "NTAG216 NFC silicone wristband" on Alibaba, US promo NFC vendors, or electronics distributors (Digi-Key sells bare NTAG216 tags for bench testing).


---

### iOS App Store submission

Operational steps — requires your Apple Developer account and a Mac with Xcode. Cannot be completed in CI.

### Prerequisites

- [ ] [Apple Developer Program](https://developer.apple.com/programs) enrolled ($99/yr)
- [ ] Physical iPhone (NFC does not work in Simulator)
- [ ] NTAG215/216 test tags
- [ ] Privacy policy live: `https://maxroot1122.github.io/RedMed/privacy-policy.html`

### Build on device

1. Open [`ios/RedMed.xcodeproj`](../ios/RedMed.xcodeproj)
2. **Signing & Capabilities** → select your **Team** (replace empty `DEVELOPMENT_TEAM` in project)
3. Run on iPhone (⌘R) → trust developer cert on device if needed
4. `./scripts/dev.sh build` — optional compile-check without signing

### NFC test matrix (physical)

- [ ] **Write Tag** → tap tag on second phone → **browser** opens card (HTTPS URL)
- [ ] **Read tag** imports profile into Keychain
- [ ] Legacy `redmed://` marketing link still opens in-app scanned view
- [ ] Find 911: GPS, compass, copy coordinates, trauma hospitals (transport; state → county only when 30+)
- [ ] Aid topics + CPR timer offline
- [ ] First-launch consent appears once ([`UseConsentView`](../ios/RedMed/Views/UseConsentView.swift))
- [ ] My ID form includes doctor name/phone and insurance provider/member ID (parity with web)

### Archive & upload

1. Select **Any iOS Device** → **Product → Archive**
2. **Distribute App → App Store Connect → Upload**
3. Wait for processing in App Store Connect

### App Store Connect metadata

| Field | Guidance |
|-------|----------|
| Bundle ID | `local.redmed.app` |
| Category | Medical (expect scrutiny) |
| Privacy Policy URL | Hosted `privacy-policy.html` |
| Screenshots | 6.7" and 6.1" iPhone minimum — see [`docs/GUIDE.md#store-listing-assets`](STORE_ASSETS.md) |
| App Privacy | On-device medical fields; precise location for Find 911 only while screen open; not linked to identity; not sent to developer servers |
| Review notes | Explain NFC writes unencrypted medical data to user's own tag by design; Find 911 does not auto-dial |

#### Suggested review note

> RedMed is a local-first medical ID. Users write their own profile to NFC tags they own. Tag data is intentionally unencrypted so a smartphone can read the emergency card in a browser without installing the app — not card readers or other NFC devices. Find 911 shows GPS on screen only; the app never auto-dials 911. First aid content is general public guidance, not medical advice.

### TestFlight

- [ ] Internal testing with 5–10 users
- [ ] Verify NFC write/read on real bracelets
- [ ] External beta optional before public release

### Post-launch

- Monitor App Review messages for privacy/NFC questions
- When custom domain goes live, update privacy URL in App Store Connect

See also [`ios/SETUP.md`](../ios/SETUP.md).

---

### Store listing assets

### App Store (iOS)

| Asset | Spec |
|-------|------|
| App icon | 1024×1024 (from `assets/icon.svg`) |
| iPhone 6.7" screenshots | Required (e.g. iPhone 15 Pro Max) |
| iPhone 6.1" screenshots | Required |
| iPad | Optional (iPhone-only app) |

### Keywords (iOS)

medical ID, emergency, NFC, bracelet, allergies, first aid, 911, ICE, wristband

### Support contact

**Email only:** `help.RedMed@gmail.com`

Privacy / support URL for store forms: `https://maxroot1122.github.io/RedMed/privacy-policy.html`

### Review messaging

- Not a medical device; not medical advice
- Tag data unencrypted by design for responder access
- No backend; no account required for bracelet taps

---

### Find 911 — trauma hospitals

**Status:** on `main` (merged with `get.html` QR routing, Bracelet sheet, Aid panes, and Google API verification on Find 911).

### Purpose (product copy)

**NFC bracelet priority:** When anyone taps the bracelet (`#d=` emergency card), **Call 911** and **trauma hospital transport** appear **first** — before allergies and profile fields. Same picker on Find 911 for owners.

Bundled list of **verified trauma hospitals** (Level I/II), not every ER. For **transport decisions** when the responder believes the patient **may not survive if they wait** for a closer non-trauma hospital. User picks state (county only if 30+ in state), then tells **911** they need trauma-center transport with location.

**Not:** live ER wait times, nearest hospital by GPS scan, or routine care routing.

**Google Maps Platform (Find 911 only, optional):** When `config/google-api-key` is set, GPS coordinates are sent to **Google Geocoding API** to auto-select state/county, and each listed hospital may be checked via **Places API** (`findplacefromtext`). Offline bundled data is still the source list; Google authenticates region + place match. No RedMed server. Bracelet card (`viewTrauma*`) stays offline-only manual pick.

Offline on **Find 911** and the **NFC emergency card** (`#viewView` / `viewTrauma*` pickers). No `fetch` to RedMed servers. GPS is **not** used to search hospitals — only to filter the offline index (and optional Google geocode on 911).

### UX (progressive disclosure)

1. User picks **State**.
2. If that state has **fewer than 30** centers in the bundled list → show hospitals **immediately** (no county step).
3. If **30 or more** → show **County** dropdown; list appears after county is chosen.

**Current data (112 US centers):** max **10** per state (CA, NY). With today's dataset, **state alone is always enough** — county UI is hidden unless the threshold is crossed after a data expansion.

Threshold constant: **30** (`TRAUMA_COUNTY_THRESHOLD` web, `TraumaHospitalFinder.countyThreshold` iOS).

### Files — edit together

| Area | Path | Notes |
|------|------|--------|
| iOS UI (Find 911) | [`ios/RedMed/Views/LocationView.swift`](../ios/RedMed/Views/LocationView.swift) | Trauma picker under GPS; optional Google Geocoder |
| Google API key | [`config/google-api-key.example`](../config/google-api-key.example) | Geocoding + Places; iOS in-app only ([`SECURITY.md`](../SECURITY.md)) |
| Bundled data | [`assets/trauma-hospitals.json`](../assets/trauma-hospitals.json) | Source JSON |
| iOS model | [`ios/RedMed/Models/TraumaHospitalFinder.swift`](../ios/RedMed/Models/TraumaHospitalFinder.swift) | `needsCountyPicker`, `resolvedHospitals`, `hospitals(in:)` |
| iOS UI (card + 911) | [`ios/RedMed/Views/TraumaHospitalsSection.swift`](../ios/RedMed/Views/TraumaHospitalsSection.swift) | [`ScannedCardView`](../ios/RedMed/Views/ScannedCardView.swift) + [`LocationView`](../ios/RedMed/Views/LocationView.swift) |
| iOS bundle data | [`ios/RedMed/trauma-hospitals.json`](../ios/RedMed/trauma-hospitals.json) | Must match `assets/trauma-hospitals.json` |
| Xcode project | [`ios/RedMed.xcodeproj/project.pbxproj`](../ios/RedMed.xcodeproj/project.pbxproj) | Target membership |
| macOS mirror | [`mac/RedMed.app/Contents/Resources/www/assets/`](../mac/RedMed.app/Contents/Resources/www/) | Copy trauma JSON after data edits |
| iOS setup blurb | [`ios/SETUP.md`](../ios/SETUP.md) | Feature summary for Mac/Xcode agents |

### JSON record schema

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

### Persistence (on-device only)

| Platform | Key / storage |
|----------|----------------|
| iOS | `@AppStorage("redMedTraumaState")`, `@AppStorage("redMedTraumaCounty")` |

### Sync scripts

```bash
./scripts/sync.sh trauma    # assets/ → ios/ + mac mirror
./scripts/sync.sh www       # get.html, card/, legal → mac/RedMed.app
./scripts/dev.sh verify     # CSP + mirrors after get.html / card/ edits
```

Manual: open Find 911 → pick a state → list appears without county (current data). Pick CA or NY → should show ≤10 cards instantly.

### What other agents should **not** do

- Do **not** reintroduce GPS-nearest scan across all US centers (removed for ease/speed).
- Do **not** add `fetch`/XHR for hospital data — keep bundled offline list.
- Do **not** move trauma UI below profile fields on the NFC card — responders see it first by design.
- Do **not** move trauma UI to My ID only unless product explicitly asks.
- Do **not** edit only one copy of `trauma-hospitals.json` — sync `assets/` and `ios/RedMed/`.

### Store / screenshot agents

Find 911 screenshots may show: Call 911, GPS card, **Trauma hospitals** (transport context + state picker + list), satellite disclosure. See [`docs/GUIDE.md#store-listing-assets`](STORE_ASSETS.md).
