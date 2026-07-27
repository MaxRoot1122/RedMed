#!/bin/bash
# Build (if needed) and stage build/RedMed-Simulator.app for drag-drop onto Simulator.
# Does not launch — use run-ios-simulator.sh to build, stage, install, and run.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export REDMED_IOS_FORCE_BUILD="${REDMED_IOS_FORCE_BUILD:-0}"

# run-ios-simulator.sh stages to build/RedMed-Simulator.app; skip launch via env.
REDMED_STAGE_ONLY=1 bash "$ROOT/scripts/run-ios-simulator.sh"
