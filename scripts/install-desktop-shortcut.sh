#!/bin/bash
# Install Mac launcher shortcuts on Desktop. iOS Simulator build is the priority.
# Safe to re-run — refreshes shortcuts after moving the repo or updating the bundle.
#
# Also installs an edit hub (repo alias, Xcode, Cursor) — aliases track this git
# clone; nothing is copied.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"

"${SCRIPT_DIR}/sync.sh" stamp >/dev/null
DESKTOP="${HOME}/Desktop"
DESKTOP_DIR="${DESKTOP}/RedMed"
APP_SRC="${REPO_ROOT}/ios/RedMed.app"
APP_REAL="${REPO_ROOT}/mac/RedMed.app"
XCODE_PROJ="${REPO_ROOT}/ios/RedMed.xcodeproj"
WORKSPACE="${REPO_ROOT}/RedMed.code-workspace"
PRIMARY_DST="${DESKTOP}/RedMed.app"
PROJECT_ALIAS="${DESKTOP_DIR}/RedMed Project"
XCODE_ALIAS="${DESKTOP_DIR}/RedMed.xcodeproj"
CURSOR_CMD="${DESKTOP_DIR}/Open in Cursor.command"
APP_DST="${DESKTOP_DIR}/RedMed iPhone.app"
SIM_SRC="${REPO_ROOT}/build/RedMed-Simulator.app"
SIM_DST="${DESKTOP_DIR}/RedMed Simulator.app"
CMD_SRC="${REPO_ROOT}/ios/RedMed.command"
CMD_DST="${DESKTOP_DIR}/RedMed.command"
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

# Edit hub — aliases to this git clone (changes stay live).
alias_app "$REPO_ROOT" "$PROJECT_ALIAS"
log "Edit folder: ${PROJECT_ALIAS} → ${REPO_ROOT}"

if [ -d "$XCODE_PROJ" ]; then
  alias_app "$XCODE_PROJ" "$XCODE_ALIAS"
  log "Xcode: ${XCODE_ALIAS} → ${XCODE_PROJ}"
fi

cat > "$CURSOR_CMD" <<EOF
#!/bin/bash
exec open -a Cursor "${WORKSPACE}" 2>/dev/null || cursor "${WORKSPACE}" 2>/dev/null || open "${REPO_ROOT}"
EOF
chmod +x "$CURSOR_CMD"
log "Cursor: ${CURSOR_CMD}"

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

GIT_REMOTE="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || echo "https://github.com/MaxRoot1122/RedMed.git")"
{
  cat <<'DESKTOP_README'
RedMed — iOS build is the priority

GitHub: https://github.com/MaxRoot1122/RedMed
Clone:  git clone https://github.com/MaxRoot1122/RedMed.git
Setup:  ./scripts/setup.sh --skip-build

Primary shortcut (Desktop):
  ~/Desktop/RedMed.app   → builds and runs the native iPhone app in Simulator

Also in ~/Desktop/RedMed/ (Finder aliases — point at your clone, not copies):
  RedMed Project         → whole repo (edit here)
  RedMed.xcodeproj       → open in Xcode
  Open in Cursor.command → open RedMed.code-workspace in Cursor
  RedMed iPhone.app      → same Simulator launcher
  RedMed Simulator.app   → signed iOS .app for drag-drop onto Simulator
  RedMed.command         → launcher with Terminal output

Install or refresh from repo root:
  ./scripts/install-desktop-shortcut.sh

DESKTOP_README
  echo ""
  echo "This clone:"
  echo "  ${REPO_ROOT}"
  echo "  ${GIT_REMOTE}"
} > "$README_DST"
log "Desktop readme: ${README_DST}"

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

# Cursor used to open ~/Desktop/Glint/RedMed — keep that path as a symlink to this clone.
GLINT_LINK="${HOME}/Desktop/Glint/RedMed"
mkdir -p "$(dirname "$GLINT_LINK")"
remove_desktop_item "$GLINT_LINK"
ln -sf "$REPO_ROOT" "$GLINT_LINK"
log "Cursor path: ${GLINT_LINK} → ${REPO_ROOT}"

log "Done. Double-click ~/Desktop/RedMed.app to build and run on iPhone Simulator."
