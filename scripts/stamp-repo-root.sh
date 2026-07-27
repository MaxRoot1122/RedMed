#!/bin/bash
# Stamp mac/ and ios/ RedMed.app with this machine's repo root (Desktop shortcuts, moved clones).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"

for PLIST in \
  "${REPO_ROOT}/mac/RedMed.app/Contents/Info.plist" \
  "${REPO_ROOT}/ios/RedMed.app/Contents/Info.plist"
do
  if [ ! -f "$PLIST" ]; then
    echo "Info.plist not found: ${PLIST}" >&2
    exit 1
  fi
  /usr/libexec/PlistBuddy -c "Set :RedMedRepoRoot ${REPO_ROOT}" "$PLIST"
  echo "RedMedRepoRoot → ${REPO_ROOT} (${PLIST#"$REPO_ROOT/"})"
done
