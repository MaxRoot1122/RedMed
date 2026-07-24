#!/usr/bin/env bash
# Propagate config/canonical-url to every surface that embeds the NFC card URL.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="$ROOT/config/canonical-url"

python3 - "$ROOT" "$CFG" <<'PY'
import json
import re
import sys
from pathlib import Path
from urllib.parse import urlparse

root = Path(sys.argv[1])
cfg_path = Path(sys.argv[2])
lines = [ln.strip() for ln in cfg_path.read_text(encoding="utf-8").splitlines()]

card_url = next((ln for ln in lines if ln.startswith("https://")), "")
if not card_url:
    sys.exit("No https:// URL found in config/canonical-url")

legacy_urls = [ln.split(":", 1)[1] for ln in lines if ln.startswith("legacy:https://")]
parsed = urlparse(card_url)
origin = f"{parsed.scheme}://{parsed.netloc}"
host = parsed.hostname or ""
path = parsed.path.removesuffix("/index.html") or ""
path_prefix = path if path else "/"
get_url = card_url.replace("/index.html", "/get.html")
privacy_url = card_url.replace("/index.html", "/privacy-policy.html")
legacy_js = json.dumps(legacy_urls, ensure_ascii=False)

print(f"Canonical card URL: {card_url}")
print(f"Get started URL:    {get_url}")
print(f"Privacy URL:        {privacy_url}")
print(f"Origin:             {origin}")
print(f"Legacy URLs:        {legacy_urls or '(none)'}")

# iOS
app_config = root / "ios/RedMed/AppConfig.swift"
text = app_config.read_text(encoding="utf-8")
text = re.sub(r'static let getStartedURL = "https?://[^"]+"', f'static let getStartedURL = "{get_url}"', text)
text = re.sub(r'static let medicalCardBaseURL = "https?://[^"]+"', f'static let medicalCardBaseURL = "{card_url}"', text)
text = re.sub(r'static let privacyPolicyURL = "https?://[^"]+"', f'static let privacyPolicyURL = "{privacy_url}"', text)
app_config.write_text(text, encoding="utf-8")

# Web
legacy_pattern = re.compile(r"var LEGACY_HOSTED_URLS = \[[^\]]*\];")
legacy_repl = f"var LEGACY_HOSTED_URLS = {legacy_js};"
for rel in ("index.html", "RedMed.app/Contents/Resources/www/index.html"):
    html = root / rel
    text = html.read_text(encoding="utf-8")
    text = re.sub(r'var GET_URL = "https?://[^"]+";', f'var GET_URL = "{get_url}";', text)
    text = re.sub(r'var HOSTED_URL = "https?://[^"]+";', f'var HOSTED_URL = "{card_url}";', text)
    if legacy_pattern.search(text):
        text = legacy_pattern.sub(legacy_repl, text)
    else:
        text = text.replace(
            f'var HOSTED_URL = "{card_url}";',
            f'var HOSTED_URL = "{card_url}";\n  {legacy_repl}',
            1,
        )
    html.write_text(text, encoding="utf-8")

# Android strings
strings = root / "android/app/src/main/res/values/strings.xml"
text = strings.read_text(encoding="utf-8")
text = re.sub(r"<string name=\"launch_url\">https?://[^<]+</string>", f'<string name="launch_url">{card_url}</string>', text)
text = re.sub(r'\\"site\\": \\"https?://[^\\"]+\\"', f'\\"site\\": \\"{origin}\\"', text)
strings.write_text(text, encoding="utf-8")

# Android manifest — primary custom domain + optional legacy GitHub project path
manifest = root / "android/app/src/main/AndroidManifest.xml"
text = manifest.read_text(encoding="utf-8")
text = re.sub(
    r"<!-- Verifies this app is allowed to open [^>]+-->",
    f"<!-- Verified App Links for {host} (and legacy GitHub Pages path while tags migrate) -->",
    text,
    count=1,
)

primary_block = f"""            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="https"
                    android:host="{host}"
                    android:pathPrefix="{path_prefix}" />
            </intent-filter>"""

legacy_blocks = ""
for legacy in legacy_urls:
    lp = urlparse(legacy)
    legacy_host = lp.hostname or ""
    legacy_path = lp.path.removesuffix("/index.html") or "/"
    legacy_blocks += f"""
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="https"
                    android:host="{legacy_host}"
                    android:pathPrefix="{legacy_path}" />
            </intent-filter>"""

# Replace ALL https App Link intent-filters after LAUNCHER with primary + legacy set.
pattern = re.compile(
    r"(?:\n            <intent-filter android:autoVerify=\"true\">.*?</intent-filter>)+",
    re.DOTALL,
)
if not pattern.search(text):
    sys.exit("Could not locate AndroidManifest https intent-filter block")
text = pattern.sub("\n" + primary_block + legacy_blocks, text, count=1)
manifest.write_text(text, encoding="utf-8")

print("Synced iOS, web, and Android surfaces from config/canonical-url.")
PY
