#!/bin/bash
# Build RedMed for iPhone from the command line (requires full Xcode).
# Signing for a physical device still needs your Team selected once in Xcode.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/ios/RedMed.xcodeproj"
SCHEME="RedMed"
CONFIG="${REDMED_IOS_CONFIG:-Release}"
DEST="${REDMED_IOS_DEST:-generic/platform=iOS}"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERROR: xcodebuild not found. Install Xcode from the Mac App Store."
  exit 1
fi

if ! xcodebuild -version >/dev/null 2>&1; then
  echo "ERROR: Full Xcode is required (Command Line Tools alone are not enough)."
  echo "Install Xcode, then run:"
  echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

echo "==> RedMed iOS build ($CONFIG, $DEST)"
echo "    Project: $PROJECT"
echo ""

# Compile-check without a signing identity. Use Xcode → Run for device install.
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DEST" \
  -configuration "$CONFIG" \
  CODE_SIGNING_ALLOWED=NO \
  build

echo ""
echo "Build succeeded."
echo ""
echo "Install on your iPhone:"
echo "  1. Open ios/RedMed.xcodeproj in Xcode"
echo "  2. Plug in iPhone → Signing & Capabilities → select your Team"
echo "  3. Press Run (⌘R)"
echo ""
echo "Optional archive for TestFlight / App Store:"
echo "  xcodebuild -project \"$PROJECT\" -scheme \"$SCHEME\" -configuration Release archive -archivePath build/RedMed.xcarchive"
echo "  (Requires a paid Apple Developer team and valid signing in Xcode first.)"
