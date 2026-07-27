#!/bin/bash
# First-time setup after cloning https://github.com/MaxRoot1122/RedMed
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
cd "$ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repo at: $ROOT" >&2
  echo "" >&2
  echo "Clone GitHub, then run setup from inside the clone:" >&2
  echo "  git clone https://github.com/MaxRoot1122/RedMed.git ~/RedMed" >&2
  echo "  cd ~/RedMed && ./scripts/setup-dev.sh --skip-build" >&2
  echo "" >&2
  echo "If Cursor says 'not a git repo', you opened the wrong folder." >&2
  echo "Open: ~/RedMed  or  ~/Desktop/RedMed/RedMed Project" >&2
  exit 1
fi

ORIGIN="$(git remote get-url origin 2>/dev/null || true)"
if [ -z "$ORIGIN" ]; then
  git remote add origin https://github.com/MaxRoot1122/RedMed.git 2>/dev/null || true
  ORIGIN="$(git remote get-url origin 2>/dev/null || echo https://github.com/MaxRoot1122/RedMed.git)"
fi

echo "Repo:   $ROOT"
echo "Remote: $ORIGIN"
echo ""

SKIP_BUILD=1
for arg in "$@"; do
  case "$arg" in
    --build) SKIP_BUILD=0 ;;
    --skip-build) SKIP_BUILD=1 ;;
    --launch) SKIP_BUILD=0; LAUNCH=1 ;;
  esac
done

if [ "${LAUNCH:-0}" = "1" ]; then
  "$ROOT/scripts/install-desktop-shortcut.sh" --launch
elif [ "$SKIP_BUILD" -eq 1 ]; then
  "$ROOT/scripts/install-desktop-shortcut.sh" --skip-build
else
  "$ROOT/scripts/install-desktop-shortcut.sh"
fi

echo ""
echo "Edit in Cursor: open $ROOT/RedMed.code-workspace"
echo "Desktop hub:    ~/Desktop/RedMed/"
