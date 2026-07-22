# Plan note: Wireless charging research

**Branch:** `cursor/wireless-charging-guidance-a8f0`  
**Base:** RedMed 2 project snapshot on `main`  
**Canonical doc:** [`docs/WIRELESS_CHARGING.md`](../WIRELESS_CHARGING.md)  
**Agent catalog:** [`docs/AGENT_PROMPTS.md`](../AGENT_PROMPTS.md) §4  
**Related plan:** [`manufacturing-bom.md`](manufacturing-bom.md)

## Status

Updated from current repo files. **Passive NTAG216 does not need wireless charging.**

- Tap power (ISO 14443) ≠ NFC Forum WLC ≠ Qi.
- WLC/Qi only matter for a future battery-powered Path B band.
- Keep v1 messaging: no battery, no charging.
- Manufacturing chip map lives in the agent plans folder: `manufacturing-bom.md`.

## Open (hardware, not this repo)

- Path B OEM RFQ if/when LED+SOS band is greenlit.
- No further software required for Path A charging (there is nothing to charge).
