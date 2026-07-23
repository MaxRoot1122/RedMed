# RedMed brand assets

Two intentional marks — **do not swap them**.

| Asset | File | Use |
|-------|------|-----|
| **App cover / icon** | `assets/icon.svg` (+ PNG/ICNS exports) | Home screen, favicon, PWA manifest, App Store, `get.html` hero, iOS `AppIcon`, linked-device emblem in header |
| **In-app wordmark** | `assets/wordmark.svg` (+ `BrandWordmark` on iOS) | My ID header, Aid chrome, anywhere the product name “RedMed” appears inside the app |
| **Symbol only** | `assets/mark.svg` | Optional tiny contexts (future: NFC sheet, loading splash) — not the full cover plate |

`icon.svg` is the **only** source for raster app icons. Regenerate PNGs/ICNS after editing it (`sips` / `iconutil` on macOS).

---

## iOS asset strategy (SF Symbols vs raster vs vector)

**Do not pick one approach for everything.** RedMed uses a split:

| Asset kind | Approach | Why |
|------------|----------|-----|
| **UI affordances** (Aid tiles, chevrons, phone, NFC, remove chips) | **SF Symbols** (`Image(systemName:)`) | Already wired in `BasicAidView`, `IconWell`, toolbars. Scales with Dynamic Type, tintable, no export pipeline. |
| **Brand cover + wordmark** (`BrandLogo`, `BrandWordmark`) | **Single PDF per imageset** in Xcode with **Preserve Vector Data** | Export once from `icon.svg` / `wordmark.svg`. Xcode scales — no `@1x/@2x/@3x` PNG maintenance. |
| **App Store / home-screen icon** | **Single raster PNG** — `AppIcon.appiconset/AppIcon.png` at **1024×1024** | Apple requires PNG for the app icon slot; Xcode generates all installed sizes from this one file. |
| **Web / Play / favicon** | **Raster PNG** from same SVG via `./scripts/generate-icons.sh` | Browsers and Play Console don't use xcassets PDFs. |

### Recommended (vectors + SF Symbols)

- **Aid / chrome icons:** keep SF Symbols — iOS already does; web keeps inline SVG paths in `index.html` (platform-appropriate).
- **Brand in xcassets:** replace three PNG slots with one vector PDF each:

```bash
# macOS — after editing icon.svg or wordmark.svg
rsvg-convert -f pdf -o ios/RedMed/Assets.xcassets/BrandLogo.imageset/BrandLogo.pdf assets/icon.svg
rsvg-convert -f pdf -o ios/RedMed/Assets.xcassets/BrandWordmark.imageset/BrandWordmark.pdf assets/wordmark.svg
```

In each imageset `Contents.json`: one universal PDF entry + `"preserves-vector-representation": true`. Delete `BrandLogo.png`, `@2x`, `@3x` once PDF is in place.

- **App icon + web rasters:** still run PNG export (below) — that is the only place 1×/2×/3× (or fixed sizes like 1024, 512, 180) stay necessary.

### When to keep 1×/2×/3× PNG instead of PDF

Only if you hit a rare PDF rendering glitch on a specific device, or you need pixel-crunched effects in the brand mark that PDF scaling softens. For RedMed's flat SVG plate + wordmark, PDF is the better default.

### Do not

