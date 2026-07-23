# RedMed — iOS app

Local-first medical ID for your iPhone: edit your profile, write it to an NFC tag, read tags back, offline first-aid guide, and Find 911 with GPS. Everything stays on-device — no accounts, no server.

**Double-click to open:** `ios/RedMed.xcodeproj`

| Setting | Value |
|--------|--------|
| Bundle ID | `local.redmed.app` |
| URL scheme | Legacy `redmed://` still registered; **new tags write HTTPS** so smartphones can open the card (not card readers) |
| Deployment | iOS 16+ · iPhone only |
| NFC | Read + write NDEF tags (NTAG213+) — profile rides in the URL `#d=` on the chip |

---

## Install on your iPhone (3 steps)

1. **Open** `ios/RedMed.xcodeproj` in Xcode (double-click in Finder).
2. **Plug in your iPhone** → select it in the toolbar → **RedMed** target → **Signing & Capabilities** → choose your **Team** (Xcode → Settings → Accounts to add your Apple ID).
3. **Run** (⌘R). First launch: on the iPhone go to **Settings → General → VPN & Device Management** → trust your developer certificate.

NFC does **not** work in Simulator — use a physical iPhone.

---

## Tabs

| Tab | What it does |
|-----|----------------|
| **My ID** | Read-only summary by default; top-right **Edit** opens the form. Edit name, blood type, allergies, meds, conditions, 3 emergency contacts (PCP + 2), notes. Saves to Keychain on this device. Once a bracelet is linked (see `BiometricGate.swift`), Edit requires Face ID / Touch ID (device-passcode fallback) — open before that so initial setup isn't blocked. |
| **Find 911** | Call 911, live GPS coordinates, compass heading, copy dispatch summary, trauma hospitals by state for transport when waiting may not be survivable (county picker only when 30+ in that state; offline bundled list). When offline, factual guidance for native Emergency SOS via satellite (OS-level — RedMed cannot initiate it). |
| **Aid** | Offline first-aid topics + CPR compression timer. |
| **Write Tag** | Writes your profile onto a blank **passive** NFC bracelet as an HTTPS card link (`#d=…` on the chip). A smartphone that taps powers the chip and opens the emergency card in a browser — RedMed not required. Also reads tags back onto this phone. |

Tapping a written tag opens `https://maxroot1122.github.io/RedMed/index.html#d=…` in the phone's browser (works on iPhone, Android, etc.). GitHub Pages must be enabled for that host to resolve.

---

## Command-line build (optional)

Requires full Xcode (not Command Line Tools alone):

```bash
./scripts/build-ios.sh
```

This compile-checks the project without signing. To install on a device, use Xcode → Run as above.

---

## Already configured in the project

You should not need to add these manually:

| Setting | Value |
|--------|--------|
| Bundle ID | `local.redmed.app` |
| Display name | RedMed |
| URL scheme | `redmed` in Info.plist |
| NFC entitlement | NDEF + TAG in `RedMed.entitlements` |
| Location | When In Use (Find 911) |
| App icon | `Assets.xcassets` (Rod of Asclepius mark) |
| Launch screen | Auto-generated (portrait) |

`AppConfig.medicalCardBaseURL` is `https://maxroot1122.github.io/RedMed/index.html` (any-device NFC). Legacy `redmed://` remains in Info.plist for older tags.

---

## Publishing to TestFlight / App Store (your Apple account)

Cannot be done without your credentials. After the app runs on your phone from Xcode:

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs) ($99/yr).
2. In Xcode: switch **Signing & Capabilities** to your paid team.
3. **Product → Archive** → **Distribute App → App Store Connect → Upload**.
4. In [App Store Connect](https://appstoreconnect.apple.com): create app with bundle ID `local.redmed.app`, add privacy policy URL `https://maxroot1122.github.io/RedMed/privacy-policy.html`, screenshots, then submit. **App Privacy / Data Safety:** declare precise location (Find 911, on-device only while that screen is open — not sent to developer servers) and on-device medical profile fields per the privacy policy; first-launch consent dialog matches the web banner (see `UseConsentView.swift`).

Full checklist: [`docs/IOS_APP_STORE.md`](../docs/IOS_APP_STORE.md).

---

## Notes

- Profile data is stored in the iOS Keychain (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`) — not synced to iCloud.
- Linked bracelet chip URL (includes `#d=` medical payload) is also stored in the Keychain; device display name stays in UserDefaults.
- The app never auto-dials 911; buttons open Phone/Messages pre-filled for you to confirm.
- **Find 911 and satellite emergency:** RedMed shows on-device GPS coordinates and a copyable dispatch summary. It does not connect to satellites or simulate satellite pointing. If you have no cell service, iPhone Emergency SOS via satellite and Android Satellite SOS are built into the operating system (Settings → Emergency SOS on iPhone 14+, or your phone's native emergency dialer on supported Android devices). RedMed's Find 911 screen explains that path when you're offline — it cannot open or control those OS features.
- First aid content is general public guidance, not personalized medical advice.
