# Fulfillment & e-commerce

Operational guide for selling RedMed NFC bracelets. Software repo does not include a storefront — choose and configure separately.

## Recommended v1 model: blank bracelets

| Approach | Pros | Cons |
|----------|------|------|
| **Blank NTAG216 ship + owner writes** | No PHI in fulfillment; simpler compliance | Extra setup step for customer |
| Pre-encoded per order | Faster customer onboarding | Handle medical data at fulfillment; stronger consent |

**Recommendation:** start with **blank** bracelets + clear insert ([`docs/PACKAGING.md`](PACKAGING.md)).

## Platform options

| Platform | Fit |
|----------|-----|
| **Shopify** + Stripe | Full storefront, inventory, shipping labels |
| **Stripe Payment Links** | Minimal SKUs, manual fulfillment |
| **Square / Etsy** | Low volume, fast launch |

## SKU structure (example)

| SKU | Contents |
|-----|----------|
| `REDMED-BAND-BLANK-216` | Blank NTAG216 silicone band, setup insert |
| `REDMED-BAND-2PACK` | Two blank bands |
| `REDMED-APP-ONLY` | Digital — link to apps (no hardware) |

## Inventory

Track:

- Blank bands (by lot / supplier)
- Inserts printed
- Optional: pre-encoded units (separate secure storage if used)

## Fulfillment workflow (blank)

1. Pick blank band → visual QC
2. Pack band + insert + optional QR to apps
3. Ship — **no encoding at warehouse**
4. Support doc: "How to write your tag" → iOS Write Tag or NFC Tools

## Support playbook

| Issue | Response |
|-------|----------|
| Tag won't write | Confirm NTAG216; check URI byte count in app; try NFC Tools |
| Tap does nothing | Phone NFC enabled; try different tap position on band |
| Card won't load | HTTPS host must be live; check canonical URL |
| Profile too large | Shorten entries or use NTAG216; see capacity warning |

Contact: `help.RedMed@gmail.com` (from terms).

## Returns / RMA

- **Defective chip / no NDEF:** replace band
- **User error / wrong data:** customer rewrites tag (no PII retention needed if blank model)

## Metrics

- Write success rate (support tickets / units sold)
- Tap test pass rate from QA sample per batch ([`docs/BRACELET.md`](BRACELET.md))

## Related

- Hardware: [`docs/BRACELET.md`](BRACELET.md)
- Legal copy: [`docs/PACKAGING.md`](PACKAGING.md)
- Domain: [`docs/DOMAIN.md`](DOMAIN.md)