- Put **custom brand art** in SF Symbols (bronze cross plate isn't a system glyph).
- Use **`.svg` files directly** in xcassets — use **PDF** (or PNG); SVG stays source in `assets/`.
- Drop **AppIcon** PNGs thinking PDF/SF Symbols replace them — they don't for store/install.

### Safe areas vs resolution

**Insets matter more than pixel density.** A layout that clears Dynamic Island and the home indicator reads correctly on every iPhone; extra @2x/@3x PNG exports do not fix content drawn under the island or home bar.

| Region | Typical inset (pt) | In code |
|--------|-------------------|---------|
| Top (Dynamic Island class) | ~59 | SwiftUI safe area — **do not hardcode** |
| Bottom (home indicator) | ~34 | SwiftUI safe area + tab bar when applicable |
| Horizontal | System + `layout.screenPad` (~20 scaled) | Side margin on scroll content |

- **Backgrounds** (`ScreenAtmosphere`) may use `.ignoresSafeArea()`; **interactive content** must not.
- **`screenBottom` / `screenPad`** in `LayoutMetrics` are extra content spacing on top of system insets, not replacements for them.
- Design comps (mockups, Figma, screenshots — **not** SwiftUI): use **two frames** and you cover the iPhone range:
  - **393×852** — standard (iPhone 15/16 class)
  - **440×956** — large (Pro Max class)
  Keep tap targets and primary text inside the safe rectangle (~759 pt tall on island phones on the smaller frame).

---

## Brainstorm (review in the morning)

### A — **Shipped for tonight** ✓
- **Cover** = full squircle plate + bronze cross + serpent (`icon.svg`) — unchanged identity on stores and install.
- **In-app** = horizontal **wordmark** (`wordmark.svg`): mini cover plate + “RedMed” + “MEDICAL ID” subtitle.
- **Linked bracelet** = header switches to **device name** + small **cover icon** (same as home screen) so the band reads as “this app on this device.”

*Pros:* Clear separation; wordmark reads at header size; cover stays iconic.  
*Cons:* Wordmark uses SVG text (fine on web/iOS 16+; falls back to system rounded sans).

### B — Typographic wordmark only (no mini icon)
“RedMed” gradient type only, no plate in the header.

*Pros:* Ultra-clean, Google/Apple minimal.  
*Cons:* Less tied to bracelet/cover story; weaker at a glance in emergencies.

### C — Wordmark + tagline lockup variants
- `wordmark.svg` — default My ID  
- `wordmark-aid.svg` — “RedMed · Roadside Aid” for Aid tab  
- `wordmark-911.svg` — “RedMed · Find 911” muted

*Pros:* Per-screen context without changing the cover.  
*Cons:* More files/translations to maintain.

### D — Animated header pulse when bracelet connected
Green dot on wordmark plate when NFC in range (web already pulses bracelet chip).

*Pros:* Reinforces live link.  
*Cons:* Motion in a medical app — use only if subtle.

### E — Dark / high-contrast wordmark
Duplicate wordmarks for OLED / outdoor readability.

*Pros:* Accessibility outdoors.  
*Cons:* Another export set.

**Recommendation:** Ship **A** now; try **C** if Aid/911 headers feel samey; skip **D** until you’ve used A for a week.

---

## Regenerate rasters (macOS)

**App icon + web only** (required PNG). Brand imagesets should use PDF vectors (see above) unless you intentionally stay on PNG `@1x/@2x/@3x`.

```bash
# App icon set (cover) — single 1024×1024 for iOS; other web/Play sizes below
rsvg-convert -w 1024 -h 1024 assets/icon.svg -o ios/RedMed/Assets.xcassets/AppIcon.appiconset/AppIcon.png
# Or: ./scripts/generate-icons.sh (writes AppIcon.png + favicon, apple-touch, Play 512)

# Optional: iOS brand vectors (preferred over PNG triplets)
rsvg-convert -f pdf -o ios/RedMed/Assets.xcassets/BrandWordmark.imageset/BrandWordmark.pdf assets/wordmark.svg
rsvg-convert -f pdf -o ios/RedMed/Assets.xcassets/BrandLogo.imageset/BrandLogo.pdf assets/icon.svg

# Legacy PNG triplets (only if not using PDF in xcassets)
rsvg-convert -w 360 -h 88 assets/wordmark.svg -o ios/RedMed/Assets.xcassets/BrandWordmark.imageset/BrandWordmark.png
rsvg-convert -w 720 -h 176 assets/wordmark.svg -o ios/RedMed/Assets.xcassets/BrandWordmark.imageset/BrandWordmark@2x.png
rsvg-convert -w 1080 -h 264 assets/wordmark.svg -o ios/RedMed/Assets.xcassets/BrandWordmark.imageset/BrandWordmark@3x.png
rsvg-convert -w 120 -h 120 assets/icon.svg -o ios/RedMed/Assets.xcassets/BrandLogo.imageset/BrandLogo.png
rsvg-convert -w 240 -h 240 assets/icon.svg -o ios/RedMed/Assets.xcassets/BrandLogo.imageset/BrandLogo@2x.png
rsvg-convert -w 360 -h 360 assets/icon.svg -o ios/RedMed/Assets.xcassets/BrandLogo.imageset/BrandLogo@3x.png
```

On Linux CI (this environment): `rsvg-convert` works for the same commands.

---

## Where each file is wired

| Location | Asset |
|----------|--------|
| `index.html` header (default) | `wordmark.svg` |
| `index.html` header (bracelet linked) | `icon.svg` + device name |
| `index.html` Aid header | `wordmark.svg` + Aid title |
| `get.html` | `icon.svg` (cover) |
| `manifest.json` / favicon | PNG from `icon.svg` |
| iOS `BrandMark` default | `BrandWordmark` image |
| iOS `BrandMark` device override | `BrandLogo` (cover icon) + name |
