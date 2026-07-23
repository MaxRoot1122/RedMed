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

for size in 32 180 512; do
  render "$size" "$ROOT/assets/logo-${size}.png"
  echo "assets/logo-${size}.png"
done

cp "$ROOT/assets/logo-32.png" "$ROOT/assets/favicon-32.png"
cp "$ROOT/assets/logo-180.png" "$ROOT/assets/apple-touch-icon.png"
mkdir -p "$ROOT/play/listing"
cp "$ROOT/assets/logo-512.png" "$ROOT/play/listing/play-store-icon-512.png"

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
  mkdir -p "$ROOT/RedMed.app/Contents/Resources/www/assets"
  iconutil -c icns "$ICONSET" -o "$ROOT/RedMed.app/Contents/Resources/www/assets/AppIcon.icns"
  echo "RedMed.app/Contents/Resources/www/assets/AppIcon.icns"
fi

echo "Done. Run ./scripts/sync-www-mirror.sh to refresh RedMed.app www/."
