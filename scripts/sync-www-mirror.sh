#!/usr/bin/env bash
# Keep macOS wrapper www/ in sync with root static files.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WWW="$ROOT/RedMed.app/Contents/Resources/www"
mkdir -p "$WWW/assets" "$WWW/config"
cp "$ROOT/index.html" "$WWW/index.html"
cp "$ROOT/get.html" "$WWW/get.html"
if [ -f "$ROOT/assets/trauma-hospitals.json" ]; then
  cp "$ROOT/assets/trauma-hospitals.json" "$WWW/assets/trauma-hospitals.json"
fi
if [ -f "$ROOT/assets/trauma-hospitals.js" ]; then
  cp "$ROOT/assets/trauma-hospitals.js" "$WWW/assets/trauma-hospitals.js"
fi
diff -q "$ROOT/index.html" "$WWW/index.html"
echo "www mirror synced."
