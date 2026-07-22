# RedMed group — agent prompts (opened in-repo)

Cursor cloud agents **cannot always read each other’s transcripts** across runs (environment / visibility scope). This file keeps RedMed group prompts and plans **inside the sole repo** so any agent on `MaxRoot1122/RedMed` can continue the work without needing the original `bc-…` session.

**Rule:** one GitHub repo (`RedMed`). One branch (or worktree) per agent task. Merge finished work to `main`. Do **not** create a second repo per agent.

---

## Today’s RedMed group (from Cursor Agents UI)

| UI name | Status | Agent id | Branch / PR | Prompt / plan |
|---------|--------|----------|-------------|---------------|
| Bracelet emergency system | Merged | `bc-019f83d5-cb63-7a1b-b405-4f700d444560` | `cursor/bracelet-sos-pin-4560` → [#28](https://github.com/MaxRoot1122/RedMed/pull/28) | [§ Bracelet emergency / SOS + PIN](#1-bracelet-emergency-system) |
| NFC bracelet project needs | Unable To Complete | `bc-e86e8012-c2bf-4d8c-b2b0-d965e5f8506a` (best match) | `*-506a` stack; commercial launch [#16](https://github.com/MaxRoot1122/RedMed/pull/16) | [§ NFC bracelet project needs](#2-nfc-bracelet-project-needs) |
| Final codebase integration | Merged | `bc-019f83cc-ba7c-7abf-88a1-d21f5c664af8` | `cursor/final-integration-4af8` → [#25](https://github.com/MaxRoot1122/RedMed/pull/25) | [§ Final codebase integration](#3-final-codebase-integration) |
| Wireless charging research | Active — updated from RedMed 2 snapshot | `bc-019f83d7-b36f-7eac-86f0-604c0164a8f0` | `cursor/wireless-charging-guidance-a8f0` | [§ Wireless charging research](#4-wireless-charging-research) |
| Development environment setup | Merged | `bc-b3048808-2d8b-4ce4-9fe5-9a487c02ecc0` | `cursor/setup-dev-environment-ecc0` → [#21](https://github.com/MaxRoot1122/RedMed/pull/21) (+ many `*-ecc0` PRs) | [§ Development environment setup](#5-development-environment-setup) |

**Access note:** those historical `bc-…` ids are often **not fetchable** from a later cloud run (`batch-fetch-details` → not found / not accessible). Use this doc + `docs/plans/` instead of relying on cross-agent transcript APIs.

Executable plan copies (for re-runs that look for an “attached plan”):

- [`docs/plans/bracelet-sos-pin.md`](plans/bracelet-sos-pin.md)
- [`docs/plans/nfc-bracelet-commercial-launch.md`](plans/nfc-bracelet-commercial-launch.md)
- [`docs/plans/wireless-charging.md`](plans/wireless-charging.md)
- [`docs/plans/manufacturing-bom.md`](plans/manufacturing-bom.md)
- [`docs/plans/final-integration.md`](plans/final-integration.md)
- [`docs/plans/dev-environment.md`](plans/dev-environment.md)

Historical research recovered from git (deleted from product docs on purpose — keep under `plans/recovered/` only):

- [`docs/plans/recovered/COMPANY-LAUNCH-PLAN.md`](plans/recovered/COMPANY-LAUNCH-PLAN.md) — 2026-07-19 company launch sequencing
- [`docs/plans/recovered/PHYSICAL-DEVICE.md`](plans/recovered/PHYSICAL-DEVICE.md) — early MedTag ICE / visor + wristband hardware design (pre–bracelet-v2)

**Cursor tip backups:** alternate tip trees from every `cursor/*` branch live under [`cursor-backup/`](../cursor-backup/README.md). Product source of truth is still repo root / `main` — those copies are archival only (used when consolidating branches without overriding live files).

---

## 1. Bracelet emergency system

**Recovered task (from PR #28 / agent name “Bracelet hardware spec SOS PIN”):**

Implement bracelet v2 industrial design + app SOS / PIN / device management:

1. **Hardware spec** in `docs/BRACELET.md` — silicone wrap-around, LED ledger-style screen, single glossy side button (Apple Watch reference), sizes 38/40/41mm, Qi wireless charging note, IP67; document SOS (30s countdown → auto-dial contacts 1 & 2, skip doctor) and PIN semantics.
2. **SOS countdown** in `index.html` — My ID header SOS → full-screen 30s overlay; cancel; on expiry `tel:` contacts 1 & 2; alert if no contacts.
3. **PIN lock/unlock** — 4-digit keypad; hash in `localStorage`; locked SOS cancel requires PIN.
4. **Disconnect / reconnect** in bracelet sheet; header + catalog status.
5. **My devices / Add product** sheet — RedMed Band + “Coming soon” slot.
6. Housekeeping — CSP `sha256-` recompute; sync `RedMed.app` www mirror; EN/ES i18n.

**Status on `main`:** merged via #28.

---

## 2. NFC bracelet project needs

**UI showed “Unable To Complete Request.”** Work under the same agent family (`…506a`) that *did* land includes commercial launch, passive-NFC-only, smartphone-only gate, trauma lookup.

**Recovered commercial-launch task (from commit `a68e104` / PR #16):**

> Implement NFC bracelet commercial launch plan:
>
> - Align iOS NFC writes with universal HTTPS tags; full-URI capacity checks
> - Add doctor/insurance fields on web and iOS; iOS first-launch consent
> - Centralize canonical URL config with sync script and custom domain docs
> - Deploy `.well-known/assetlinks.json` via GitHub Pages; add `CNAME`
> - Commercial docs: bracelet SOP, stores, packaging, fulfillment
> - Play listing copy, feature graphic template, proprietary LICENSE
> - Bundle legal pages in macOS wrapper; update terms for physical products

**Also under this agent family:**

- Passive NFC only (PR #27) — NTAG / ISO 14443 only; no BLE/active RFID/battery bands
- Smartphone-only emergency card gate (no dedicated card readers)
- Trauma center finder on Find 911 + NFC card (see `docs/TRAUMA_FINDER.md`)

**Recovered earlier research (git history, deleted from live docs):**

- [`plans/recovered/COMPANY-LAUNCH-PLAN.md`](plans/recovered/COMPANY-LAUNCH-PLAN.md) — LLC / EIN / samples / insurance sequencing (Pages + no-backend rules now supersede parts of this)
- [`plans/recovered/PHYSICAL-DEVICE.md`](plans/recovered/PHYSICAL-DEVICE.md) — early visor-clip + wristband ICE Core design; bracelet-v2 in `docs/BRACELET.md` is the current SKU

**If a re-run says “Unable To Complete”:** open [`docs/plans/nfc-bracelet-commercial-launch.md`](plans/nfc-bracelet-commercial-launch.md), verify against `main`, and only implement **remaining** owner action items (domain, store IDs, samples) — do not re-merge already-landed code.

---

## 3. Final codebase integration

**Recovered task (from PR #25):**

> Consolidate all outstanding draft PRs into a single trunk-ready revision on `main`.
>
> Include: Cloud `verify-web.sh` + `initLang` boot fix; emergency SMS from Find 911; bracelet live link; modern UI; RedMed nav label; trauma hospitals; commercial launch docs/assets.
>
> Supersede / close superseded drafts; resolve conflicts against current `main` (keep 3-contact accordion, local-only privacy, condition chips).
>
> Verify with `./scripts/verify-web.sh` and Swift brace/paren balance.

**Status on `main`:** merged via #25.

---

## 4. Wireless charging research

**Recovered task (from PR #26 + `docs/WIRELESS_CHARGING.md`):**

> Research and document wireless charging for RedMed bracelets without confusing the **current passive NTAG** product:
>
> - Path A: passive bracelet — no battery, no charging
> - Path B: future powered band only if a battery-justified feature exists; OEM RFQ + prototype checklist
> - Emergency tap must still work if a future battery is dead
> - Ship product-facing docs (`docs/WIRELESS_CHARGING.md`, README, packaging copy) — docs-only unless product direction changes

**Updated from RedMed 2 snapshot files (this branch):**

> Rebase research onto current `main` snapshot. Confirm passive NFC does **not** need WLC/Qi. Keep:
>
> - [`docs/WIRELESS_CHARGING.md`](WIRELESS_CHARGING.md) — expanded verdict + learning log
> - [`docs/plans/manufacturing-bom.md`](plans/manufacturing-bom.md) — vertical-integration chip/BOM map
> - [`docs/BRACELET.md`](BRACELET.md) — LED battery local-only, side-button SOS siren, phone must not continuous-scan, no MAC blacklist
> - [`docs/plans/wireless-charging.md`](plans/wireless-charging.md) — executable plan note

**Status:** Active on `cursor/wireless-charging-guidance-a8f0` (rebased onto RedMed 2 `main`).

---

## 5. Development environment setup

**Recovered task (from PRs #5 / #21 + `AGENTS.md`):**

> Set up Cursor Cloud for RedMed:
>
> - No installable deps; update script = `true`
> - Document run/verify in `AGENTS.md`
> - Add `scripts/verify-web.sh` (CSP hash, `node --check`, www mirror, HTTP smoke on `:8934`)
> - Fix `initLang()` boot order (must run after highlight helpers exist)
> - Serve locally: `python3 -m http.server 8934 --bind 127.0.0.1`

Same long-lived agent (`…ecc0`) also shipped many feature PRs (#8–#20, #12–#15, etc.). Prefer task branches over one shared long-lived agent branch when working alone with multiple AIs.

**Status on `main`:** setup merged; feature stack largely integrated.

---

## Verbatim prompts recoverable from a live sibling agent

From **Shared branch workflow** (`bc-019f8422-9f72-7f87-bcae-065131cabe8d`) — user messages present in transcript:

1. > I want to be shown how to make a repo for every single agent and putting them into one project. Using git and Claude with them and having a final finished project I can merge onto my main
2. > I’m only one working / I’m also using ai of course
3. > So one main branch is safe if I have a backup on my end?

**Answer already in product rules:** stay on **one** repo; use **one branch per agent task**; `main` = finished only; backups help recovery, not concurrent-edit safety.

---

## Sibling re-runs (same environment, 2026-07-21)

These agents were launched looking for “attached plans” that never landed in the workspace. Conclusions:

| Agent | bcId | Outcome |
|-------|------|---------|
| Bracelet hardware spec SOS PIN | `bc-019f8423-1a18-71db-ae6e-d6ee9eb40fbc` | Already on `main` via #28 — verify only |
| NFC bracelet commercial launch | `bc-019f8423-aa75-7b7e-971d-605505cdcfc5` | In-repo launch merged; leftovers = owner ops (store IDs, domain, samples) |
| Redmed wireless charging plan | `bc-019f8424-084c-791f-950c-1d0017c54544` | Guidance already on `main` via #26 |
| Shared branch workflow | `bc-019f8422-9f72-7f87-bcae-065131cabe8d` | Advice-only — one repo, task branches, Cloud → draft PR → `main` |

This file + `docs/plans/*.md` are the durable substitutes for those missing attachments.

---

## What’s left that needs a human (not another agent transcript)

Placeholder store IDs still in repo (intentional until listings exist):

- `get.html` / `AppConfig.appStoreURL` → `id0000000000`
- Huawei AppGallery → `C000000000`

Owner checklist (from commercial launch plan): domain + DNS, real store IDs, NTAG216 samples + QA, screenshots, storefront. See `docs/plans/nfc-bracelet-commercial-launch.md`.

---

## How to add a new prompt so the next agent can find it

1. Paste the prompt under a new `##` section here (exact user text).
2. Optionally add `docs/plans/<slug>.md` with the implementation plan + todos.
3. Commit on a `cursor/<slug>-…` branch and merge after review.
4. Tell the next agent: “Follow `docs/AGENT_PROMPTS.md` § … / `docs/plans/….md`.”

Do **not** depend on another agent’s `bc-…` transcript remaining API-accessible.
