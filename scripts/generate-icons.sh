#!/usr/bin/env bash
# Regenerate raster icons from assets/icon.svg or assets/icon-512.png (macOS sips).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SVG="$ROOT/assets/icon.svg"
PNG="$ROOT/assets/icon-512.png"

if [[ ! -f "$SVG" && ! -f "$PNG" ]]; then
  echo "Missing $SVG or $PNG" >&2
  exit 1
fi

render() {
  local size="$1" out="$2"
  if [[ -f "$PNG" ]] && command -v sips >/dev/null 2>&1; then
    sips -z "$size" "$size" "$PNG" --out "$out" >/dev/null
  elif [[ -f "$SVG" ]] && command -v rsvg-convert >/dev/null 2>&1; then
    rsvg-convert -w "$size" -h "$size" "$SVG" -o "$out"
  elif [[ -f "$SVG" ]] && command -v inkscape >/dev/null 2>&1; then
    inkscape "$SVG" -w "$size" -h "$size" -o "$out"
  else
    echo "Install icon-512.png + sips (macOS), or rsvg-convert / Inkscape for SVG." >&2
    exit 1
  fi
}

render 32 "$ROOT/assets/favicon-32.png"
echo "assets/favicon-32.png"
render 180 "$ROOT/assets/apple-touch-icon.png"
echo "assets/apple-touch-icon.png"
render 512 "$ROOT/assets/icon-512.png"
echo "assets/icon-512.png"

mkdir -p "$ROOT/play/listing"
cp "$ROOT/assets/icon-512.png" "$ROOT/play/listing/play-store-icon-512.png"
echo "play/listing/play-store-icon-512.png"

APPICON="$ROOT/ios/RedMed/Assets.xcassets/AppIcon.appiconset"
render 1024 "$APPICON/AppIcon.png"
echo "$APPICON/AppIcon.png"

BRAND="$ROOT/ios/RedMed/Assets.xcassets/BrandLogo.imageset"
for size in 120 240 360; do
  case "$size" in
    120) out="$BRAND/BrandLogo.png" ;;
    240) out="$BRAND/BrandLogo@2x.png" ;;
    360) out="$BRAND/BrandLogo@3x.png" ;;
  esac
  render "$size" "$out"
  echo "$out"
done

# Optional: BrandWordmark rasters from the iOS wordmark source (tagline baked in).
WORDMARK_IOS="$ROOT/assets/wordmark-ios.svg"
BRAND_WM="$ROOT/ios/RedMed/Assets.xcassets/BrandWordmark.imageset"
render_wordmark_raster() {
  local width="$1" height="$2" out="$3"
  if command -v rsvg-convert >/dev/null 2>&1; then
    rsvg-convert -w "$width" -h "$height" "$WORDMARK_IOS" -o "$out"
    return 0
  fi
  if command -v qlmanage >/dev/null 2>&1 && command -v sips >/dev/null 2>&1; then
    local tmp="$ROOT/build/wordmark-thumb.png"
    mkdir -p "$ROOT/build"
    rm -f "$tmp"
    qlmanage -t -s "$width" -o "$ROOT/build" "$WORDMARK_IOS" >/dev/null 2>&1
    mv "$ROOT/build/wordmark-ios.svg.png" "$tmp"
    sips -z "$height" "$width" "$tmp" --out "$out" >/dev/null
    return 0
  fi
  return 1
}
if [[ -f "$WORDMARK_IOS" ]]; then
  if render_wordmark_raster 360 88 "$BRAND_WM/BrandWordmark.png" \
    && render_wordmark_raster 720 176 "$BRAND_WM/BrandWordmark@2x.png" \
    && render_wordmark_raster 1080 264 "$BRAND_WM/BrandWordmark@3x.png"; then
    echo "BrandWordmark PNGs from wordmark-ios.svg"
  else
    echo "WARN: could not render BrandWordmark PNGs (install rsvg-convert or use macOS qlmanage+sips)." >&2
  fi
fi

if [[ -f "$PNG" ]]; then
  cp "$PNG" "$ROOT/assets/cpr-trainer-icon.png"
  echo "assets/cpr-trainer-icon.png"
fi

if command -v iconutil >/dev/null 2>&1 && [[ -f "$PNG" ]]; then
  ICONSET="$ROOT/build/icon.iconset"
  rm -rf "$ICONSET"
  mkdir -p "$ICONSET"
  SRC="$PNG"
  sips -z 16 16 "$SRC" --out "$ICONSET/icon_16x16.png" >/dev/null
  sips -z 32 32 "$SRC" --out "$ICONSET/icon_16x16@2x.png" >/dev/null
  sips -z 32 32 "$SRC" --out "$ICONSET/icon_32x32.png" >/dev/null
  sips -z 64 64 "$SRC" --out "$ICONSET/icon_32x32@2x.png" >/dev/null
  sips -z 128 128 "$SRC" --out "$ICONSET/icon_128x128.png" >/dev/null
  sips -z 256 256 "$SRC" --out "$ICONSET/icon_128x128@2x.png" >/dev/null
  sips -z 256 256 "$SRC" --out "$ICONSET/icon_256x256.png" >/dev/null
  sips -z 512 512 "$SRC" --out "$ICONSET/icon_256x256@2x.png" >/dev/null
  sips -z 512 512 "$SRC" --out "$ICONSET/icon_512x512.png" >/dev/null
  sips -z 1024 1024 "$SRC" --out "$ICONSET/icon_512x512@2x.png" >/dev/null
  iconutil -c icns "$ICONSET" -o "$ROOT/mac/RedMed.app/Contents/Resources/AppIcon.icns"
  echo "mac/RedMed.app/Contents/Resources/AppIcon.icns"
fi

echo "Done. Run ./scripts/sync-www-mirror.sh to refresh mac/RedMed.app www/."
