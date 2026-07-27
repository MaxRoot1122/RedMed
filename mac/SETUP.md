# RedMed — Mac helpers

Mac-only launchers for building and running the **iPhone app** in Simulator.
Not a Mac product — these are dev shortcuts.

## One clone on this Mac

Keep a **single** git clone at `~/RedMed`. `~/Desktop/RedMed/` is only a hub of aliases (not a second copy).

```bash
# First time / cleanup duplicate Desktop clone + pull + Desktop shortcuts:
curl -fsSL https://raw.githubusercontent.com/MaxRoot1122/RedMed/main/scripts/setup-local-mac.sh | bash

# Or from inside the clone:
cd ~/RedMed && ./scripts/setup-local-mac.sh
```


| File | What it does |
|------|----------------|
| **`ios/RedMed.app`** | Primary — double-click next to the Xcode project (symlink to `mac/RedMed.app`) |
| **`ios/RedMed.command`** | Same, with Terminal output |
| **`mac/RedMed.app`** | Mac bundle source (Finder app) |
| **`mac/RedMed.command`** | Mac terminal launcher (same behavior) |
| **`RedMed.command`** (repo root) | Thin wrapper → `ios/RedMed.command` |
| **`build/RedMed-Simulator.app`** | Signed iOS `.app` for drag-drop onto Simulator (created after first build) |
| **`mac/refresh-icon.command`** | Bust Finder/Dock icon cache after regenerating `AppIcon.icns` |

Run `./scripts/setup-dev.sh --skip-build` after cloning, or `./scripts/install-desktop-shortcut.sh` to refresh Desktop aliases. Hub: **`~/Desktop/RedMed/`** (`RedMed Project`, **Open in Cursor.command**, **RedMed.xcodeproj**). Simulator: **`~/Desktop/RedMed.app`**. Re-run after moving the repo.

NFC does **not** work in Simulator — use a physical iPhone (see [`ios/SETUP.md`](SETUP.md)).
