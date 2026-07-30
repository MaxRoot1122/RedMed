#!/bin/bash
# iPhone Simulator launcher — lives next to the Xcode project.
cd "$(dirname "$0")/.." || exit 1
LOG="${HOME}/Library/Logs/RedMed/launch.log"
mkdir -p "$(dirname "$LOG")"
echo "=== $(date '+%Y-%m-%d %H:%M:%S') ios/RedMed.command ===" >> "$LOG"
echo "Launching RedMed on iPhone Simulator..."
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
