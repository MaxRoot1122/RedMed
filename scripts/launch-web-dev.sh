#!/bin/bash
# Optional: localhost web app for Web NFC / browser testing only — not the Mac product launcher.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/sync-www-mirror.sh"
# shellcheck source=/dev/null
source "$ROOT/scripts/redmed-server.sh"
redmed_launch "$ROOT/RedMed.app/Contents/Resources/www"
