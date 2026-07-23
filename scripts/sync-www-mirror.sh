#!/usr/bin/env bash
# Keep macOS wrapper www/ in sync with root static files.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WWW="$ROOT/RedMed.app/Contents/Resources/www"
mkdir -p "$WWW/assets"

if [ -f "$ROOT/assets/logo.pdf" ] && command -v sips >/dev/null 2>&1; then
  sips -s format png "$ROOT/assets/logo.pdf" --out "$ROOT/assets/logo-header.png" >/dev/null
fi

for page in index.html get.html manifest.json privacy-policy.html terms-of-service.html; do
  if [ -f "$ROOT/$page" ]; then
    cp "$ROOT/$page" "$WWW/$page"
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
