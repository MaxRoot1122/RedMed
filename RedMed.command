#!/bin/bash
# Double-click in Finder — sync www mirror, start localhost, open RedMed (same bundle as RedMed.app).
cd "$(dirname "$0")" || exit 1
./scripts/sync-www-mirror.sh
source "./scripts/redmed-server.sh"
redmed_launch "$(pwd)/RedMed.app/Contents/Resources/www"
