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
  else
    echo "Install rsvg-convert (librsvg) or Inkscape to render icons." >&2
    exit 1
  fi
}

for size in 16 32 48 64 128 180 192 256 512 1024; do
  render "$size" "$ROOT/assets/icon-${size}.png"
  echo "assets/icon-${size}.png"
done

cp "$ROOT/assets/icon-32.png" "$ROOT/assets/favicon-32.png"
cp "$ROOT/assets/icon-180.png" "$ROOT/assets/apple-touch-icon.png"
cp "$ROOT/assets/icon-512.png" "$ROOT/play/listing/play-store-icon-512.png"

echo "Done. Copy iOS/Android appiconset variants manually or use Xcode/Android Studio asset tools."
