@echo off
REM Double-click on Windows — local server + browser (same as RedMed.command on Mac).
cd /d "%~dp0"
python scripts\serve-local.py --open
