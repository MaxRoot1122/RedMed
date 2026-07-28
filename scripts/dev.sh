#!/bin/bash
# Dev helpers: clean local junk, compile-check iOS, verify hosted card/get pages.
# Usage: ./scripts/dev.sh [clean|build|verify|icons]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
CMD="${1:-clean}"

case "$CMD" in
  clean)
    cd "$ROOT"
    removed=0
    rm_rf() {
      local path="$1"
      if [ -e "$path" ] || [ -L "$path" ]; then
        rm -rf "$path"
        echo "removed: ${path#"$ROOT/"}"
        removed=$((removed + 1))
      fi
    }
    rm_rf build
    find . -name .DS_Store -delete
    rm_rf .claude
    rm_rf ios/RedMed.xcodeproj/project.xcworkspace/xcuserdata
    rm_rf ios/build
    rm_rf .vscode
    rm_rf buildServer.json
    for stray in \
      "RedMed Project" "RedMed Simulator.app" "RedMed iPhone.app" "RedMed.app" \
      "RedMed.xcodeproj" "RedMedOs.app" "Open in Cursor.command" "README.txt"
    do
      rm_rf "$stray"
    done
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git gc --prune=now --quiet 2>/dev/null && echo "git gc: pruned loose objects"
    fi
    echo "Done. Rebuild Simulator app: ./scripts/run-ios-simulator.sh"
    ;;
  build)
    PROJECT="$ROOT/ios/RedMed.xcodeproj"
    SCHEME="RedMed"
    CONFIG="${REDMED_IOS_CONFIG:-Release}"
    DEST="${REDMED_IOS_DEST:-generic/platform=iOS}"
    if ! command -v xcodebuild >/dev/null 2>&1; then
      echo "ERROR: xcodebuild not found. Install Xcode from the Mac App Store." >&2
      exit 1
    fi
    echo "==> RedMed iOS build ($CONFIG, $DEST)"
    xcodebuild \
      -project "$PROJECT" \
      -scheme "$SCHEME" \
      -destination "$DEST" \
      -configuration "$CONFIG" \
      CODE_SIGNING_ALLOWED=NO \
      build
    echo "Build succeeded."
    ;;
  verify)
    exec "$SCRIPT_DIR/verify-web.sh"
    ;;
  icons)
    exec "$SCRIPT_DIR/generate-icons.sh"
    ;;
  *)
    echo "Usage: $0 [clean|build|verify|icons]" >&2
    exit 1
    ;;
esac
