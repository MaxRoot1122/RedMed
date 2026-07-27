# RedMed — Mac helpers

Mac-only launchers for building and running the **iPhone app** in Simulator.
Not a Mac product — these are dev shortcuts.

| File | What it does |
|------|----------------|
| **`ios/RedMed.app`** | Primary — double-click next to the Xcode project (symlink to `mac/RedMed.app`) |
| **`ios/RedMed.command`** | Same, with Terminal output |
| **`mac/RedMed.app`** | Mac bundle source (Finder app) |
| **`mac/RedMed.command`** | Mac terminal launcher (same behavior) |
| **`RedMed.command`** (repo root) | Thin wrapper → `ios/RedMed.command` |
| **`build/RedMed-Simulator.app`** | Signed iOS `.app` for drag-drop onto Simulator (created after first build) |
| **`mac/refresh-icon.command`** | Bust Finder/Dock icon cache after regenerating `AppIcon.icns` |

Run `./scripts/install-desktop-shortcut.sh` to stamp this clone, **build the iOS Simulator app**, and install shortcuts. Primary launcher: **`~/Desktop/RedMed.app`**. Extras in **`~/Desktop/RedMed/`**. Re-run after moving the repo.

NFC does **not** work in Simulator — use a physical iPhone (see [`ios/SETUP.md`](SETUP.md)).
