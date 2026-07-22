#!/bin/bash
# Double-click in Finder — starts localhost server and opens RedMed (no manual Terminal).
cd "$(dirname "$0")" || exit 1
source "./scripts/redmed-server.sh"
redmed_launch "$(pwd)"
