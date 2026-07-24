#!/bin/bash
# Mirror the booted Xcode simulator into Cursor's Simple Browser panel.
set -euo pipefail

SIM_UDID="${REDMED_SIM_UDID:-19E727CE-3724-428C-89B6-2EFBFFE8AD88}"
PORT="${REDMED_SIM_STREAM_PORT:-3200}"
HOST="${REDMED_SIM_STREAM_HOST:-127.0.0.1}"
PREVIEW_URL="http://${HOST}:${PORT}/"
CURSOR_BIN="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"

if ! command -v serve-sim >/dev/null 2>&1; then
  echo "Installing serve-sim..."
  npm install -g serve-sim
fi

# Boot target sim if needed (reuse Xcode's booted device when possible).
xcrun simctl boot "$SIM_UDID" 2>/dev/null || true

if ! curl -sf -o /dev/null "$PREVIEW_URL" 2>/dev/null; then
  echo "Starting simulator stream on ${PREVIEW_URL} ..."
  nohup serve-sim --host "$HOST" --port "$PORT" --fit "$SIM_UDID" >/tmp/redmed-serve-sim.log 2>&1 &
  for _ in $(seq 1 50); do
    curl -sf -o /dev/null "$PREVIEW_URL" 2>/dev/null && break
    sleep 0.2
  done
fi

if ! curl -sf -o /dev/null "$PREVIEW_URL" 2>/dev/null; then
  echo "ERROR: serve-sim did not start. See /tmp/redmed-serve-sim.log" >&2
  exit 1
fi

ENCODED="$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PREVIEW_URL', safe=''))")"
URI="vscode://vscode.simple-browser/show?url=${ENCODED}"

echo "Live sim stream: $PREVIEW_URL"
echo "Opening inside Cursor..."

if [[ -x "$CURSOR_BIN" ]]; then
  "$CURSOR_BIN" --open-url "$URI" 2>/dev/null || open "$URI" 2>/dev/null || true
else
  open "$URI" 2>/dev/null || true
fi

echo ""
echo "Drag the Simple Browser tab beside your Swift editor."
echo "You can minimize the external Simulator.app — this stream is the same device."
echo "Rebuild: Cmd+Shift+B (SweetPad: Launch RedMed on iPhone 17)"
