#!/bin/bash
# One-shot local Mac setup: single clone at ~/RedMed, Desktop hub (aliases only), pull main.
# Run ON the Mac mini (cloud agents cannot reach your Mac):
#   curl -fsSL https://raw.githubusercontent.com/MaxRoot1122/RedMed/main/scripts/setup-local-mac.sh | bash
# Or from an existing clone:
#   ./scripts/setup-local-mac.sh
set -euo pipefail

REPO_URL="${REDMED_GIT_URL:-https://github.com/MaxRoot1122/RedMed.git}"
HOME_REPO="${REDMED_HOME:-$HOME/RedMed}"
DESK_PATH="${HOME}/Desktop/RedMed"

is_git_repo() {
  local d="$1"
  [ -d "$d/.git" ] || git -C "$d" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

echo "==> RedMed local Mac setup"
echo "    Canonical clone: ${HOME_REPO}"
echo ""

# Prefer running from an existing clone if this script lives inside one.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P || true)"
if [ -n "${SCRIPT_DIR}" ] && [ -f "${SCRIPT_DIR}/../ios/RedMed.xcodeproj/project.pbxproj" ]; then
  FROM_CLONE="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
else
  FROM_CLONE=""
fi

# Resolve / create HOME_REPO
if [ -n "$FROM_CLONE" ]; then
  if [ "$FROM_CLONE" != "$(cd "$HOME_REPO" 2>/dev/null && pwd -P || true)" ]; then
    # Script ran from a clone that isn't ~/RedMed — keep that clone if ~/RedMed missing
    if [ ! -d "$HOME_REPO/.git" ]; then
      echo "Using existing clone as home: $FROM_CLONE"
      if [ "$FROM_CLONE" != "$HOME_REPO" ]; then
        if [ -e "$HOME_REPO" ] || [ -L "$HOME_REPO" ]; then
          echo "ERROR: ${HOME_REPO} exists but is not a git clone. Move it aside and re-run." >&2
          exit 1
        fi
        ln -s "$FROM_CLONE" "$HOME_REPO" 2>/dev/null || {
          echo "Clone is at ${FROM_CLONE}"
          echo "Recommended: mv \"${FROM_CLONE}\" \"${HOME_REPO}\""
          HOME_REPO="$FROM_CLONE"
        }
      fi
    fi
  fi
fi

if [ ! -d "$HOME_REPO/.git" ]; then
  if [ -L "$DESK_PATH" ] && is_git_repo "$(readlink "$DESK_PATH" 2>/dev/null || true)"; then
    echo "Desktop/RedMed is a symlink — using its target as the clone."
    HOME_REPO="$(cd "$(readlink "$DESK_PATH")" && pwd -P)"
  elif is_git_repo "$DESK_PATH"; then
    echo "Moving Desktop git clone → ${HOME_REPO}"
    if [ -e "$HOME_REPO" ] || [ -L "$HOME_REPO" ]; then
      echo "ERROR: ${HOME_REPO} already exists. Remove or rename it, then re-run." >&2
      exit 1
    fi
    mv "$DESK_PATH" "$HOME_REPO"
  else
    echo "Cloning ${REPO_URL} → ${HOME_REPO}"
    git clone "$REPO_URL" "$HOME_REPO"
  fi
fi

cd "$HOME_REPO"
echo "Repo: $(pwd -P)"
git remote set-url origin "$REPO_URL" 2>/dev/null || git remote add origin "$REPO_URL"
git fetch origin main
git checkout main
git pull --ff-only origin main || git pull origin main
echo "Tip: $(git log -1 --oneline)"
echo ""

# Remove a *second full clone* on Desktop (has .git). Keep Desktop/RedMed hub (aliases only).
if [ -L "$DESK_PATH" ]; then
  target="$(readlink "$DESK_PATH" || true)"
  echo "Removing Desktop/RedMed symlink → ${target}"
  rm -f "$DESK_PATH"
elif [ -d "$DESK_PATH/.git" ]; then
  H="$(git -C "$HOME_REPO" rev-parse HEAD)"
  D="$(git -C "$DESK_PATH" rev-parse HEAD)"
  HP="$(cd "$HOME_REPO" && pwd -P)"
  DP="$(cd "$DESK_PATH" && pwd -P)"
  if [ "$HP" = "$DP" ]; then
    echo "Desktop/RedMed is the same directory as home — leaving path; shortcuts will refresh."
  elif [ "$H" = "$D" ]; then
    echo "Desktop/RedMed is a duplicate clone (same commit ${H:0:7}) — deleting it."
    rm -rf "$DESK_PATH"
  else
    echo "WARNING: Desktop/RedMed is a different clone (${D:0:7} vs ${H:0:7})." >&2
    echo "         Not deleting. Merge or delete manually, then re-run." >&2
    echo "         Home kept: ${HOME_REPO}" >&2
  fi
elif [ -d "$DESK_PATH" ] && [ ! -e "$DESK_PATH/RedMed Project" ] && [ ! -f "$DESK_PATH/README.txt" ]; then
  # Unknown Desktop/RedMed folder that isn't a hub and isn't git — leave it
  echo "Note: ${DESK_PATH} exists but isn't a git clone or known hub — leaving it alone."
fi

echo ""
echo "==> Installing Desktop hub (aliases → ${HOME_REPO}, not a second copy)"
chmod +x scripts/*.sh ios/RedMed.command mac/RedMed.command 2>/dev/null || true
./scripts/setup-dev.sh --skip-build

echo ""
echo "Done — all local."
echo "  Clone:     ${HOME_REPO}"
echo "  Desktop:   ~/Desktop/RedMed/  (hub aliases only)"
echo "  Simulator: ~/Desktop/RedMed.app"
echo "  Xcode:     open ${HOME_REPO}/ios/RedMed.xcodeproj"
echo "  Device:    plug in iPhone (iOS 27+) → Signing → ⌘R"
echo ""
echo "Open Cursor on: ${HOME_REPO}/RedMed.code-workspace"
