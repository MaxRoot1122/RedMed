#!/bin/bash
# Poll for iOS source edits and rebuild/relaunch the Simulator app.
# Usage: ./scripts/watch-ios-simulator.sh [interval_seconds]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INTERVAL="${1:-${REDMED_WATCH_INTERVAL:-8}}"
SCRIPT="$ROOT/scripts/run-ios-simulator.sh"
STAMP="$ROOT/build/.watch-ios-stamp"

mkdir -p "$ROOT/build"
touch "$STAMP"

echo "==> Watching ios/RedMed/*.swift every ${INTERVAL}s (Ctrl+C to stop)"

while true; do
  if find "$ROOT/ios/RedMed" -name '*.swift' -newer "$STAMP" -print -quit | grep -q . \
    || [ "$ROOT/ios/RedMed.xcodeproj/project.pbxproj" -nt "$STAMP" ]; then
    echo "==> Source change detected $(date '+%H:%M:%S')"
    if REDMED_IOS_FORCE_BUILD=1 "$SCRIPT"; then
      touch "$STAMP"
    else
      echo "==> Build failed — will retry on next change" >&2
    fi
  fi
  sleep "$INTERVAL"
done
