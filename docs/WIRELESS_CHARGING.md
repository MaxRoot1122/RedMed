# Wireless charging guidance for RedMed

This document explains when wireless charging applies to RedMed and what to do next for each product path.

## Path A (current launch): passive bracelet

RedMed's current NTAG216 bracelet is passive NFC with no battery. It does not need charging.

- Keep shipping blank NTAG216 bracelets per [docs/BRACELET.md](BRACELET.md).
- Keep responder UX as tap-to-browser with no app required.
- Use simple customer-facing wording: "No battery. No charging required."

## Path B (future): powered bracelet

Wireless charging only applies if RedMed introduces a battery-powered band.

### Definition of done before prototyping

1. Pick one powered feature that justifies a battery (for example: LED alert, BLE auto-sync, or find-my-band).
2. Keep dead-battery emergency access in the spec (passive NFC fallback still readable by any phone).
3. Choose charging approach:
   - NFC Wireless Charging (WLC) for smaller form factors and lower power.
   - Qi/Qi2 only if higher power and thicker hardware are acceptable.

### OEM RFQ checklist

Request answers from 2-3 qualified suppliers:

- NFC architecture (single-chip dynamic NFC vs dual-chip with dedicated NTAG216 fallback).
- Charging architecture (NFC WLC receiver IC or Qi receiver, charge current, expected charge times).
- Battery details (chemistry, capacity, cycle life, safety certifications).
- Mechanical constraints (band thickness, enclosure sealing, target ingress rating).
- Read performance through silicone and in wet conditions.
- Compliance path (FCC/CE, battery transport UN38.3, regional safety requirements).
- Manufacturing QA flow (tap-read verification, charge verification, lot traceability).

### Prototype validation checklist

Before committing to tooling:

- Verify passive tap still opens the emergency card when the battery is depleted.
- Measure charge time and thermals in real wearable conditions.
- Verify NFC read reliability across wrist sizes and orientations.
- Confirm durability targets after soak/flex testing.
- Review legal copy to preserve "not a medical device" positioning.

## Notes on standards

- NFC Wireless Charging (NFC Forum WLC 2.0) is suited to low-power small accessories and currently supports up to 1 W.
- Qi/Qi2 is better for higher-power devices but typically needs larger coils and thicker enclosures.
- For RedMed's core emergency use case, passive readability should remain the non-negotiable requirement.
