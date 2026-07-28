#!/bin/bash
# RedMed setup — clone check, Desktop hub, optional Simulator build.
# Usage: ./scripts/setup.sh [--local] [--skip-build|--build|--launch]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
LOCAL=0
SKIP_BUILD=1
LAUNCH=0

for arg in "$@"; do
  case "$arg" in
    --local) LOCAL=1 ;;
    --build) SKIP_BUILD=0 ;;
    --skip-build) SKIP_BUILD=1 ;;
    --launch) SKIP_BUILD=0; LAUNCH=1 ;;
  esac
done

is_git_repo() {
  local d="$1"
  [ -d "$d/.git" ] || git -C "$d" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

run_local_mac_setup() {
  local repo_url="${REDMED_GIT_URL:-https://github.com/MaxRoot1122/RedMed.git}"
  local home_repo="${REDMED_HOME:-$HOME/RedMed}"
  local desk_path="${HOME}/Desktop/RedMed"

  echo "==> RedMed local Mac setup"
  echo "    Canonical clone: ${home_repo}"
  echo ""

  if [ ! -d "$home_repo/.git" ]; then
    if [ -L "$desk_path" ] && is_git_repo "$(readlink "$desk_path" 2>/dev/null || true)"; then
      echo "Desktop/RedMed is a symlink — using its target as the clone."
      home_repo="$(cd "$(readlink "$desk_path")" && pwd -P)"
    elif is_git_repo "$desk_path"; then
      echo "Moving Desktop git clone → ${home_repo}"
      if [ -e "$home_repo" ] || [ -L "$home_repo" ]; then
        echo "ERROR: ${home_repo} already exists. Remove or rename it, then re-run." >&2
        exit 1
      fi
      mv "$desk_path" "$home_repo"
    else
      echo "Cloning ${repo_url} → ${home_repo}"
      git clone "$repo_url" "$home_repo"
    fi
  fi

  cd "$home_repo"
  git remote set-url origin "$repo_url" 2>/dev/null || git remote add origin "$repo_url"
  git fetch origin main
  git checkout main
  git pull --ff-only origin main || git pull origin main
  echo "Tip: $(git log -1 --oneline)"
  echo ""

  if [ -L "$desk_path" ]; then
    target="$(readlink "$desk_path" || true)"
    echo "Removing Desktop/RedMed symlink → ${target}"
    rm -f "$desk_path"
  elif [ -d "$desk_path/.git" ]; then
    local h d hp dp
    h="$(git -C "$home_repo" rev-parse HEAD)"
    d="$(git -C "$desk_path" rev-parse HEAD)"
    hp="$(cd "$home_repo" && pwd -P)"
    dp="$(cd "$desk_path" && pwd -P)"
    if [ "$hp" = "$dp" ]; then
      echo "Desktop/RedMed is the same directory as home — leaving path; shortcuts will refresh."
    elif [ "$h" = "$d" ]; then
      echo "Desktop/RedMed is a duplicate clone (same commit ${h:0:7}) — deleting it."
      rm -rf "$desk_path"
    else
      echo "WARNING: Desktop/RedMed is a different clone (${d:0:7} vs ${h:0:7})." >&2
      echo "         Not deleting. Merge or delete manually, then re-run." >&2
    fi
  fi

  ROOT="$home_repo"
  SCRIPT_DIR="${ROOT}/scripts"
  cd "$ROOT"
  chmod +x scripts/*.sh ios/RedMed.command 2>/dev/null || true
}

if [ "$LOCAL" -eq 1 ]; then
  run_local_mac_setup
fi

cd "$ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repo at: $ROOT" >&2
  echo "" >&2
  echo "Clone GitHub, then run setup from inside the clone:" >&2
  echo "  git clone https://github.com/MaxRoot1122/RedMed.git ~/RedMed" >&2
  echo "  cd ~/RedMed && ./scripts/setup.sh --skip-build" >&2
  echo "" >&2
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

if [ "$LAUNCH" -eq 1 ]; then
  "$ROOT/scripts/install-desktop-shortcut.sh" --launch
elif [ "$SKIP_BUILD" -eq 1 ]; then
  "$ROOT/scripts/install-desktop-shortcut.sh" --skip-build
else
  "$ROOT/scripts/install-desktop-shortcut.sh"
fi

echo ""
echo "Edit in Cursor: open $ROOT/RedMed.code-workspace"
echo "Desktop hub:    ~/Desktop/RedMed/"
if [ "$LOCAL" -eq 1 ]; then
  echo ""
  echo "Done — all local."
  echo "  Clone:     $ROOT"
  echo "  Simulator: ~/Desktop/RedMed.app"
  echo "  Xcode:     open $ROOT/ios/RedMed.xcodeproj"
fi
