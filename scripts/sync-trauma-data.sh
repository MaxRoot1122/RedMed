#!/usr/bin/env bash
# Copy bundled trauma hospital data to all consumers.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JSON="$ROOT/assets/trauma-hospitals.json"
JS="$ROOT/assets/trauma-hospitals.js"
IOS="$ROOT/ios/RedMed/trauma-hospitals.json"
WWW_ASSETS="$ROOT/RedMed.app/Contents/Resources/www/assets"
if [ ! -f "$JSON" ]; then
  echo "missing $JSON" >&2
  exit 1
fi
cp "$JSON" "$IOS"
mkdir -p "$WWW_ASSETS"
cp "$JSON" "$WWW_ASSETS/trauma-hospitals.json"
if [ -f "$JS" ]; then
  cp "$JS" "$WWW_ASSETS/trauma-hospitals.js"
fi
echo "trauma data synced to iOS + macOS mirror."
