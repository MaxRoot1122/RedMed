# RedMed — Product Requirements Document (MVP)

## 1. Problem Statement

**The problem:** Medical alert bracelets today mostly rely on QR codes to share a wearer's medical profile. QR codes fail exactly when they're needed most — in low light, in blood, in rain, or when the code is scratched or obscured. On top of that, most QR-code bracelets hide the code on the *inside* of the band, so a bystander has to remove it from an unconscious person's wrist and flip it over just to find something to scan. In an emergency, those extra seconds and failure points matter.

**How people solve this today:**
- Engraved dog tags / traditional medical ID bracelets (static, can't hold detailed info, easy to overlook)
- Apple Health "Medical ID" via the Health app or Apple Watch (locked to one ecosystem, requires the phone/watch to be present, unlocked, and known about by the responder)
- QR-code bracelets (fail in low light, blood, glare, or if the code degrades)

**Where these fail (the market gap):** every existing option adds friction right when there should be none. QR codes need a clean scan and good lighting. Apple Health needs a specific device and a responder who knows to look for it. None of them are built around the one truth of an emergency: someone else, often a total stranger, needs your critical info *instantly*, with zero setup and zero guesswork. That's the whole idea behind the company's tagline — **"Reducing human suffering"** — and it's the gap RedMed fills.

## 2. Solution

**One-line value proposition:** RedMed is a passive NFC medical ID band for people who need their critical health info accessible instantly, so a stranger can help before EMS arrives.

**Concise statement:** A rugged NFC bracelet for people with medical conditions, so any bystander can tap it and immediately see their profile, first-aid steps, and emergency contacts — no app, no login, no light needed.

## 3. Prioritized Features (MVP Focus)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| 1 | Passive NFC chip | No battery, no charging — taps and works forever, in any light | Must Have |
| 2 | Silicone band | Comfortable, waterproof, sweat-proof, everyday wearable | Must Have |
| 3 | Minimal, sporty design | Looks like a normal fitness/sport band, not a medical device — no stigma | Must Have |
| 4 | Rugged / durable build | Built for outdoorsmen, hunters, and everyday rough use | Must Have |
| 5 | Locally-stored medical profile | Name, conditions, allergies, medications, blood type — lives on the tag itself, not a server | Must Have |
| 6 | Basic first-aid instructions | Short, on-tap first-aid steps a bystander can follow immediately | Must Have |
| 7 | Emergency contacts | Contact info pulled up instantly alongside the medical profile | Must Have |
| 8 | One-tap 911 path | Tapped page makes calling 911 the obvious next action | Must Have |
| 9 | Discounts for veterans & first responders | Pricing perk for a core audience | Nice to Have |
| 10 | Bluetooth chip | Adds connectivity for future features (e.g. phone pairing) | Nice to Have |
| 11 | IFAK / med kit referral links | Affiliate links to trauma kits, with a kickback to RedMed | Nice to Have |
| 12 | Wireless charging + action button | "Apple Watch in a perfect world" — active electronics, not just passive NFC | Nice to Have |
| — | Authentication, database, cloud APIs | Any login system, central user database, or backend service | Not Prioritized (future) |

**MVP note on basics:** No authentication, no database, and no APIs are needed for the MVP — the whole point is that the profile lives locally on the NFC tag itself. That's what makes it fast and HIPAA-safe by default: there's no server to breach because there's no server.

## 4. Core User Journey

**Step-by-step flow:**
1. User fills out their medical profile once (name, conditions, allergies, medications, blood type, emergency contacts) on a simple web form.
2. That profile is written directly onto the NFC chip inside their silicone band — no account, no cloud upload.
3. User wears the band day to day, same as any fitness band.
4. If the user becomes incapacitated, a bystander (a "Good Samaritan") taps their phone to the band.
5. The bystander's phone instantly opens a simple page showing: the medical profile, basic first-aid steps relevant to the situation, and emergency contacts — with 911 as the clear first action.
6. No app install, no login, no signal required — it all works straight off the tag.

**Pages/screens (keep content as already built in the repo — don't add complexity):**
- **Setup form** — where the user enters their profile before writing it to the band.
- **Tapped/emergency view** — the page a bystander sees: profile, first-aid basics, emergency contacts, call-911 prompt. This is the only screen that matters in the moment, so it stays the simplest and fastest-loading of all of them.

## 5. Out of Scope / Limitations

**What the MVP will NOT do:**
- No native login system, user accounts, or cloud database
- No Bluetooth, wireless charging, or physical action button (all "nice to have," not MVP)
- No real-time health monitoring or biometric sensors
- No in-app messaging, social features, or community features
- No automated 911 dialing (the bystander still has to place the call — the app just makes it the obvious next step)

**Manual workarounds:**
- Updating a profile means re-writing the NFC tag (via the setup form + a phone with NFC write support) — no remote/cloud sync in the MVP.
- If a bystander's phone doesn't support NFC, they'd need another NFC-capable phone nearby, since there's no QR-code fallback in the MVP.

## 6. Success Metrics

1. **Bands sold / activated** — the clearest signal of real-world adoption.
2. **Tap-to-load success rate** — percentage of NFC taps that successfully open the emergency page on the first try (proves the core promise: it works every time, unlike QR).
3. **Time from tap to visible emergency info** — how many seconds from tap to a bystander seeing the profile; the whole product exists to make this number as close to zero as possible.
