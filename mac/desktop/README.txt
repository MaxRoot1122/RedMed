RedMed — iOS build is the priority

Primary shortcut (Desktop):
  ~/Desktop/RedMed.app   → builds and runs the native iPhone app in Simulator

Also in ~/Desktop/RedMed/:
  RedMed iPhone.app      → same launcher
  RedMed Simulator.app   → signed iOS .app for drag-drop onto Simulator
  RedMed.command         → launcher with Terminal output

Install or refresh from repo root:
  ./scripts/install-desktop-shortcut.sh

That stamps your clone, builds for Simulator, and updates Desktop shortcuts.
Skip the build: ./scripts/install-desktop-shortcut.sh --skip-build
Build and launch:  ./scripts/install-desktop-shortcut.sh --launch
