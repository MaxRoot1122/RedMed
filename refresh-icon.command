#!/bin/bash
# Forces macOS to reload RedMed.app's new icon (busts Finder/Dock icon cache)
set -e
APP="$(cd "$(dirname "$0")" && pwd)/RedMed.app"
echo "Refreshing icon for: $APP"

# 1. Bump modification times so LaunchServices re-reads the bundle
touch "$APP" "$APP/Contents/Info.plist" "$APP/Contents/Resources/AppIcon.icns"

# 2. Re-register the bundle with LaunchServices
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" 2>/dev/null || true

# 3. Clear the user icon-services cache (no sudo needed for this one)
rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.iconservices"* 2>/dev/null || true

# 4. Restart the UI services that hold cached icons
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "Done. If the icon still looks stale, log out and back in."
sleep 1
