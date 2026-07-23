#!/bin/bash
# Build RedMed and run it in the iOS Simulator, end to end.
# Boots a simulator if needed, builds, installs, and launches the app.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/ios/RedMed.xcodeproj"
SCHEME="RedMed"
DEVICE_NAME="${REDMED_SIM_DEVICE:-iPhone 17 Pro}"
BUNDLE_ID="local.redmed.app"
# Must live outside iCloud Drive — iCloud adds resource-fork metadata that
# breaks codesign ("resource fork, Finder information, or similar detritus
# not allowed").
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData/RedMed-sim"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERROR: xcodebuild not found. Install Xcode from the Mac App Store."
  exit 1
fi

if ! xcodebuild -version >/dev/null 2>&1; then
  echo "ERROR: Full Xcode is required (Command Line Tools alone are not enough)."
  echo "Run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

if [ ! -f "$ROOT/ios/RedMed/google-api-key" ]; then
  echo "# No Google Maps API key configured locally." > "$ROOT/ios/RedMed/google-api-key"
fi

UDID="$(xcrun simctl list devices available | grep "$DEVICE_NAME (" | grep -oE '[0-9A-F-]{36}' | head -1)"
if [ -z "$UDID" ]; then
  echo "ERROR: No available simulator matching \"$DEVICE_NAME\". List options with: xcrun simctl list devices available"
  exit 1
fi

STATE="$(xcrun simctl list devices | grep "$UDID" | grep -oE '\(Booted\)|\(Shutdown\)' || true)"
if [ "$STATE" != "(Booted)" ]; then
  echo "==> Booting $DEVICE_NAME ($UDID)"
  xcrun simctl boot "$UDID"
fi
open -a Simulator --args -CurrentDeviceUDID "$UDID"

echo "==> Building RedMed for simulator"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "id=$UDID" \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA" \
  build

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/RedMed.app"
if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: Build succeeded but app bundle not found at $APP_PATH"
  exit 1
fi

echo "==> Installing on $DEVICE_NAME"
xcrun simctl install "$UDID" "$APP_PATH"

echo "==> Launching RedMed"
xcrun simctl launch "$UDID" "$BUNDLE_ID"

echo ""
echo "RedMed is running in Simulator. NFC does not work in Simulator — use a physical iPhone for tag read/write."
