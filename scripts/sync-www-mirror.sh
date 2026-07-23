#!/usr/bin/env bash
# Keep macOS wrapper www/ in sync with root static files (source of truth: repo root).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WWW="$ROOT/RedMed.app/Contents/Resources/www"
mkdir -p "$WWW/assets" "$WWW/config"

cp "$ROOT/index.html" "$WWW/index.html"
cp "$ROOT/get.html" "$WWW/get.html"
cp "$ROOT/privacy-policy.html" "$WWW/privacy-policy.html"
cp "$ROOT/terms-of-service.html" "$WWW/terms-of-service.html"
cp "$ROOT/manifest.json" "$WWW/manifest.json"

if [ -d "$ROOT/assets" ]; then
  rsync -a --delete "$ROOT/assets/" "$WWW/assets/"
fi

if [ -d "$ROOT/config" ]; then
  rsync -a "$ROOT/config/" "$WWW/config/"
fi

# Legacy duplicates at www root — legal pages and HTML use assets/ paths only.
rm -f "$WWW/heading.svg" "$WWW/heading.png" "$WWW/wordmark.svg" "$WWW/legal-doc.css"

cp "$ROOT/scripts/redmed-server.sh" "$ROOT/RedMed.app/Contents/Resources/redmed-server.sh"

for page in index.html get.html privacy-policy.html terms-of-service.html; do
  if [ -f "$ROOT/$page" ] && [ -f "$WWW/$page" ]; then
    diff -q "$ROOT/$page" "$WWW/$page"
  fi
done

echo "www mirror synced."
