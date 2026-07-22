# NFC bracelet — hardware & encoding

Manufacturing spec for RedMed commercial bracelets. Software writes the same NDEF URI everywhere; this doc is the factory/QA source of truth.

## Passive NFC only (product rule)

RedMed bracelets and the app use **passive NFC only** — ISO/IEC 14443 Type A tags (NTAG21x) with NDEF URI records.

| In scope | Out of scope — do not add |
|----------|---------------------------|
| Passive NTAG215/216 inlay (no battery) | Active NFC tags, BLE beacons, UHF RFID |
| Phone powers chip on tap; chip stores data | Battery-powered wristbands, GPS trackers |
| iOS CoreNFC + Web NFC write once | Continuous broadcast, "always-on" RFID |
| Data on chip until next write | Cloud-linked live tags, remote wipe radios |

The bracelet **does not transmit**. A smartphone's NFC field energizes the chip for the moment of contact; then the chip goes idle again. Effective read range is **under 6 inches (0.50 ft)** — the phone must be held within about 1–2 inches of the band for a reliable tap. Beyond 3–6 inches, the field is too weak to power the chip.

## Hardware spec (v1)

| Component | Requirement |
|-----------|-------------|
| NFC chip | **NTAG216** (NXP, 888 bytes user memory). NTAG215 acceptable for minimal profiles only. **Passive only** — reject battery-assisted or active tags. |
| Protocol | ISO/IEC 14443 Type A, NDEF read/write (13.56 MHz HF) |
| Form factor | Silicone wristband with embedded PVC inlay **or** metal/medical-style ID plate |
| Antenna | Full-size coil — avoid micro tags that fail through silicone. Read range ≤ 6 in (0.50 ft / ~15 cm); typical tap is 1–2 in (3–5 cm). |
| Durability | Target IP67 if marketed for active/outdoor use; document operating temperature |
| UID-only tags | **Reject** — must support NDEF URI records |

## Smartphone-only card (software)

Passive NFC chips cannot tell a phone from a card reader at the hardware level — any ISO 14443 device can read the URI bytes. RedMed's hosted emergency card (`#d=` view) **only renders medical data on smartphones** (iPhone/Android phone user-agents). Card readers, payment terminals, badge scanners, tablets, desktops, and other NFC gear that open the URL see a "Smartphone required" screen instead. Most fixed card readers never open a browser — they only read chip data; this gate protects the web card when something tries to load the link.

Owners can still preview on a computer using **Preview** (`?preview=1` on the link). The URI on the chip is unchanged.

**Not for:** wallet tap-to-pay terminals, hotel key encoders, retail card readers, USB NFC dongles used as scanners, or general RFID inventory wands — bracelet is for **phone tap → browser** only.

## Industrial design (v2)

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

### SOS button behavior

The single side button is the hardware SOS trigger. When pressed:

1. Bracelet screen shows a **30-second countdown**.
2. Wearer has 30 seconds to press the button again (or cancel in-app) to abort.
3. If not cancelled, the paired phone app auto-dials emergency contacts #1 and #2 (skipping contact #3 / doctor).
4. If the bracelet is PIN-locked, cancelling the SOS requires entering the PIN in-app first.

### PIN lock

The owner can lock the bracelet with a 4-digit PIN via the app. When locked:
- The bracelet NFC data remains readable (responders can still tap).
- SOS cancel requires PIN entry in the app.
- Unlock via the app with the same PIN.

## What goes on the tag

Single **NDEF Well-Known URI** record:

```
https://<canonical-host>/index.html#d=<base64url JSON profile>
```

Canonical host is defined in [`config/canonical-url`](../config/canonical-url). Run `scripts/sync-canonical-url.sh` after changing it.

Profile JSON schema matches [`index.html`](../index.html) / [`ios/RedMed/Models/MedicalProfile.swift`](../ios/RedMed/Models/MedicalProfile.swift): `name`, `dob`, `blood`, `allergies`, `meds`, `conditions`, `contacts` (3 slots), `doc` (name/phone), `insurance` (provider/id), `notes`, `updated`.

**Not encrypted** — intentional so any responder's phone can read the card without an app.

## Bracelet tap experience (responder priority)

After tap, the hosted card opens with:

1. **Call 911**
2. **Trauma hospitals** — state picker for verified trauma-center transport (when waiting may not be survivable)
3. Patient allergies, meds, contacts, doctor/insurance, notes

Trauma data is bundled offline in the page — no extra network call. See [`docs/TRAUMA_FINDER.md`](TRAUMA_FINDER.md).

## Encoding SOP

### Blank bracelet (recommended v1)

1. Ship **blank** NTAG216 bracelets.
2. Owner fills profile in web app or iOS app → **Save**.
3. Write tag via **iOS Write Tag** tab or third-party app (NFC Tools) using the HTTPS card link.
4. Owner taps bracelet to verify card opens in browser.

### Pre-encoded at fulfillment (optional)

1. Customer completes profile at checkout (with explicit consent — see [`docs/PACKAGING.md`](PACKAGING.md)).
2. Encode NDEF URI on NTAG216 at fulfillment station.
3. QA tap on iPhone + Android (locked and unlocked).
4. Ship with insert card; do **not** lock tag read-only unless you provide a clear re-write policy.

### Capacity

The app shows byte count for the **full URI** (base URL + `#d=` + payload). NTAG216 limit ≈ **888 bytes** total on chip. Shorter canonical URLs (custom domain) leave more room for medical data.

## QA matrix (every batch)

| Scenario | Pass criteria |
|----------|----------------|
| iPhone, RedMed not installed | Safari opens emergency card with Call 911 + trauma hospitals at top |
| iPhone, RedMed installed | Browser opens card (HTTPS tag) |
| Android, Chrome default | Card renders all fields |
| Android, RedMed TWA installed | Card opens in app or browser |
| Locked screen | NFC opens URL (OS-dependent; test both platforms) |
| Profile near NTAG216 limit | Write succeeds; card shows all sections |
| Wet / flexed band | Tag still reads after 10 soak/flex cycles (if claiming water resistance) |
| Legacy `redmed://` tag | iOS app opens scanned card view only |

## Supplier checklist

- [ ] Samples are **NTAG216**, **passive** NDEF-capable (not UID-only, not active/BLE)
- [ ] MOQ, lead time, custom logo/molding quoted
- [ ] No **medical device** claims on supplier marketing (see terms)
- [ ] Serial or lot marking for support lookups

## Ordering samples

Budget ~$20–80 for 5–10 sample units. Search: "NTAG216 NFC silicone wristband" on Alibaba, US promo NFC vendors, or electronics distributors (Digi-Key sells bare NTAG216 tags for bench testing).

## Related

- Custom domain: [`docs/DOMAIN.md`](DOMAIN.md)
- Packaging copy: [`docs/PACKAGING.md`](PACKAGING.md)
- Fulfillment: [`docs/FULFILLMENT.md`](FULFILLMENT.md)
