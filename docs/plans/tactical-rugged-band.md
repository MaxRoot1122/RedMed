# Plan: Tactical Rugged Silicone Band (Armed Forces Path)

**Status:** Research + hardware roadmap (not yet in production)  
**Related:** [`docs/BRACELET.md`](../BRACELET.md), [`Product requirements.md`](../../Product%20requirements.md), [`docs/plans/nfc-bracelet-commercial-launch.md`](nfc-bracelet-commercial-launch.md)  
**SKU working name:** **RedMed Tactical Band** (passive NFC only — no battery, no BLE)

---

## Executive summary

RedMed’s core promise — **any smartphone tap opens a full emergency medical card with no app, no login, and no light** — maps directly to field medicine and combat-casualty care, where responders need blood type, allergies, medications, and contacts in seconds, not after unlocking a phone or scanning a QR code in mud or darkness.

This plan defines a **rugged, all-environment silicone wristband** with:

1. **Passive NTAG216** NDEF URI (same encoding as today’s app — see [`docs/BRACELET.md`](../BRACELET.md))
2. **IP68** waterproof construction and wide operating temperature
3. **Magnetic clasp + mechanical retention holder** so the band stays put during PT, ruck marches, weapons handling, and water ops
4. **Optional breakaway safety** on a secondary keeper (snag release under high pull force)
5. A phased path from **sample units → environmental QA → veteran/military pilot → procurement conversations**

**Important product boundary:** This SKU stays **passive NFC only**. The v2 “smart band” concept in `docs/BRACELET.md` (LED screen, Qi charging, SOS button) is a separate, later product line. The armed-forces entry point should be the **simple, zero-maintenance passive band** — no charging in the field, no firmware, no radio signature beyond a brief phone-powered tap.

---

## Why this form factor for military use

| Need in the field | Dog tag / engraved ID | Phone Medical ID | QR bracelet | RedMed passive NFC band |
|-------------------|----------------------|------------------|-------------|-------------------------|
| Works unconscious / phone locked | Partial (static text only) | No | No (needs camera + light) | **Yes** |
| Full med list + contacts | No (space limited) | Yes (if phone present) | Depends on backend | **Yes (on chip)** |
| No app for responder | Yes | No | Often no | **Yes** |
| Update after med change | Re-issue tag | Edit phone | Re-print / cloud | **Re-write tag (owner phone)** |
| No cloud / no account | Yes | No | Often no | **Yes (by design)** |
| Works offline after first page load | N/A | No | Varies | **Yes (bundled trauma data on card)** |
| No battery / no maintenance | Yes | Phone-dependent | Usually yes | **Yes** |

