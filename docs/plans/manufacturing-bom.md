# Manufacturing BOM — vertical integration map

What you need to build RedMed hardware yourself (or with OEMs), given software already exists in this repo.

**Start with v1 (passive).** v2 (powered) is optional vertical expansion.

```mermaid
flowchart TB
  subgraph software [You already have - software]
    Web[index.html PWA]
    iOS[iOS CoreNFC app]
    Android[Android TWA]
    Pages[GitHub Pages host]
    Encode[NDEF URI writer]
  end

  subgraph v1 [v1 Manufacture - ship this first]
    Chip[NXP NTAG216 die]
    Ant[HF antenna coil 13.56 MHz]
    Inlay[PVC or PET inlay]
    Band[Medical-grade silicone band]
    Print[Logo / ICE marking]
    Pack[Box insert + QR to get.html]
    Chip --> Inlay
    Ant --> Inlay
    Inlay --> Band
    Print --> Band
    Band --> Pack
  end

  subgraph factory [Factory tools]
    Writer[USB NFC encoder station]
    QA[Phone tap QA iPhone + Android]
    Lot[Lot / UID logging]
  end

  software -.->|programs blank bands| Writer
  Writer --> Band
  Band --> QA
  QA --> Pack
```

---

## v1 — Passive medical ID bracelet (minimum viable hardware)

No battery. No charging. Phone powers the chip on tap.

### Chips / electronics

| Item | Spec | Notes |
|------|------|-------|
| **NFC IC** | **NXP NTAG216** | 888 bytes user memory; ISO 14443 Type A; NDEF URI. NTAG215 OK for tiny profiles only. |
| **Antenna** | Etched/wound HF coil matched to 13.56 MHz | Full-size; outer face of band (away from pocket). Avoid micro tags that fail through silicone. |
| **Inlay substrate** | PVC / PET / PI flexible inlay | Chip + antenna laminated before overmold. |

**Not required for v1:** MCU, BLE, battery, Qi coil, WLC IC, display, buttons, crystal, regulators.

### Mechanics / materials

| Item | Spec |
|------|------|
| Band body | Medical-grade / hypoallergenic silicone (S/M/L or 38/40/41 mm sizes) |
| Optional plate | Metal / medical ID plate with embedded inlay |
| Markings | Deboss / print: ICE, tap cue, lot code |
| Durability | Target IP67 if marketed wet/outdoor |

### Encoding & fulfillment

| Item | Role |
|------|------|
| Blank NTAG216 bands | Preferred v1 — owner writes via RedMed |
| USB NFC writer (ACR122U-class or industrial) | Optional pre-encode at warehouse |
| QA phones | iPhone + Android; locked + unlocked tap test |
| Packaging | Insert per [PACKAGING.md](../PACKAGING.md); QR → `get.html` |

### Software you already own (no new chips)

| Surface | Programs / reads |
|---------|------------------|
| [`index.html`](../index.html) | Profile → `#d=` URL; Web NFC write on Chrome Android |
| iOS app | CoreNFC write/read + verify |
| Hosted Pages | Emergency card any phone can open |

```mermaid
flowchart LR
  Owner[Owner phone] -->|Write NDEF URI| Tag[NTAG216 in band]
  Responder[Any smartphone] -->|Tap RF power + read| Tag
  Tag -->|HTTPS #d=| Card[Emergency card in browser]
```

---

## v2 — Powered band (only if you vertical-integrate further)

Adds LED + SOS side button + Qi charge. **Keep a separate NTAG216** so dead battery still opens the emergency card.

```mermaid
flowchart TB
  subgraph power [Power]
    QiCoil[Qi receive coil]
    QiIC[Qi receiver / charger IC]
    Gauge[Fuel gauge]
    Bat[LiPo cell + protection]
    QiCoil --> QiIC --> Bat
    Bat --> Gauge
  end

  subgraph compute [Compute and radio]
    MCU[BLE MCU e.g. nRF52-class]
    XTAL[Crystal / load caps]
    Reg[PMIC / LDOs]
  end

  subgraph ui [UI]
    LED[LED ledger display + driver]
    Btn[Sole side action button]
    Siren[Buzzer / piezo for SOS]
  end

  subgraph nfc [Emergency NFC - passive fallback]
    NTAG[NTAG216 + own antenna]
  end

  Bat --> Reg --> MCU
  Gauge --> MCU
  MCU --> LED
  MCU --> Btn
  MCU --> Siren
  NTAG -.->|any phone tap even if dead| Phone[Responder phone]
  MCU -.->|BLE to owner app only| OwnerPhone[Owner phone]
```

### Extra chips / parts (v2 only)

| Block | Examples of what to source | Why |
|-------|----------------------------|-----|
| Qi RX | Qi/Qi2 receiver + matching coil + ferrite | Charge without ports |
| Battery | Small LiPo + PCM/protection | Powers LED/SOS/BLE |
| Fuel gauge | Battery monitor IC or MCU ADC | LED `BAT xx%` |
| MCU + BLE | Nordic nRF52-class or similar | SOS, PIN, display, bond token |
| Display | Low-power LED matrix / ledger module + driver | Local battery + countdown |
| Button | Flush side switch (sole control) | SOS arm / cancel |
| Audio | Piezo / magnetic transducer | Loud SOS siren on-band |
| Passives | Ferrite, caps, ESD, antenna matching | Coexistence Qi vs NFC |
| **NTAG216 inlay** | Same as v1 | **Non-negotiable** emergency path |

Optional alternate charge: NFC WLC receiver (ROHM-class) instead of Qi if the band must stay ring-thin — see [WIRELESS_CHARGING.md](../WIRELESS_CHARGING.md).

---

## Vertical integration ladder

What to own in-house vs buy:

```mermaid
flowchart TB
  L0[L0 Software - done in this repo]
  L1[L1 Buy blank NTAG216 silicone bands - OEM]
  L2[L2 Own branding + packaging + QA encode]
  L3[L3 Own inlay design - antenna + NTAG216]
  L4[L4 Own silicone mold + overmold]
  L5[L5 Own v2 PCB - Qi MCU LED]
  L0 --> L1 --> L2 --> L3 --> L4 --> L5
```

| Level | You own | Buy / partner |
|-------|---------|----------------|
| **L0** | App, web, Pages URL | — |
| **L1** (recommended start) | Spec + QA | Finished blank NTAG216 bands |
| **L2** | Brand, insert, fulfillment SOP | Same bands + box printer |
| **L3** | Antenna geometry, inlay gerbers | Chip + flex fab |
| **L4** | Mold tooling, silicone compound | Overmold factory |
| **L5** | v2 schematics, firmware | PCB fab, battery cells, cert lab |

---

## Factory line (v1)

1. Receive / inspect NTAG216 inlays (reject UID-only).
2. Overmold into silicone (or mount plate).
3. Optional: encode NDEF at station (or ship blank).
4. QA matrix in [BRACELET.md](../BRACELET.md) — iPhone + Android tap.
5. Pack with disclaimers; lot mark for support.

---

## Related

- Hardware rules: [BRACELET.md](../BRACELET.md)
- Charging research: [WIRELESS_CHARGING.md](../WIRELESS_CHARGING.md)
- Packaging copy: [PACKAGING.md](../PACKAGING.md)
- Fulfillment: [FULFILLMENT.md](../FULFILLMENT.md)
- Agent catalog: [AGENT_PROMPTS.md](../AGENT_PROMPTS.md) §4
- Plan note: [wireless-charging.md](wireless-charging.md)
