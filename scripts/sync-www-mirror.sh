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

# Prefer rsync when available; fall back to cp so Linux CI/agents without rsync still sync.
sync_dir() {
  local src="$1" dest="$2"
  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$src/" "$dest/"
  else
    # Best-effort mirror without rsync: refresh files, leave orphan cleanup to verify-web.
    cp -a "$src"/. "$dest"/
  fi
}

if [ -d "$ROOT/assets" ]; then
  sync_dir "$ROOT/assets" "$WWW/assets"
fi

if [ -d "$ROOT/config" ]; then
  sync_dir "$ROOT/config" "$WWW/config"
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
