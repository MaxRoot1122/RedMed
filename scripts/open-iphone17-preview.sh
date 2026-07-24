#!/bin/bash
# Open RedMed iPhone 17 preview inside Cursor (Simple Browser panel).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${REDMED_PORT:-8934}"
HOST="${REDMED_HOST:-127.0.0.1}"
PREVIEW_URL="http://${HOST}:${PORT}/dev/iphone17-preview.html"
CURSOR_BIN="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"

cd "$ROOT"

# Serve repo root so /dev/iphone17-preview.html resolves (not the www mirror alone).
if ! curl -sf -o /dev/null "$PREVIEW_URL" 2>/dev/null; then
  echo "Starting RedMed dev server on ${HOST}:${PORT}..."
  python3 scripts/serve-local.py --root "$ROOT" &
  SERVER_PID=$!
  for _ in $(seq 1 40); do
    curl -sf -o /dev/null "$PREVIEW_URL" 2>/dev/null && break
    sleep 0.15
  done
  if ! curl -sf -o /dev/null "$PREVIEW_URL" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    echo "ERROR: dev server did not become ready at $PREVIEW_URL" >&2
    exit 1
  fi
  echo "Dev server running (pid $SERVER_PID)."
fi

ENCODED="$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PREVIEW_URL', safe=''))")"
URI="vscode://vscode.simple-browser/show?url=${ENCODED}"

echo "iPhone 17 preview: $PREVIEW_URL"
echo "Opening in Cursor Simple Browser..."

if [[ -x "$CURSOR_BIN" ]]; then
  "$CURSOR_BIN" --open-url "$URI" "$ROOT" 2>/dev/null || open "$URI" 2>/dev/null || true
else
  open "$URI" 2>/dev/null || true
fi

echo ""
echo "If the panel did not open: Cmd+Shift+P → Simple Browser: Show"
echo "Paste: $PREVIEW_URL"
echo "Drag the tab beside your editor for split design view."
