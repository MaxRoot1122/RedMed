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

### LED battery display (local-only)

Battery level stays **on the watch**, not in the phone app:

- Idle / wake: LED shows charge as a short bar + percent (e.g. `BAT 72%` or a 5-segment fill).
- On Qi pad: LED shows charging state (e.g. `CHG 72%` with animated fill).
- Critical (≤20%): brief low-battery flash on wake; never block NFC medical ID.
- No cloud sync and no required in-app battery UI — fuel gauge is firmware-local on the band.

Passive **NTAG216** emergency tap must still work when the battery is dead (LED blank; chip still readable).

### Side action button (sole control)

The band has **one physical control**: a flush side action button (Apple Watch crown reference). It is the only button — no other hardware keys.

**Does not trigger SOS:** NFC tap / medical-card scan (responders must be able to tap without starting a countdown).

### SOS button behavior

When the side action button is **activated** (pressed and held / confirmed per firmware anti-pocket rules):

1. Band **immediately** plays a loud Emergency SOS–style siren (Apple Crash Detection / Emergency SOS character — piercing alternating tones) and flashes the LED so the wearer knows SOS started.
2. LED shows a **30-second countdown**.
3. Wearer can abort by pressing the side button again within 30 seconds, or by cancelling in the paired phone app (PIN required if the band is PIN-locked).
4. If not cancelled, the paired phone app auto-dials emergency contacts **#1 and #2 only** — never the doctor / contact #3.
5. Siren continues through the countdown (or until cancelled) so bystanders hear the activation.

Firmware note: the siren is generated on-band (and mirrored in the phone app overlay when the phone is the SOS surface). Do not rely on a quiet haptic-only cue.

### PIN lock

The owner can lock the bracelet with a 4-digit PIN via the app. When locked:
- The bracelet NFC data remains readable (responders can still tap).
- SOS cancel requires PIN entry in the app.
- Unlock via the app with the same PIN.

### Phone must not scan / interfere with the bracelet

Goal: the owner's phone should **not** keep an NFC field on the band during normal use.

| Layer | Rule |
|-------|------|
| **App (web)** | No background / presence NFC polling. `NDEFReader` runs only for explicit **Read** or **Write**, then aborts. |
| **App (iOS)** | CoreNFC sessions are user-started only (sheet prompt) and end after one operation — never continuous scan. |
| **Owner ignore (paired)** | When this phone has linked the band, opening that same `#d=` URL skips the emergency card and stays on My ID (use **Preview** to see the stranger view). Responders on other phones are unaffected. |
| **Hardware (v1 + v2)** | Place the NFC antenna on the **outer** face of the band (away from the wrist / phone-in-pocket side) so casual pocket coupling is weak. |
| **OS NFC** | Android/iOS system NFC can still read a tag if the phone is pressed against the band — that is intentional for responders. Owners: avoid resting the phone on the band; RedMed will not add continuous app-side scanning. |
| **Qi (v2)** | Charging coil and NFC antenna must be designed for coexistence (ferrite / time-multiplex) so a charge pad does not corrupt the NTAG. |

**Do not blacklist a smartphone MAC on the bracelet.** Passive NTAG216 cannot see, store, or filter phone MAC addresses — NFC readers do not present a Wi‑Fi/Bluetooth MAC to the tag, and modern phones randomize MACs. A MAC “blacklist” would also break the owner’s ability to rewrite the band and is the wrong tool. Use: (1) no continuous phone scan, (2) owner-ignore of the paired URL on this phone, (3) outer-face antenna. For v2 BLE, bond to a **pairing token** generated on the phone — never rely on a raw MAC.

**Do not:** leave Web NFC `scan()` running on My ID to show a "connected" dot — that continuously energizes the chip and interferes with the band.

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
- Manufacturing BOM / chips: [`docs/plans/manufacturing-bom.md`](plans/manufacturing-bom.md)
- Wireless charging: [`docs/WIRELESS_CHARGING.md`](WIRELESS_CHARGING.md)
