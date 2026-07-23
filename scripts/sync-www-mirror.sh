#!/usr/bin/env bash
# Keep macOS wrapper www/ in sync with root static files.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WWW="$ROOT/RedMed.app/Contents/Resources/www"
mkdir -p "$WWW/assets" "$WWW/config"
cp "$ROOT/index.html" "$WWW/index.html"
cp "$ROOT/get.html" "$WWW/get.html"
cp "$ROOT/privacy-policy.html" "$WWW/privacy-policy.html"
cp "$ROOT/terms-of-service.html" "$WWW/terms-of-service.html"
cp "$ROOT/manifest.json" "$WWW/manifest.json"
for f in logo.svg longlogo.svg longlogo.png apple-touch-icon.png favicon-32.png logo-512.png; do
  if [ -f "$ROOT/assets/$f" ]; then
    cp "$ROOT/assets/$f" "$WWW/assets/$f"
  fi
done
if [ -f "$ROOT/assets/trauma-hospitals.json" ]; then
  cp "$ROOT/assets/trauma-hospitals.json" "$WWW/assets/trauma-hospitals.json"
fi
if [ -f "$ROOT/assets/trauma-hospitals.js" ]; then
  cp "$ROOT/assets/trauma-hospitals.js" "$WWW/assets/trauma-hospitals.js"
fi
diff -q "$ROOT/index.html" "$WWW/index.html"
echo "www mirror synced."