Research on **NATO Field Medical Card (NFMC)** workflows shows allied militaries exploring **NFC as a digital carrier** for casualty traceability during evacuation — replacing paper cards that degrade, smear, or become illegible ([UVigo TFG on NFMC + NFC](https://calderon.cud.uvigo.es/items/ef0289a1-fdf1-404a-aff6-d1d3978eff14)). RedMed’s offline `#d=` payload is not a full NFMC replacement today, but it covers the **first 60 seconds** every medic and corpsman cares about: **blood type, allergies, meds, who to call, call 911 / trauma-center context**.

Commercial medical NFC silicone bands (Hero Link, Contact Co., Tap and Share) validate market demand for **waterproof sport silicone + tap-to-read**. RedMed’s differentiator for service members: **data lives on the tag, not a vendor cloud**, aligned with [`SECURITY.md`](../../SECURITY.md) and product rules.

---

## Hardware architecture

### 1. Band body

| Attribute | Target spec | Rationale |
|-----------|-------------|-----------|
| Material | **Medical-grade liquid silicone rubber (LSR)**, hypoallergenic, latex-free | Skin contact 24/7; NATO-adjacent hygiene expectations |
| Band width | **22–25 mm** | Room for debossed **ICE / NFC** markers + full antenna inlay |
| Thickness | **2.5–3.5 mm** body (excluding clasp module) | Balance durability vs. comfort under watch / gloves |
| Colors | Matte **OD green**, **coyote tan**, **black**, **rescue red** accent stripe | Low visual signature + high-contrast tap zone option |
| Durability rating | **IP68** (1 m+ submersion, 30+ min — validate with supplier) | Swim ops, rain, blood wash-down, decon rinse |
| Operating temp | **−40 °C to +85 °C** (design); chip rated per NXP NTAG216 datasheet | Arctic, desert, engine-compartment heat in vehicles |
| Chemical exposure | Document resistance to **sunscreen, DEET, diesel/gun oil, chlorinated water, isopropyl wipe** | Field realism — not full CBRN suit integration in v1 |

### 2. Magnetic clasp + retention holder (“stay put when active”)

Consumer sport bands use **magnetic slide clasps** that fail under load unless a **second mechanical lock** is added. For RedMed Tactical, specify a **dual-security closure**:

```
┌─────────────────────────────────────────────────────────────┐
  TAIL END                          CLASP MODULE (POM + 316 SS)
  ─────────                         ───────────────────────────
  [ silicone strap ]                ┌─────────────────────┐
  with perforations or              │ Neodymium latch    │
  micro-adjust holes                │ (embedded, capped)  │
        │                           ├─────────────────────┤
        └──── pin ──► [ ○ hole ]    │ Pin-and-tuck slot   │  ◄── free tail
                                    │ OR silicone keeper  │      passes through
                                    │ loop (fixed ring)   │      and locks
                                    └─────────────────────┘
              ▲
              └── NFC TAP PAD (opposite side of wrist, 180° from clasp)
```

| Component | Spec |
|-----------|------|
| Primary closure | **Magnetic buckle** — embedded magnets in ** polymer housing** (POM/nylon), not exposed steel on skin side |
| Retention holder | **Pin-and-tuck** through nearest adjustment hole **or** molded **silicone keeper loop** (like watch band retainers) — prevents tail flapping and stops magnet-only slip during burpees, rope climbs, ruck shifts |
| Breakaway (optional tier) | **Plastic safety insert** in keeper path rated to release at **~4–6 kg** pull — reduces snag risk on kit; band remains readable if separated |
| Adjustment | **Micro-hole ladder** (8–12 positions) or **stepless magnetic rail** with indexed detents — fit **160–220 mm** wrist (S/M/L SKUs or one adjustable) |
| Glove compatibility | Clasp operable with **thin nitrile or flight glove**; tap pad locatable by **raised tactile ring** |

**Do not** ship magnet-only closure without the retention holder — field feedback from sport-band category consistently cites **magnet slip under sweat and vibration** as the failure mode.

### 3. NFC inlay (critical path)

| Parameter | Requirement |
|-----------|-------------|
| Chip | **NXP NTAG216** (888 bytes user NDEF) — same as [`docs/BRACELET.md`](../BRACELET.md) |
| Protocol | ISO/IEC 14443 Type A, NFC Forum Type 2 |
| Payload | Single NDEF URI → `https://<canonical-host>/index.html#d=<profile>` |
| Antenna | **Custom FPC inlay 45 × 12 mm**, 4–6 turns — not a 10 mm dot tag |
| Placement | **Volar tap pad** (inside wrist) or **dorsal flat zone** — pick one and QA both wet/flex; **minimum 50 mm arc distance from clasp magnets** |
| Ferrite shield | **0.3–0.5 mm ferrite sheet** (e.g. TDK IFL class) between antenna and wrist tissue **and** between antenna and any metal clasp hardware |
| Read target | **≥95% first-tap success** at 1–2 in (3–5 cm) on iPhone + Pixel after soak/flex cycle |
| Write protection (optional) | NTAG **write-only password (PROT=0)** after owner programs — prevents field tampering; **reads stay open** for responders |

#### Magnet ↔ NFC interference (must design around)

Neodymium magnets within **~3–5 cm** of an NFC coil can cut effective read range by **50%+**. Mitigations (mandatory in mechanical design):

1. **Physical separation** — inlay on opposite side of band from clasp magnets  
2. **Ferrite flux shield** behind the antenna  
3. **Non-magnetic clasp hardware** where possible (316 SS pin, polymer body; magnet fully encapsulated)  
4. **Factory QA**: read test with clasp closed vs. open; wet vs. dry

Reference: wearable NFC antenna guides recommend ferrite-backed FPC inlays in 2 mm silicone overmold for **3–5 cm on-body range** ([NFC wearable antenna design](https://nfcwork.com/nfc-antenna-design-for-wearable-form-factors/)).

### 4. Visual identification (responder-facing)

| Element | Purpose |
|---------|---------|
| **Star of Life** or red cross mark (deboss + color fill) | EMS/medic recognition — international convention |
| **NFC wave icon** + **“TAP PHONE”** (all caps, no emoji on molded surface) | Stranger knows what to do without training |
| **Reflective strip** (3M Scotchlite class, narrow) | Night / low-light locate on wrist |
| **Raised tactile ring** around tap zone | Gloved hand finds sweet spot |

Align colors with app `--accent` (#dc2626) and slate body per [`docs/BRAND.md`](../BRAND.md).

### 5. Owner-phone ignore (software — not hardware)

Passive chips **cannot** block the owner’s phone. After pairing on that device, RedMed **skips the emergency UI** when the same `#d=` hash is seen (`isOwnPairedBraceletHash()` in `index.html`). Strangers always get the full card. See prior NFC research and [`SECURITY.md`](../../SECURITY.md).

---

## Environmental durability matrix (design verification)

Every production batch should pass a subset of these before “all environments” marketing claims:

| Environment | Test | Pass criteria |
|-------------|------|---------------|
| **Maritime / rain** | IPX8 soak 1 m, 30 min; read immediately after | NFC read ≤2 s to URL open |
| **Desert / UV** | 72 h UV chamber or outdoor rack; 500 flex cycles | No delamination; read success ≥95% |
| **Arctic** | −20 °C chamber, 4 h; flex while cold | No crack; read success ≥95% |
| **Heat** | +60 °C chamber, 4 h (vehicle dash proxy) | Magnet pull force within 80% of spec; NFC OK |
| **Mud / blood proxy** | Tap through thin dried mud smear on tap pad | Readable after wipe; document if wipe required |
| **DEET / sunscreen** | 24 h chemical soak (controlled) | No silicone swell >5%; NFC OK |
| **Flex fatigue** | 1,000 wrist flex cycles around 50 mm mandrel | Inlay intact; read ≥95% |
| **Snag** | Breakaway keeper releases at rated force; band undamaged | No choking hazard; band still wearable |
| **Drop** | 1.5 m drop × 6 faces on packed band | Clasp intact; NFC OK |

Document operating limits in packaging — do **not** claim “medical device” or “ballistic” certification without actual test reports.

---

## Armed forces adoption path (realistic)

### What RedMed is good for today

- **Individual service member / veteran** medical ID (allergies, anticoagulants, blood type, ICE contacts)
- **Training environments** where phones are allowed and medics carry smartphones
- **CONUS garrison** daily wear; **field exercises** where tap-to-phone still works
- **Trauma context messaging** on card (bundled trauma-center list — see [`docs/TRAUMA_FINDER.md`](../TRAUMA_FINDER.md))
- **Zero electronic signature** — passive tag only energizes during tap (OPSEC-friendly vs. beacons)

### What requires explicit scope / future work

| Gap | Notes |
|-----|-------|
| **NFMC / DD Form 1380 full replacement** | Today’s JSON schema is ICE-focused, not complete NATO medical record |
| **Unit procurement (NSN, GSA, ECAT)** | Needs legal entity, liability insurance, test reports, often 12–24 month sales cycle |
| **Medical device classification** | Avoid FDA “device” claims; position as **personal identification aid**, not diagnostic |
| **Encrypted NFC** | Contradicts stranger-tap requirement — do not add for this SKU |
| **Owner tap suppression on native iOS** | Universal Links gap — see [`SECURITY.md`](../../SECURITY.md); fix before marketing “paired phone ignore” to app users |

### Suggested pilot ladder

1. **Veteran & first-responder community** (already in PRD as nice-to-have discount tier)  
2. **NGO / disaster-response volunteers** (high NFC + smartphone penetration)  
3. **Unit morale / safety officer** bulk buy (10–50 bands, self-setup, no PHI at factory)  
4. **Military treatment facility** coordination cell — evaluate alongside paper NFMC  
5. **Formal procurement** only after IP68 + NFC QA reports and legal review

---

## Phased roadmap

### Phase 0 — Spec freeze & bench (Weeks 1–4)

- [ ] Freeze **Tactical Passive SKU** BOM: NTAG216 FPC + ferrite + LSR + clasp module  
- [ ] Order **5–10 bare NTAG216 tags** (Digi-Key) + **3 commercial silicone NFC samples** (NTAG216, IP68 claimed)  
- [ ] Verify chips with **NXP TagInfo** (counterfeit screening — see [`docs/plans/recovered/COMPANY-LAUNCH-PLAN.md`](recovered/COMPANY-LAUNCH-PLAN.md))  
- [ ] Write test profiles at **850-byte** URI limit from app  
- [ ] Document clasp ↔ antenna spacing rules for suppliers

**Budget:** ~$100–300 samples + shipping

### Phase 1 — Prototype bands (Weeks 5–12)

- [ ] Issue **RFQ** to 2–3 suppliers (see checklist below) for **10 custom units** with:
  - Magnetic clasp + pin-and-tuck or keeper loop  
  - NTAG216 FPC inlay, ferrite-backed  
  - OD green + coyote tan samples  
- [ ] RedMed app writes production-format URI to each band  
- [ ] Run **QA matrix** from [`docs/BRACELET.md`](../BRACELET.md) + environmental table above  
- [ ] Iterate **one** mechanical revision if read rate &lt;95% wet/flex

**Budget:** ~$500–2,000 (custom tooling often waived at 10–50 pc prototype tier)

### Phase 2 — Pilot cohort (Months 4–6)

- [ ] **50-band pilot** — veterans, outdoor athletes, ROTC / unit volunteers  
- [ ] Collect: first-tap success rate, clasp retention failures, skin reaction reports  
- [ ] Publish **field setup guide** (blank band + phone write — no PHI at factory)  
- [ ] Add **Tactical Band** insert copy to [`docs/PACKAGING.md`](../PACKAGING.md)

### Phase 3 — Production & military outreach (Months 6–12)

- [ ] MOQ production run (typical **500–1,000** silicone NFC MOQ from Asia vendors)  
- [ ] Third-party **IP68 test report** (if supplier lacks one)  
- [ ] Explore **Military OneSource / MWR / base exchange** consignment paths (owner ops)  
- [ ] Optional: **unit bulk SKU** `REDMED-BAND-TAC-216-BLANK` in [`docs/FULFILLMENT.md`](../FULFILLMENT.md)

### Phase 4 — Optional electronics fork (12+ months, out of scope for this plan)

The v2 smart band (LED, SOS button, Qi) in `docs/BRACELET.md` is **not** required for armed-forces MVP. Revisit only after passive SKU proves field NFC reliability.

---

## Supplier RFQ checklist

Send to NFC silicone wristband manufacturers (Alibaba, GoToTags custom, Proud Tek, GAOTek, CXJ RFID, etc.):

- [ ] **NTAG216** genuine NXP (provide TagInfo screenshot requirement)  
- [ ] **888-byte** NDEF URI pre-test or blank for customer write  
- [ ] **Custom FPC antenna** with **ferrite shield**, not coin tag glued in  
- [ ] **IP68** silicone band, **medical-grade** LSR  
- [ ] **Magnetic clasp + secondary retention** (pin-and-tuck or keeper — specify drawing)  
- [ ] **Magnet placement drawing** — min 50 mm from NFC pad  
- [ ] **Deboss + print** Star of Life / TAP PHONE / NFC icon  
- [ ] **Reflective strip** option  
- [ ] Optional **breakaway keeper** force rating  
- [ ] **No UID-only chips**  
- [ ] **No active/BLE/UHF** dual-frequency unless explicitly rejected  
- [ ] Sample **10 pc**, **2 colors**, lead time, MOQ, tooling cost  
- [ ] **Chemical compatibility** statement (DEET, chlorine, IPA)  
- [ ] Confirm they will **not** market as FDA medical device on your behalf

Search terms: `"NTAG216 silicone wristband IP68 magnetic clasp custom antenna"`.

---

## Software / ops dependencies (no hardware blockers)

These ship in software today or are documented gaps:

| Item | Status |
|------|--------|
| NDEF URI write (iOS CoreNFC + Web NFC) | Shipped |
| Emergency card + trauma hospitals on tap | Shipped |
| Owner paired-phone ignore (web) | Shipped |
| Owner paired-phone ignore (iOS native + HTTPS tag) | Gap — Universal Links |
| Blank-band fulfillment (no PHI at factory) | Documented in [`docs/FULFILLMENT.md`](../FULFILLMENT.md) |
| Canonical URL / GitHub Pages host | [`config/canonical-url`](../../config/canonical-url) |

No firmware or cloud work required for Tactical Passive SKU.

---

## Risks and mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Magnet detuning NFC | Tap fails in field | Ferrite + spacing + mandatory wet/flex QA |
| Clasp opens under load | Lost band = lost ID | Dual-security closure; breakaway only on keeper, not primary latch |
| Snag on kit / vehicle | Injury | Optional rated breakaway; document tradeoff vs. retention |
| Counterfeit NTAG chips | Write failures | TagInfo verify every batch |
| “Medical device” regulatory trap | Legal exposure | Personal ID positioning; no diagnostic claims |
| Smartphone-only responders | No phone = no read | Same as all NFC ID; print **ICE** on band exterior as backup cue |
| Profile too large for NTAG216 | Write fail | App byte counter; shorten URL via custom domain |
| Service member phone locked down | NFC URL may still open in browser | QA on DoD-managed devices if pilot expands |

---

## Success metrics (Tactical SKU)

1. **First-tap read success ≥95%** after environmental soak/flex (primary KPI from PRD)  
2. **Zero clasp openings** in standardized **5 km ruck / obstacle course** test (n=20 wearers)  
3. **Time tap → visible allergies/blood type ≤3 s** on mid-tier Android + iPhone  
4. **Pilot NPS / field feedback** from ≥30 service members or veterans  
5. **Return / defect rate &lt;2%** on first production MOQ  

---

## Recommended next actions

1. **Approve mechanical concept**: magnetic clasp + pin-and-tuck/keeper, NFC pad 180° opposite clasp, ferrite-backed NTAG216 FPC.  
2. **Order bench samples** this week (bare tags + one IP68 NTAG216 wristband from GoToTags or equivalent).  
3. **Issue RFQ** to two suppliers with the drawing and magnet-spacing rule.  
4. **Run `./scripts/verify-web.sh`** after any profile/schema change; keep [`docs/BRACELET.md`](../BRACELET.md) encoding SOP as factory source of truth.  
5. **Pilot with veterans first** — faster feedback loop than formal military procurement, aligns with PRD discount tier and builds test data for later unit sales.

---

## References (external research)

- NXP NTAG21x family — ISO 14443 Type A, NDEF, password protection ([Proud Tek NTAG21x guide](https://proudtek.com/guides/ntag21x-family-memory-map-commands/))  
- IP68 silicone NFC wristbands — commercial suppliers (RFID silicone, CardCube, GAOTek NTAG216 bands)  
- NFC + magnet interference — maintain ≥3–5 cm separation or ferrite shield ([TJ NFC TAG](https://www.tjnfctag.com/en_gb/nfc-and-magnets/))  
- Wearable NFC antenna + ferrite — 3–5 cm on-body target ([NFC Work wearable guide](https://nfcwork.com/nfc-antenna-design-for-wearable-form-factors/))  
- NATO NFMC + NFC evacuation tracking — academic prototype ([UVigo](https://calderon.cud.uvigo.es/items/ef0289a1-fdf1-404a-aff6-d1d3978eff14))  
- Magnetic sport band dual closure pattern — magnet + pin-and-tuck ([consumer sport band category](https://replenis.com/magnetic-silicone-sport-band-for-apple-watch-compatible-with-all-models/))  
- RedMed in-repo: [`docs/BRACELET.md`](../BRACELET.md), [`Product requirements.md`](../../Product%20requirements.md), [`SECURITY.md`](../../SECURITY.md)
