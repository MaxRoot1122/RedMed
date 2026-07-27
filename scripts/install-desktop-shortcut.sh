#!/bin/bash
# Symlink RedMed.app (and a Desktop RedMed.command wrapper) to ~/Desktop.
# Safe to re-run — refreshes shortcuts after moving the repo or updating the bundle.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
DESKTOP="${HOME}/Desktop"
APP_SRC="${REPO_ROOT}/RedMed.app"
APP_DST="${DESKTOP}/RedMed.app"
SIM_SRC="${REPO_ROOT}/build/RedMed-Simulator.app"
SIM_DST="${DESKTOP}/RedMed Simulator.app"
CMD_SRC="${REPO_ROOT}/RedMed.command"
CMD_DST="${DESKTOP}/RedMed.command"
QUIET=0

for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=1 ;;
  esac
done

log() {
  [ "$QUIET" -eq 1 ] || echo "$*"
}

if [ ! -d "$APP_SRC" ]; then
  echo "RedMed.app not found at ${APP_SRC}" >&2
  exit 1
fi

mkdir -p "$DESKTOP"

if [ -e "$APP_DST" ] || [ -L "$APP_DST" ]; then
  rm -rf "$APP_DST"
fi
ln -sf "$APP_SRC" "$APP_DST"
log "Desktop app: ${APP_DST} → ${APP_SRC} (Mac launcher — double-click to build & run)"

if [ -d "$SIM_SRC" ]; then
  if [ -e "$SIM_DST" ] || [ -L "$SIM_DST" ]; then
    rm -rf "$SIM_DST"
  fi
  ln -sf "$SIM_SRC" "$SIM_DST"
  log "Simulator drag-drop: ${SIM_DST} → ${SIM_SRC}"
else
  log "Tip: run ./scripts/run-ios-simulator.sh once to create build/RedMed-Simulator.app for drag-drop."
fi

if [ -f "$CMD_SRC" ]; then
  cat > "$CMD_DST" <<EOF
#!/bin/bash
# Opens RedMed from your Desktop — delegates to the repo launcher.
exec "${CMD_SRC}"
EOF
  chmod +x "$CMD_DST"
  log "Desktop command: ${CMD_DST}"
fi

log "Done. Double-click RedMed on your Desktop to launch."
