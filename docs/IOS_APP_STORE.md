# iOS App Store submission checklist

Operational steps — requires your Apple Developer account and a Mac with Xcode. Cannot be completed in CI.

## Prerequisites

- [ ] [Apple Developer Program](https://developer.apple.com/programs) enrolled ($99/yr)
- [ ] Physical iPhone (NFC does not work in Simulator)
- [ ] NTAG215/216 test tags
- [ ] Privacy policy live: `https://www.redmed.com/privacy-policy.html`

## Build on device

1. Open [`ios/RedMed.xcodeproj`](../ios/RedMed.xcodeproj)
2. **Signing & Capabilities** → select your **Team** (replace empty `DEVELOPMENT_TEAM` in project)
3. Run on iPhone (⌘R) → trust developer cert on device if needed
4. `./scripts/build-ios.sh` — optional compile-check without signing

## NFC test matrix (physical)

- [ ] **Write Tag** → tap tag on second phone → **browser** opens card (HTTPS URL)
- [ ] **Read tag** imports profile into Keychain
- [ ] Legacy `redmed://` marketing link still opens in-app scanned view
- [ ] Find 911: GPS, compass, copy coordinates, trauma hospitals (transport; state → county only when 30+)
- [ ] Aid topics + CPR timer offline
- [ ] First-launch consent appears once ([`UseConsentView`](../ios/RedMed/Views/UseConsentView.swift))
- [ ] My ID form includes doctor name/phone and insurance provider/member ID (parity with web)

## Archive & upload

1. Select **Any iOS Device** → **Product → Archive**
2. **Distribute App → App Store Connect → Upload**
3. Wait for processing in App Store Connect

## App Store Connect metadata

| Field | Guidance |
|-------|----------|
| Bundle ID | `local.redmed.app` |
| Category | Medical (expect scrutiny) |
| Privacy Policy URL | Hosted `privacy-policy.html` |
| Screenshots | 6.7" and 6.1" iPhone minimum — see [`docs/STORE_ASSETS.md`](STORE_ASSETS.md) |
| App Privacy | On-device medical fields; precise location for Find 911 only while screen open; not linked to identity; not sent to developer servers |
| Review notes | Explain NFC writes unencrypted medical data to user's own tag by design; Find 911 does not auto-dial |

### Suggested review note

> RedMed is a local-first medical ID. Users write their own profile to NFC tags they own. Tag data is intentionally unencrypted so a smartphone can read the emergency card in a browser without installing the app — not card readers or other NFC devices. Find 911 shows GPS on screen only; the app never auto-dials 911. First aid content is general public guidance, not medical advice.

## TestFlight

- [ ] Internal testing with 5–10 users
- [ ] Verify NFC write/read on real bracelets
- [ ] External beta optional before public release

## Post-launch

- Monitor App Review messages for privacy/NFC questions
- When custom domain goes live, update privacy URL in App Store Connect

See also [`ios/SETUP.md`](../ios/SETUP.md).
