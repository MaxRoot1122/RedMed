#!/usr/bin/env bash
# Propagate config/canonical-url to every surface that embeds the NFC card URL.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="$ROOT/config/canonical-url"

url="$(grep -E '^https://' "$CFG" | head -1 | tr -d '[:space:]')"
if [[ -z "$url" ]]; then
  echo "No https:// URL found in $CFG" >&2
  exit 1
fi

origin="$(python3 - "$url" <<'PY'
from urllib.parse import urlparse
import sys
p = urlparse(sys.argv[1])
print(f"{p.scheme}://{p.netloc}")
PY
)"

privacy="${url%/index.html}/privacy-policy.html"

echo "Canonical card URL: $url"
echo "Privacy URL: $privacy"

perl -i -pe "s#static let medicalCardBaseURL = \"https?://[^\"]+\"#static let medicalCardBaseURL = \"$url\"#" \
  "$ROOT/ios/RedMed/AppConfig.swift"
perl -i -pe "s#static let privacyPolicyURL = \"https?://[^\"]+\"#static let privacyPolicyURL = \"$privacy\"#" \
  "$ROOT/ios/RedMed/AppConfig.swift"

for f in "$ROOT/index.html" "$ROOT/RedMed.app/Contents/Resources/www/index.html"; do
  perl -i -pe "s#var HOSTED_URL = \"https?://[^\"]+\";#var HOSTED_URL = \"$url\";#" "$f"
done

perl -i -pe "s#<string name=\"launch_url\">https?://[^<]+</string>#<string name=\"launch_url\">$url</string>#" \
  "$ROOT/android/app/src/main/res/values/strings.xml"
perl -i -pe "s#\"site\": \"https?://[^\"]+\"#\"site\": \"$origin\"#" \
  "$ROOT/android/app/src/main/res/values/strings.xml"

echo "Synced. Update android/app/src/main/AndroidManifest.xml host if switching to a custom domain."
