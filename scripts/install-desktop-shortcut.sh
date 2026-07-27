#!/bin/bash
# Install Mac launcher shortcuts on Desktop. iOS Simulator build is the priority.
# Safe to re-run — refreshes shortcuts after moving the repo or updating the bundle.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"

"${SCRIPT_DIR}/stamp-repo-root.sh" >/dev/null
DESKTOP="${HOME}/Desktop"
DESKTOP_DIR="${DESKTOP}/RedMed"
APP_SRC="${REPO_ROOT}/ios/RedMed.app"
APP_REAL="${REPO_ROOT}/mac/RedMed.app"
PRIMARY_DST="${DESKTOP}/RedMed.app"
APP_DST="${DESKTOP_DIR}/RedMed iPhone.app"
SIM_SRC="${REPO_ROOT}/build/RedMed-Simulator.app"
SIM_DST="${DESKTOP_DIR}/RedMed Simulator.app"
CMD_SRC="${REPO_ROOT}/ios/RedMed.command"
CMD_DST="${DESKTOP_DIR}/RedMed.command"
README_SRC="${REPO_ROOT}/mac/desktop/README.txt"
README_DST="${DESKTOP_DIR}/README.txt"
QUIET=0
SKIP_BUILD=0
LAUNCH_AFTER_BUILD=0

for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=1 ;;
    --skip-build) SKIP_BUILD=1 ;;
    --launch) LAUNCH_AFTER_BUILD=1 ;;
  esac
done

log() {
  [ "$QUIET" -eq 1 ] || echo "$*"
}

remove_desktop_item() {
  local path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    rm -rf "$path"
  fi
}

# Finder alias — shows the real .app icon (symlinks often look generic on Desktop).
alias_app() {
  local src="$1"
  local dst="$2"
  local folder name
  folder="$(dirname "$dst")"
  name="$(basename "$dst")"
  mkdir -p "$folder"
  remove_desktop_item "$dst"
  osascript - "$src" "$folder" "$name" <<'APPLESCRIPT'
on run argv
  set srcPath to item 1 of argv
  set folderPath to item 2 of argv
  set itemName to item 3 of argv
  tell application "Finder"
    set targetItem to POSIX file srcPath as alias
    set destFolder to POSIX file folderPath as alias
    make new alias file at destFolder to targetItem with properties {name:itemName}
  end tell
end run
APPLESCRIPT
}

refresh_app_icon() {
  local app="$1"
  [ -d "$app" ] || return 0
  touch "$app" "$app/Contents/Info.plist" "$app/Contents/Resources/AppIcon.icns" 2>/dev/null || true
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app" 2>/dev/null || true
}

if [ ! -d "$APP_SRC" ]; then
  echo "ios/RedMed.app not found at ${APP_SRC}" >&2
  exit 1
fi

mkdir -p "$DESKTOP_DIR"

for stale in \
  "${DESKTOP}/RedMed iPhone.app" \
  "${DESKTOP}/RedMed Simulator.app" \
  "${DESKTOP}/RedMed.command"
do
  remove_desktop_item "$stale"
  log "Removed old Desktop shortcut: ${stale}"
done

alias_app "$APP_SRC" "$PRIMARY_DST"
log "Primary (Desktop): ${PRIMARY_DST} → ${APP_SRC}"

alias_app "$APP_SRC" "$APP_DST"
log "Desktop app: ${APP_DST} → ${APP_SRC}"

if [ -f "$CMD_SRC" ]; then
  cat > "$CMD_DST" <<EOF
#!/bin/bash
exec "${CMD_SRC}"
EOF
  chmod +x "$CMD_DST"
  log "Desktop command: ${CMD_DST}"
fi

if [ -f "$README_SRC" ]; then
  cp "$README_SRC" "$README_DST"
  log "Desktop readme: ${README_DST}"
fi

if [ "$SKIP_BUILD" -eq 0 ] && command -v xcodebuild >/dev/null 2>&1; then
  log "Building iOS app for Simulator (priority)..."
  if [ "$LAUNCH_AFTER_BUILD" -eq 1 ]; then
    bash "${REPO_ROOT}/scripts/run-ios-simulator.sh"
  else
    REDMED_STAGE_ONLY=1 bash "${REPO_ROOT}/scripts/run-ios-simulator.sh"
  fi
elif [ "$SKIP_BUILD" -eq 0 ]; then
  log "Tip: install Xcode, then re-run to build the iOS Simulator app."
fi

if [ -d "$SIM_SRC" ]; then
  alias_app "$SIM_SRC" "$SIM_DST"
  log "Simulator drag-drop: ${SIM_DST} → ${SIM_SRC}"
else
  log "Tip: run ./scripts/run-ios-simulator.sh once to create build/RedMed-Simulator.app"
fi

refresh_app_icon "$APP_REAL"
log "Refreshed launcher icon (AppIcon.icns)."

log "Done. Double-click ~/Desktop/RedMed.app to build and run on iPhone Simulator."
