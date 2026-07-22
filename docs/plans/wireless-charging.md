# Plan note: Wireless charging research

**Branch:** `cursor/bracelet-battery-bar-a8f0`  
**Canonical doc:** [`docs/WIRELESS_CHARGING.md`](../WIRELESS_CHARGING.md)  
**Agent catalog:** [`docs/AGENT_PROMPTS.md`](../AGENT_PROMPTS.md) §4  
**Related plan:** [`manufacturing-bom.md`](manufacturing-bom.md)

## Status

Research continued: **passive NTAG216 does not need wireless charging.**

- Tap power (ISO 14443) ≠ NFC Forum WLC ≠ Qi.
- WLC/Qi only matter for a future battery-powered Path B band.
- Keep v1 messaging: no battery, no charging.

## Open (hardware, not this repo)

- Path B OEM RFQ if/when LED+SOS band is greenlit.
- No further software required for Path A charging (there is nothing to charge).
