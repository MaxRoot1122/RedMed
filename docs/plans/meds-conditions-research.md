# Medicines & conditions catalog research

**Agent / branch:** Research (`cursor/wireless-charging-guidance-a8f0`)  
**Surface:** My ID chip search in `index.html` (`COMMON_*` / `RARE_*` + quick browse seeds)

## Goal

Expand offline search catalogs so owners can find **common** and **rare** medicines and conditions without a network call. Lists are for chip UX / emergency-card clarity — not prescribing advice.

## Sources (orientation)

| Layer | Basis |
|-------|--------|
| Common meds | ClinCalc DrugStats Top ~200–300 U.S. prescriptions (2023) + high-use OTC / devices / HIV / MS / psoriasis biologics that show up often on IDs |
| Rare meds | Orphan / specialty products with emergency relevance (HAE rescue, factor / Hemlibra, CFTR modulators, ERT, complement inhibitors, PAH prostacyclins, CAR-T / bispecifics, glucagon rescue, IVIG, etc.) |
| Common conditions | High-prevalence chronic disease + devices / directives first responders need (diabetes, anticoagulation, seizures, dialysis, DNR/POLST, anaphylaxis history) |
| Rare conditions | NORD-style rare disease flags + MedicAlert-style emergency unknowns (MH susceptibility, Fontan, porphyria, urea-cycle, SMA, MPS, HHT/AVM, channelopathies, etc.) |

## Catalog mechanics (do not break)

- `dedupeCatalog` — case-insensitive unique strings  
- `catalogMinus(RARE_*_RAW, COMMON_*)` — rare browse/search never duplicates common  
- `browseCommonFrom(catalog, seed, max)` — curated seeds first; seed strings must **exactly** match catalog entries  
- Search UX: `wireChipSearch` with `browseCommon` + `browseRare` (meds use `QUICK_RARE_MEDS`)

## Approximate sizes (this revision)

| Catalog | ~count |
|---------|--------|
| `COMMON_MEDS` | ~330 |
| `RARE_MEDS` (after minus) | ~250 |
| `COMMON_CONDITIONS` | ~286 |
| `RARE_CONDITIONS` (after minus) | ~440 |

Free-text Enter still adds custom names; catalogs only seed search.

## Verification

```bash
./scripts/sync-www-mirror.sh
./scripts/verify-web.sh
```

Any edit inside the inline `<script>` requires CSP `sha256-` recompute.

## Out of scope

- Network drug databases / RxNorm live lookup  
- Dosing recommendations or drug–drug interaction engines  
- iOS duplicate catalogs (web is source for this pass; native can mirror later if asked)
