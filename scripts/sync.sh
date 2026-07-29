#!/usr/bin/env bash
# Propagate repo config and static files to iOS, web mirrors, and launcher plists.
# Usage: ./scripts/sync.sh [all|canonical|trauma|www|stamp]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
CMD="${1:-all}"

stamp_repo_root() {
  local PLIST="${ROOT}/ios/RedMed.app/Contents/Info.plist"
  if [ ! -f "$PLIST" ]; then
    echo "Info.plist not found: ${PLIST}" >&2
    exit 1
  fi
  /usr/libexec/PlistBuddy -c "Set :RedMedRepoRoot ${ROOT}" "$PLIST"
  echo "RedMedRepoRoot → ${ROOT} (${PLIST#"$ROOT/"})"
}

sync_canonical() {
  python3 - "$ROOT" "$ROOT/config/canonical-url" <<'PY'
import re
import sys
from pathlib import Path
from urllib.parse import urlparse

root = Path(sys.argv[1])
cfg_path = Path(sys.argv[2])
lines = [ln.strip() for ln in cfg_path.read_text(encoding="utf-8").splitlines()]

card_url = next((ln for ln in lines if ln and not ln.startswith("#") and not ln.startswith("legacy:")), "")
if not card_url:
    sys.exit("No active target found in config/canonical-url")

legacy_urls = [
    ln.lstrip("#").strip().split(":", 1)[1]
    for ln in lines
    if ln.lstrip("#").strip().startswith("legacy:https://")
]
if not legacy_urls:
    sys.exit("No legacy:https:// line found in config/canonical-url")
legacy_url = legacy_urls[0]

site_base = card_url.rstrip("/").rsplit("/", 1)[0]
privacy_url = site_base + "/privacy-policy.html"
get_started_url = site_base + "/get"

print(f"Active card target: {card_url}")
print(f"Legacy card URL:    {legacy_url}")

app_config = root / "ios/RedMed/AppConfig.swift"
text = app_config.read_text(encoding="utf-8")
text = re.sub(r'static let getStartedURL = "https?://[^"]+"', f'static let getStartedURL = "{get_started_url}"', text)
text = re.sub(r'static let medicalCardBaseURL = "[^"]+"', f'static let medicalCardBaseURL = "{card_url}"', text)
text = re.sub(r'static let legacyHostedCardBaseURL = "https?://[^"]+"', f'static let legacyHostedCardBaseURL = "{legacy_url}"', text)
text = re.sub(r'static let privacyPolicyURL = "https?://[^"]+"', f'static let privacyPolicyURL = "{privacy_url}"', text)
app_config.write_text(text, encoding="utf-8")

print("Synced AppConfig.swift from config/canonical-url.")
PY
}

sync_trauma() {
  local json="$ROOT/assets/trauma-hospitals.json"
  local js="$ROOT/assets/trauma-hospitals.js"
  local ios="$ROOT/ios/RedMed/trauma-hospitals.json"
  local www="$ROOT/ios/RedMed.app/Contents/Resources/assets"
  if [ ! -f "$json" ]; then
    echo "missing $json" >&2
    exit 1
  fi
  cp "$json" "$ios"
  mkdir -p "$www"
  cp "$json" "$www/trauma-hospitals.json"
  if [ -f "$js" ]; then
    cp "$js" "$www/trauma-hospitals.js"
  fi
  echo "trauma data synced to iOS + macOS mirror."
}

sync_www() {
  local www="$1"
  mkdir -p "$www/assets" "$www/config" "$www/card"
  cp "$ROOT/get.html" "$www/get.html"
  mkdir -p "$www/get"
  cp "$ROOT/get.html" "$www/get/index.html"
  cp "$ROOT/privacy-policy.html" "$www/privacy-policy.html"
  cp "$ROOT/terms-of-service.html" "$www/terms-of-service.html"
  cp "$ROOT/card/index.html" "$www/card/index.html"
  cp "$ROOT/card/sw.js" "$www/card/sw.js"
  rm -f "$www/index.html" "$www/manifest.json"
  if [ -d "$ROOT/assets" ]; then
    rm -rf "$www/assets"
    mkdir -p "$www/assets"
    cp -a "$ROOT/assets/." "$www/assets/"
  fi
  if [ -d "$ROOT/config" ]; then
    mkdir -p "$www/config"
    cp -a "$ROOT/config/." "$www/config/"
  fi
  rm -f "$www/heading.svg" "$www/heading.png" "$www/wordmark.svg" "$www/legal-doc.css" \
    "$www/logo-32.png" "$www/logo-180.png" "$www/logo-512.png"
}

case "$CMD" in
  all)
    sync_canonical
    sync_trauma
    sync_www "$ROOT/ios/RedMed.app/Contents/Resources"
    echo "www mirror synced: ios/RedMed.app/Contents/Resources"
    sync_www "$HOME"
    echo "www mirror synced: ${HOME} (local preview)"
    cp "$ROOT/scripts/redmed-server.sh" "$ROOT/ios/RedMed.app/Contents/Resources/redmed-server.sh"
    stamp_repo_root
    ;;
  canonical) sync_canonical ;;
  trauma) sync_trauma ;;
  www)
    sync_www "$ROOT/ios/RedMed.app/Contents/Resources"
    echo "www mirror synced: ios/RedMed.app/Contents/Resources"
    sync_www "$HOME"
    echo "www mirror synced: ${HOME} (local preview)"
    cp "$ROOT/scripts/redmed-server.sh" "$ROOT/ios/RedMed.app/Contents/Resources/redmed-server.sh"
    ;;
  stamp) stamp_repo_root ;;
  *)
    echo "Usage: $0 [all|canonical|trauma|www|stamp]" >&2
    exit 1
    ;;
esac
