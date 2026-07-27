#!/usr/bin/env bash
# Keep macOS wrapper www/ mirrors in sync with root static files (source of truth: repo root).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MIRRORS=(
  "$ROOT/mac/RedMed.app/Contents/Resources/www"
  "$ROOT/ios/RedMed.app/Contents/Resources/www"
)

sync_www() {
  local WWW="$1"
  mkdir -p "$WWW/assets" "$WWW/config" "$WWW/card"

  cp "$ROOT/index.html" "$WWW/index.html"
  cp "$ROOT/get.html" "$WWW/get.html"
  cp "$ROOT/privacy-policy.html" "$WWW/privacy-policy.html"
  cp "$ROOT/terms-of-service.html" "$WWW/terms-of-service.html"
  cp "$ROOT/manifest.json" "$WWW/manifest.json"
  cp "$ROOT/card/index.html" "$WWW/card/index.html"
  cp "$ROOT/card/sw.js" "$WWW/card/sw.js"

  if [ -d "$ROOT/assets" ]; then
    rm -rf "$WWW/assets"
    mkdir -p "$WWW/assets"
    cp -a "$ROOT/assets/." "$WWW/assets/"
  fi

  if [ -d "$ROOT/config" ]; then
    mkdir -p "$WWW/config"
    cp -a "$ROOT/config/." "$WWW/config/"
  fi

  # Legacy duplicates at www root — legal pages and HTML use assets/ paths only.
  rm -f "$WWW/heading.svg" "$WWW/heading.png" "$WWW/wordmark.svg" "$WWW/legal-doc.css" \
    "$WWW/logo-32.png" "$WWW/logo-180.png" "$WWW/logo-512.png"
}

for WWW in "${MIRRORS[@]}"; do
  sync_www "$WWW"
  for page in index.html get.html privacy-policy.html terms-of-service.html card/index.html card/sw.js; do
    if [ -f "$ROOT/$page" ] && [ -f "$WWW/$page" ]; then
      diff -q "$ROOT/$page" "$WWW/$page"
    fi
  done
  echo "www mirror synced: ${WWW#"$ROOT/"}"
done

cp "$ROOT/scripts/redmed-server.sh" "$ROOT/mac/RedMed.app/Contents/Resources/redmed-server.sh"
cp "$ROOT/scripts/redmed-server.sh" "$ROOT/ios/RedMed.app/Contents/Resources/redmed-server.sh"

echo "www mirrors synced."

