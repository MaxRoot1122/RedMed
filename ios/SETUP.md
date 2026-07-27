# RedMed — iOS app

Local-first medical ID **iPhone app**: edit your profile, write it to an NFC tag, read tags back, offline first-aid guide, and Find 911 with GPS. Everything stays on-device — no accounts, no server. RedMed is iOS-only (not web, not Android).

**Double-click to open:** `ios/RedMed.xcodeproj` · **Simulator:** `ios/RedMed.app` or `ios/RedMed.command`

| File | What it does |
|------|----------------|
| **`ios/RedMed.app`** | Double-click — builds (if needed) and runs on iPhone Simulator |
| **`ios/RedMed.command`** | Same, with Terminal build output |
| **`build/RedMed-Simulator.app`** | Drag onto Simulator to reinstall (created after first launch) |

Mac copies and Desktop shortcuts: see [`../mac/SETUP.md`](../mac/SETUP.md).

| Setting | Value |
|--------|--------|
| Bundle ID | `local.redmed.app` |
| URL scheme | `redmed://` — in-app deep links only; **new NFC writes** use HTTPS `card/#d=…` on the chip |
| Deployment | iOS 27.0+ · iPhone only |
| Layout | **393×852 pt** baseline via `LayoutMetrics` (`AppTheme.swift`); mockups also check **440×956**; safe areas ≈59 pt top / 34 pt bottom on Dynamic Island |
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
| **My ID** | Read-only summary; **Edit** opens the form. Face ID is required to **edit** only after the first save — viewing tabs and the summary stay open. First-time setup has no biometric gate. |
| **Find 911** | Call 911, **Scan emergency bracelet** (native first-responder card), live GPS, trauma hospitals by state (county picker when 30+). Offline: factual Emergency SOS via satellite guidance (OS-level — RedMed cannot initiate it). |
| **Aid** | Offline first-aid topics + CPR compression timer. |
| **NFC** | Writes your profile onto a blank **passive** bracelet as HTTPS `card/#d=…` (Safari for anyone who taps). **Scan emergency bracelet** opens native SwiftUI (`ScannedCardView`) for owners. **Import** pulls a tag onto this phone. |

**Owners** use RedMed (SwiftUI) to edit, write, and scan in-app. **Anyone else** taps the band — Safari opens the hosted emergency card; no App Store install. Legacy `redmed://` tags still decode when scanned inside the app.

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

`AppConfig.medicalCardBaseURL` is HTTPS `card/` (passersby → Safari). Keep in sync with [`config/canonical-url`](../config/canonical-url). `redmed://` remains for in-app deep links and legacy tags.

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

- **Layout:** Design at **393×852 pt**. `ContentView` installs `LayoutMetrics` via `.withLayoutMetrics()`. In views and button styles, use `@Environment(\.layoutMetrics) private var layout` and tokens like `layout.screenPad`, `layout.heroTitleFont()`, or `layout.s(14)` — do not hardcode point sizes.
- **Mockups (not code):** check layouts at **393×852** and **440×956** — see [`docs/BRAND.md`](../docs/BRAND.md) § Safe areas.
- Profile data is stored in the iOS Keychain (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`) — not synced to iCloud.
- Linked bracelet chip URL (includes `#d=` medical payload) is also stored in the Keychain; device display name stays in UserDefaults.
- The app never auto-dials 911; buttons open the Phone dialer pre-filled for you to confirm.
- **Find 911 and satellite emergency:** RedMed shows on-device GPS coordinates you can copy. It does not connect to satellites or simulate satellite pointing. If you have no cell service, iPhone Emergency SOS via satellite and Android Satellite SOS are built into the operating system (Settings → Emergency SOS on iPhone 14+, or your phone's native emergency dialer on supported Android devices). RedMed's Find 911 screen explains that path when you're offline — it cannot open or control those OS features.
- First aid content is general public guidance, not personalized medical advice.
