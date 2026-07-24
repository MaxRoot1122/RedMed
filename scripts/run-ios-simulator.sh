#!/bin/bash
# Build (if needed) and run the native RedMed iOS app in Simulator.
# RedMed.app on Mac calls this — not the web index.html launcher.
#
# IMPORTANT: DerivedData is built OUTSIDE iCloud Drive on purpose.
# This repo lives in ~/Library/Mobile Documents/com~apple~CloudDocs (iCloud).
# If the .app is built/installed from inside iCloud, iCloud evicts the files
# to dataless placeholders and the Simulator fails with
# "Failed to re-fetch bundle during preflight". Keep builds local.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/ios/RedMed.xcodeproj"
SCHEME="RedMed"
CONFIG="${REDMED_IOS_CONFIG:-Debug}"

# Local, NON-iCloud DerivedData location.
DERIVED="${REDMED_DERIVED_DATA:-$HOME/Library/Developer/Xcode/DerivedData/RedMed-local}"
APP="$DERIVED/Build/Products/${CONFIG}-iphonesimulator/RedMed.app"
# Preferred device name; if it isn't installed, we fall back to any iPhone,
# then any available iOS simulator. Override with REDMED_SIM_DEVICE.
DEVICE_NAME="${REDMED_SIM_DEVICE:-iPhone 17}"
BUNDLE_ID="local.redmed.app"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERROR: xcodebuild not found. Install Xcode from the Mac App Store." >&2
  exit 1
fi

# Resolve a usable simulator on ANY machine. Preference order:
#   1. An already-booted iOS simulator (use what's open)
#   2. The requested DEVICE_NAME (newest runtime it exists on)
#   3. Any available iPhone (newest runtime)
#   4. Any available iOS simulator (newest runtime)
# Prints: "<udid>\t<name>\t<runtime-id>"
RESOLVED="$(xcrun simctl list devices available -j | python3 -c "
import json, sys
want = sys.argv[1]
data = json.load(sys.stdin).get('devices', {})

def ver(rt):
    # 'com.apple.CoreSimulator.SimRuntime.iOS-26-5' -> (26, 5)
    tail = rt.rsplit('.iOS-', 1)[-1]
    parts = []
    for p in tail.split('-'):
        try: parts.append(int(p))
        except ValueError: pass
    return tuple(parts)

# Only iOS runtimes, newest first.
runtimes = sorted((rt for rt in data if '.iOS-' in rt), key=ver, reverse=True)
avail = {rt: [d for d in data[rt] if d.get('isAvailable')] for rt in runtimes}

# 1. already booted
for rt in runtimes:
    for d in avail[rt]:
        if d.get('state') == 'Booted':
            print(f\"{d['udid']}\t{d['name']}\t{rt}\"); sys.exit(0)
# 2. requested name
for rt in runtimes:
    for d in avail[rt]:
        if d['name'] == want:
            print(f\"{d['udid']}\t{d['name']}\t{rt}\"); sys.exit(0)
# 3. any iPhone
for rt in runtimes:
    for d in avail[rt]:
        if d['name'].startswith('iPhone'):
            print(f\"{d['udid']}\t{d['name']}\t{rt}\"); sys.exit(0)
# 4. anything
for rt in runtimes:
    if avail[rt]:
        d = avail[rt][0]
        print(f\"{d['udid']}\t{d['name']}\t{rt}\"); sys.exit(0)
sys.exit('ERROR: No available iOS Simulator found. Open Xcode > Settings > Components and install an iOS runtime, or create a simulator in Xcode > Window > Devices and Simulators.')
" "$DEVICE_NAME")"

DEVICE_ID="$(printf '%s' "$RESOLVED" | cut -f1)"
DEVICE_NAME="$(printf '%s' "$RESOLVED" | cut -f2)"
echo "==> Using simulator: $DEVICE_NAME ($DEVICE_ID)"

need_build=1
if [ -d "$APP" ] && [ "${REDMED_IOS_FORCE_BUILD:-0}" != "1" ]; then
  need_build=0
fi

if [ "$need_build" -eq 1 ]; then
  echo "==> Building RedMed for iOS Simulator ($CONFIG) -> $DERIVED"
  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -configuration "$CONFIG" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=YES \
    -derivedDataPath "$DERIVED" \
    build
else
  echo "==> Using existing Simulator build ($APP)"
fi

# Ad-hoc sign the bundle so iOS 26 Simulators accept the install.
if [ ! -d "$APP/_CodeSignature" ]; then
  echo "==> Ad-hoc signing bundle"
  codesign --force --sign - --timestamp=none "$APP" || true
fi

# Install from a fully materialized copy in /tmp (guaranteed off iCloud).
STAGE="$(mktemp -d /tmp/redmed-stage.XXXXXX)"
cp -R "$APP" "$STAGE/RedMed.app"
STAGED_APP="$STAGE/RedMed.app"

echo "==> Launching on $DEVICE_NAME (native iOS app)"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator

# Clear the broken/evicted placeholder before reinstalling.
xcrun simctl uninstall "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true

xcrun simctl install "$DEVICE_ID" "$STAGED_APP"
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
echo "RedMed native app is running on $DEVICE_NAME."

rm -rf "$STAGE"
