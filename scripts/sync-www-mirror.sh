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
for f in icon.svg mark.svg wordmark.svg apple-touch-icon.png favicon-32.png logo-512.png; do
  if [ -f "$ROOT/assets/$f" ]; then
    cp "$ROOT/assets/$f" "$WWW/assets/$f"
  fi
done

if [ -d "$ROOT/assets" ]; then
  rsync -a "$ROOT/assets/" "$WWW/assets/"
fi

for page in index.html get.html privacy-policy.html terms-of-service.html; do
  if [ -f "$ROOT/$page" ] && [ -f "$WWW/$page" ]; then
    diff -q "$ROOT/$page" "$WWW/$page"
  fi
done

echo "www mirror synced."
