#!/bin/bash
# Double-click in Finder — opens Terminal and runs the native iOS app (easiest way to see errors).
cd "$(dirname "$0")" || exit 1
LOG="${HOME}/Library/Logs/RedMed/launch.log"
mkdir -p "$(dirname "$LOG")"
echo "=== $(date '+%Y-%m-%d %H:%M:%S') RedMed.command ===" >> "$LOG"
echo "Launching native RedMed in iOS Simulator..."
echo "(Log: $LOG)"
echo ""
if ./scripts/run-ios-simulator.sh 2>&1 | tee -a "$LOG"; then
  echo ""
  echo "RedMed is running in Simulator."
else
  echo ""
  echo "Launch failed. See: $LOG"
  read -r -p "Press Enter to close…"
  exit 1
fi
