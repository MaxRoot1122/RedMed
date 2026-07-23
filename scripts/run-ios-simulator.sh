#!/bin/bash
# Build (if needed) and run the native RedMed iOS app in Simulator.
# RedMed.app on Mac calls this — not the web index.html launcher.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/ios/RedMed.xcodeproj"
SCHEME="RedMed"
CONFIG="${REDMED_IOS_CONFIG:-Debug}"
DERIVED="$ROOT/build/DerivedData"
APP="$DERIVED/Build/Products/${CONFIG}-iphonesimulator/RedMed.app"
DEVICE_NAME="${REDMED_SIM_DEVICE:-iPhone 17}"
BUNDLE_ID="local.redmed.app"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERROR: xcodebuild not found. Install Xcode from the Mac App Store." >&2
  exit 1
fi

RUNTIME="$(xcrun simctl list runtimes available -j | python3 -c "
import json, sys
runtimes = json.load(sys.stdin).get('runtimes', [])
ios = [r for r in runtimes if r.get('isAvailable') and r.get('platform') == 'iOS']
if not ios:
    sys.exit('ERROR: No iOS Simulator runtime installed.')
print(sorted(ios, key=lambda r: r.get('version', ''), reverse=True)[0]['identifier'])
")"

DEVICE_ID="$(xcrun simctl list devices available -j | python3 -c "
import json, sys
name, runtime = sys.argv[1], sys.argv[2]
data = json.load(sys.stdin)
for d in data.get('devices', {}).get(runtime, []):
    if d.get('name') == name and d.get('isAvailable'):
        print(d['udid'])
        break
else:
    sys.exit(f'ERROR: Simulator \"{name}\" not found for runtime {runtime}.')
" "$DEVICE_NAME" "$RUNTIME")"

need_build=1
if [ -d "$APP" ] && [ "${REDMED_IOS_FORCE_BUILD:-0}" != "1" ]; then
  need_build=0
fi

if [ "$need_build" -eq 1 ]; then
  echo "==> Building RedMed for iOS Simulator ($CONFIG)"
  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -configuration "$CONFIG" \
    CODE_SIGNING_ALLOWED=NO \
    -derivedDataPath "$DERIVED" \
    build
else
  echo "==> Using existing Simulator build ($APP)"
fi

echo "==> Launching on $DEVICE_NAME (native iOS app)"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator
xcrun simctl install "$DEVICE_ID" "$APP"
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
echo "RedMed native app is running on $DEVICE_NAME."
