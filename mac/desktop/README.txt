RedMed — iOS build is the priority

GitHub: https://github.com/MaxRoot1122/RedMed
Clone:  git clone https://github.com/MaxRoot1122/RedMed.git
Setup:  ./scripts/setup-dev.sh --skip-build

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

That stamps your clone, builds for Simulator, and updates Desktop shortcuts.
Skip the build: ./scripts/install-desktop-shortcut.sh --skip-build
Build and launch:  ./scripts/install-desktop-shortcut.sh --launch
