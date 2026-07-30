#!/bin/bash
REPO_ROOT="$(cd "$(dirname "$0")" && pwd -P)"
exec "${REPO_ROOT}/ios/RedMed.command"
