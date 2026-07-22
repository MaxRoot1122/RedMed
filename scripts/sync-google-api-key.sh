#!/usr/bin/env bash
# Copy local Google API key into iOS bundle resource (dev builds only).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/config/google-api-key"
DST="$ROOT/ios/RedMed/google-api-key"
if [ ! -f "$SRC" ]; then
  echo "No $SRC — copy config/google-api-key.example and add your key." >&2
  exit 1
fi
cp "$SRC" "$DST"
echo "google-api-key copied to ios/RedMed/ (gitignored)."
