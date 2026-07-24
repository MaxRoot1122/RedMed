# Threat model

Local-first emergency medical ID on a **passive NTAG** (ISO 14443). Profile data
lives on-device and on the chip as an HTTPS URI + `#d=` payload. No RedMed
server receives medical profiles.

## Assets

| Asset | Where | Sensitivity |
|-------|--------|-------------|
| Medical profile | Web `localStorage`, iOS Keychain, NFC `#d=` | High (PHI) |
| Hosted card JS/HTML | GitHub Pages from `main` | Critical integrity |
| Optional Google Maps key | Public `config/google-api-key` on Pages | Billing / abuse |
| Bracelet PIN digest | Web `localStorage` only | Low (UX lock, not NFC ACL) |

## Actors

- **Responder / bystander** — taps band; must read the card without an account.
- **Owner** — edits profile, writes tag, optional local PIN.
- **Attacker with physical tag access** — can read/clone/overwrite NDEF (accepted).
- **Attacker with crafted `#d=` URL** — can present a fake card or try XSS / DoS.
- **Supply-chain / repo attacker** — malicious Pages deploy reaches all bracelets.

## In scope threats

1. Compromised `main` or Pages workflow → malicious JS on every tap.
2. XSS from hostile `#d=` / NFC URI rendered in the browser.
3. Oversized `#d=` deep-link DoS before schema caps run.
4. Abuse of a publicly deployed Maps API key (quota / billing).
5. Fake medical cards and social-engineering / phishing store apps.
6. Incomplete Android App Links (placeholder Asset Links fingerprints).

## Out of scope / accepted risks

| Risk | Why accepted |
|------|----------------|
| Anyone who taps can read the medical card | Emergency access by design |
| NFC cloning / rewrite of unlocked tags | Same class as a paper medical ID |
| No accounts / no remote wipe | Local-only HIPAA-adjacent posture |
| UA “smartphone gate” bypass (`?preview=1`) | UX friction, not access control |
| PIN does not hide NFC data | PIN is owner-device SOS/unlock only |

## Explicit non-goals

Do **not** add: operator backends, OAuth/JWT, encrypting NFC so responders need a
password, BLE/active RFID, analytics that phone home PHI, or fake satellite
pointing UIs.

## Mitigations in product

- CSP on `index.html` and `get.html` (hash-pinned script; `object-src 'none'`;
  Maps `connect-src` exception for Find 911 only).
- `#d=` pre-parse size gate + schema coercion / length caps before render.
- Contact `tel:` links built via DOM APIs + `normalizePhone` (not string `innerHTML` hrefs).
- Emergency card `document.title` is generic (`RedMed — Emergency`) — no patient name.
- PIN stored with PBKDF2 (Web Crypto) + attempt lockout; set fails closed without SubtleCrypto.
- When PIN-locked, NFC write and disconnect require unlock (NFC chip data stays readable).
- iOS profile + bracelet URL in Keychain (`WhenUnlockedThisDeviceOnly`); decode path size-capped.
- Android `allowBackup="false"` on the TWA wrapper.
- Pages Actions pinned to commit SHAs.

## Residual owner actions

1. Branch protection on `main` (GitHub settings — not in-repo).
2. Paste real Play signing SHA-256 into `.well-known/assetlinks.json` before
   relying on full-screen TWA verification ([`docs/ANDROID_PLAY.md`](ANDROID_PLAY.md)).
3. Restrict Maps keys in Google Cloud Console before setting
   `GOOGLE_MAPS_API_KEY` ([`SECURITY.md`](../SECURITY.md)).
4. If you add a custom domain later, confirm it serves this app + AASA before
   flipping [`config/canonical-url`](../config/canonical-url) — see
   [`docs/DOMAIN.md`](DOMAIN.md). Do not use `redmed.app` (unrelated third-party).
