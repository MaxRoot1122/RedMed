# Plan: Wireless charging research → product guidance

**Source agent:** `bc-019f83d7-b36f-7eac-86f0-604c0164a8f0`  
**Branch:** `cursor/wireless-charging-guidance-a8f0`  
**PR:** https://github.com/MaxRoot1122/RedMed/pull/26  
**Status:** Docs merged into `main` (`docs/WIRELESS_CHARGING.md`).

## Goal

Translate wireless charging research into clear product docs without implying today’s passive bracelet needs charging.

## Todos

- [x] `docs/WIRELESS_CHARGING.md` — Path A passive (no charge); Path B future powered band + OEM RFQ / prototype checklist
- [x] Preserve emergency tap if a future battery is dead
- [x] README + packaging wording: no battery / no charging on current SKU
- [x] Docs-only — no NFC/runtime behavior change unless product direction changes

## Constraints

- Current bracelet = passive NTAG — phone powers chip on tap.
- Do not add fake battery UI or BLE beacons.
