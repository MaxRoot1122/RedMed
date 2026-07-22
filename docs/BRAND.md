# RedMed brand assets

Two intentional marks — **do not swap them**.

| Asset | File | Use |
|-------|------|-----|
| **App cover / icon** | `assets/icon.svg` (+ PNG/ICNS exports) | Home screen, favicon, PWA manifest, App Store, `get.html` hero, iOS `AppIcon`, linked-device emblem in header |
| **In-app wordmark** | `assets/wordmark.svg` (+ `BrandWordmark` on iOS) | My ID header, Aid chrome, anywhere the product name “RedMed” appears inside the app |
| **Symbol only** | `assets/mark.svg` | Optional tiny contexts (future: NFC sheet, loading splash) — not the full cover plate |

`icon.svg` is the **only** source for raster app icons. Regenerate PNGs/ICNS after editing it (`sips` / `iconutil` on macOS).

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

```bash
# App icon set (cover)
rsvg-convert -w 1024 -h 1024 assets/icon.svg -o assets/icon-1024.png
# …existing sips/iconutil pipeline for favicon, apple-touch, AppIcon.appiconset

# In-app wordmark (iOS BrandWordmark.imageset)
rsvg-convert -w 360 -h 88 assets/wordmark.svg -o ios/RedMed/Assets.xcassets/BrandWordmark.imageset/BrandWordmark.png
rsvg-convert -w 720 -h 176 assets/wordmark.svg -o ios/RedMed/Assets.xcassets/BrandWordmark.imageset/BrandWordmark@2x.png
rsvg-convert -w 1080 -h 264 assets/wordmark.svg -o ios/RedMed/Assets.xcassets/BrandWordmark.imageset/BrandWordmark@3x.png

# Cover-consistent toolbar emblem (iOS BrandLogo = full icon)
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
