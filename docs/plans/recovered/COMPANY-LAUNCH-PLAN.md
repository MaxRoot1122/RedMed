# RedMed — Company Launch: Research & Plan

Prepared 2026-07-19 for work starting 2026-07-20. Nothing below has been actioned — this is research and sequencing so tomorrow starts with a plan, not a blank page.

---

## Do these in order — everything else is blocked on #1

1. **Push today's code to GitHub, enable Pages.** Nothing physical or commercial matters until the card actually loads at a real URL. Five minutes of your time, blocks literally everything downstream (real NFC tags, samples, testing, even the "does tap-to-scan work" question).
2. **Verify the hosted URL loads, then test a real tap-to-scan** on a second phone, screen locked, before trusting any of this with real data.
3. **File the LLC** (same-day online in most states) — do this before you take a single sale, not after.
4. **Get the EIN** (free, IRS.gov, ~10 minutes, instant).
5. **Order NFC wristband samples** — free-to-cheap, no commitment, can happen in parallel with 3–4.
6. **Get a liability insurance quote** once the LLC exists — needed before real sales, not before.
7. **Trademark filing** — deliberately last. Explained below.

---

## 1. GitHub Pages (recap — you already know this one)

`maxroot1122.github.io/med/index.html` still doesn't resolve as of last check tonight. Repo Settings → Pages → Deploy from a branch → `main` → `/ (root)` → Save. Your local `medappp` folder has all of today's fixes (cloud sync, CSP hardening, satellite hint, iOS wiring) — none of it is on GitHub yet because the push needs to happen from your own Terminal (see the exact commands from earlier tonight: `rm -f .git/index.lock && git add -A && git commit -m "..." && git push`).

---

## 2. Business formation

**LLC — recommend your home state, not Delaware**, unless you have a specific reason (outside investors, multi-state operations from day one). Delaware's advantages mainly matter once you're raising money or operating across many states — for a single-owner product business, home-state formation is cheaper and simpler, and you avoid Delaware's annual franchise tax (rising to $400/year starting Aug 2026) on top of whatever your home state charges.

Rough numbers: state filing fees run $50–$300 depending on the state (Delaware $90 base, California $70, Texas $300 — check your specific state). Processing is typically 2–7 business days, faster with an expedited-filing fee. Budget under $500 all-in for formation regardless of state.

**EIN**: free, directly from IRS.gov, takes about 10 minutes, issued instantly online. Needed to open a business bank account and required before payroll or 1099 contractors — get it same day as the LLC.

**Why before your first sale, not after**: this product touches health information and gives first-aid guidance. An LLC puts that liability on the company, not you personally. Skipping this step to move faster is the one shortcut with real personal downside.

## 3. Liability insurance

Get a quote once the LLC exists — a Business Owner's Policy (BOP) bundling general liability + product liability typically runs **$57–150/month** for a small hardware startup, sometimes less pre-revenue. Most contracts (retailers, distributors, even some payment processors) require a **$1M liability limit** as a baseline, so ask for that when quoting. Vouch, Insureon, and NEXT Insurance all do fast online quotes for exactly this profile (small consumer hardware, pre-revenue or early revenue).

Not urgent for tomorrow specifically — get the LLC first, then insurance before your first real sale, not before you've validated the product with samples.

## 4. Trademark — deliberately last, here's why

USPTO filing costs **$350–550 per class** of goods, and the full registration process takes **12–18 months** even with no issues. Over 40% of DIY applications get an Office Action (a rejection/clarification request) that's harder to resolve without a trademark attorney.

You don't need a registered trademark to operate, sell, or even build a brand — common-law trademark rights exist the moment you're using a name in commerce, they're just weaker than a federal registration. The practical move: do a **free knockout search** (USPTO's TESS database, plus a plain Google/Amazon search) before you fall in love with a name, to avoid a costly rebrand later — but hold off on the $350+ filing fee until the name and product have survived actual market contact. Filing early on a name that changes after customer feedback is money and 12 months wasted.

## 5. Manufacturing — NFC wristband sourcing

Refined pricing from tonight's research, since the earlier numbers were rougher:

| Tier | Source | Price | Notes |
|---|---|---|---|
| **Samples** | Shop NFC | €2.49/unit, 3-unit minimum | NTAG216, silicone, fastest way to get real hardware in hand |
| **Samples** | RFIDFS | No stated MOQ | Small batches cost more per unit but no commitment |
| **Small batch** | Shop NFC | as low as €0.89–1.95/unit at 1000 units | Depends on style (basic vs colored/printed) |
| **Bulk** | TJ RFID Supplies | 1000-unit MOQ, 10–12 day lead time | Your scale-up vendor once samples are validated |
| **Bulk (cheapest)** | Alibaba listings | 1000-unit MOQ typical | Widest price range, most counterfeit-chip risk — verify everything |

Stock samples typically ship in **1–5 days**; sub-10K custom orders in **7–15 days**; full bulk orders around **30 days**. Order samples this week — it's cheap and doesn't block anything else.

**Non-negotiable before any bulk order**: verify every sample's actual chip with NFC Tools' chip-info read (confirms real NTAG216 vs. mislabeled/counterfeit silicon), test write/lock/rewrite, and run a drop/wash cycle on the silicone. This market has real counterfeit-chip risk at the cheap end.

**Ship blank, not pre-encoded** — cheaper per unit, and it matches the product's whole design principle (user controls their own data, writes it via NFC Tools + your hosted page).

## 6. Regulatory reality check (unchanged from earlier — restated for completeness)

Not an FDA-regulated medical device — same category as MedicAlert/Road ID, which have operated for decades without clearance, because the product doesn't diagnose or treat anything, it's a data carrier a human reads. Once the company is collecting real customer health data through Supabase (not just your own personal use), state-level health-data privacy laws likely apply (Washington's My Health My Data Act and similar), plus CCPA if you have California customers — regardless of HIPAA not applying. Worth 30 minutes with an actual lawyer before your first real sale, not before tomorrow.

---

## Dependency graph — what actually blocks what

```
GitHub Pages live
   └─→ real NFC tag can be written and tested
          └─→ confirms the whole product works end-to-end

LLC filed → EIN issued
   └─→ business bank account
   └─→ liability insurance quote becomes real (not just budgeting)
          └─→ safe to take real sales

NFC samples ordered (parallel, no dependency on the above)
   └─→ chip verified, hardware validated
          └─→ bulk order only after this passes

Trademark: intentionally decoupled — do the free knockout search anytime,
file the paid application only after the name has survived contact with
actual customers.
```

Nothing here commits money beyond LLC filing fees (~$100–300) and a few dollars for wristband samples. Everything expensive (bulk manufacturing, insurance, trademark filing) waits for validation first.
