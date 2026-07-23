#!/bin/bash
# Double-click in Finder — native iOS app in Simulator (same as RedMed.app).
cd "$(dirname "$0")" || exit 1
exec ./scripts/run-ios-simulator.sh
