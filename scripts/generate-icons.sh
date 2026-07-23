#!/usr/bin/env bash
# Regenerate raster icons from assets/icon.svg (requires Inkscape or rsvg-convert).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SVG="$ROOT/assets/icon.svg"

if [[ ! -f "$SVG" ]]; then
  echo "Missing $SVG" >&2
  exit 1
fi

render() {
  local size="$1" out="$2"
  if command -v rsvg-convert >/dev/null 2>&1; then
    rsvg-convert -w "$size" -h "$size" "$SVG" -o "$out"
  elif command -v inkscape >/dev/null 2>&1; then
    inkscape "$SVG" -w "$size" -h "$size" -o "$out"
  elif command -v qlmanage >/dev/null 2>&1 && command -v sips >/dev/null 2>&1; then
    local tmp
    tmp="$(mktemp -t redmed-logo).png"
    qlmanage -t -s 512 -o "$(dirname "$tmp")" "$SVG" >/dev/null 2>&1
    mv "$(dirname "$tmp")/$(basename "$SVG").png" "$tmp"
    sips -z "$size" "$size" "$tmp" --out "$out" >/dev/null
    rm -f "$tmp"
  else
    echo "Install rsvg-convert (librsvg), Inkscape, or use macOS qlmanage+sips." >&2
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

echo "Done. Run ./scripts/sync-www-mirror.sh to refresh RedMed.app."
