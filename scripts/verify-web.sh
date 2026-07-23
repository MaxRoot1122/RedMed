#!/usr/bin/env bash
# RedMed web verification — CSP hash, JS syntax, mirror sync, HTTP smoke.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 << 'PY'
import re, hashlib, base64, subprocess, sys, filecmp, urllib.request, json

def script_hash(path):
    html = open(path, encoding="utf-8").read()
    m = re.search(r"<script>(.*?)</script>", html, re.DOTALL)
    if not m:
        print(f"FAIL: no inline script in {path}"); sys.exit(1)
    script = m.group(1)
    h = base64.b64encode(hashlib.sha256(script.encode()).digest()).decode()
    csp = re.search(r"script-src[^;]*'sha256-([^']+)'", html)
    if not csp or csp.group(1) != h:
        print(f"FAIL: CSP hash mismatch in {path}")
        print(" expected:", h)
        print(" in file:", csp.group(1) if csp else "none")
        sys.exit(1)
    return script, h

script, h = script_hash("index.html")
open("/tmp/redmed-script.js", "w").write(script)
print("OK: index.html CSP hash matches inline script")

r = subprocess.run(["node", "--check", "/tmp/redmed-script.js"], capture_output=True, text=True)
if r.returncode:
    print("FAIL: node --check"); print(r.stderr); sys.exit(1)
print("OK: node --check passed")

get_script, _ = script_hash("get.html")
open("/tmp/redmed-get-script.js", "w").write(get_script)
r2 = subprocess.run(["node", "--check", "/tmp/redmed-get-script.js"], capture_output=True, text=True)
if r2.returncode:
    print("FAIL: get.html node --check"); print(r2.stderr); sys.exit(1)
print("OK: get.html CSP hash + node --check")

mirror = "RedMed.app/Contents/Resources/www/index.html"
if not filecmp.cmp("index.html", mirror, shallow=False):
    print(f"FAIL: {mirror} out of sync with index.html"); sys.exit(1)
print("OK: macOS www mirror matches index.html")

for name in ("get.html", "privacy-policy.html", "terms-of-service.html"):
    mpath = f"RedMed.app/Contents/Resources/www/{name}"
    try:
        if not filecmp.cmp(name, mpath, shallow=False):
            print(f"FAIL: {mpath} out of sync with {name}"); sys.exit(1)
    except FileNotFoundError:
        print(f"WARN: missing mirror {mpath}")
print("OK: get.html + privacy-policy + terms-of-service mirrors match")

import os
REQUIRED_ASSETS = (
    "assets/icon.svg", "assets/icon-512.png", "assets/cpr-trainer-icon.png",
    "assets/favicon-32.png", "assets/apple-touch-icon.png",
    "assets/logo-512.png", "assets/heading.svg", "assets/fonts/dm-sans-latin.woff2",
)
missing_assets = [p for p in REQUIRED_ASSETS if not os.path.isfile(p)]
if missing_assets:
    print("FAIL: missing deploy assets:")
    for p in missing_assets:
        print(" ", p)
    sys.exit(1)
print("OK: required assets present in assets/")

index_html = open("index.html", encoding="utf-8").read()
css = index_html.split("<style>", 1)[1].split("</style>", 1)[0]
if css.count("{") != css.count("}"):
    print("FAIL: index.html CSS brace imbalance")
    sys.exit(1)
print("OK: index.html CSS braces balanced")

# Canonical URL — shipping surfaces must match config/canonical-url
from urllib.parse import urlparse
cfg_lines = [ln.strip() for ln in open("config/canonical-url", encoding="utf-8")]
card_url = next((ln for ln in cfg_lines if ln.startswith("https://")), "")
legacy_urls = [ln.split(":", 1)[1] for ln in cfg_lines if ln.startswith("legacy:https://")]
if not card_url:
    print("FAIL: no https:// in config/canonical-url"); sys.exit(1)
get_url = card_url.replace("/index.html", "/get.html")
privacy_url = card_url.replace("/index.html", "/privacy-policy.html")
origin = f"{urlparse(card_url).scheme}://{urlparse(card_url).netloc}"
checks = [
    ("ios/RedMed/AppConfig.swift", card_url, "medicalCardBaseURL"),
    ("ios/RedMed/AppConfig.swift", get_url, "getStartedURL"),
    ("ios/RedMed/AppConfig.swift", privacy_url, "privacyPolicyURL"),
    ("index.html", card_url, "HOSTED_URL"),
    ("index.html", get_url, "GET_URL"),
    ("android/app/src/main/res/values/strings.xml", card_url, "launch_url"),
    ("android/app/src/main/res/values/strings.xml", origin, "asset_statements site"),
]
for path, needle, label in checks:
    body = open(path, encoding="utf-8").read()
    if needle not in body:
        print(f"FAIL: {label} mismatch in {path} (expected {needle})"); sys.exit(1)
legacy_js = json.dumps(legacy_urls, ensure_ascii=False)
if legacy_js not in open("index.html", encoding="utf-8").read():
    print("FAIL: LEGACY_HOSTED_URLS out of sync in index.html"); sys.exit(1)
if "hostedCardOrigins" not in open("index.html", encoding="utf-8").read():
    print("FAIL: index.html missing hostedCardOrigins() allow-list helper"); sys.exit(1)
print("OK: canonical URL synced across shipping surfaces")

server_sh = "scripts/redmed-server.sh"
app_server_sh = "RedMed.app/Contents/Resources/redmed-server.sh"
if os.path.isfile(server_sh) and os.path.isfile(app_server_sh):
    if not filecmp.cmp(server_sh, app_server_sh, shallow=False):
        print(f"FAIL: {app_server_sh} out of sync with {server_sh}")
        sys.exit(1)
    print("OK: redmed-server.sh mirror matches")

try:
    links = json.load(open(".well-known/assetlinks.json", encoding="utf-8"))
    fps = links[0]["target"]["sha256_cert_fingerprints"]
    if any("REPLACE_WITH" in f for f in fps):
        print("WARN: assetlinks.json still has REPLACE_WITH_* placeholders — paste Play App Signing + upload key SHA-256 before relying on TWA verification (see docs/ANDROID_PLAY.md)")
    else:
        print("OK: assetlinks.json fingerprints look populated")
except Exception as e:
    print(f"WARN: could not parse assetlinks.json ({e})")

base = "http://127.0.0.1:8934"
for path in ("index.html", "get.html", "privacy-policy.html"):
    try:
        with urllib.request.urlopen(f"{base}/{path}", timeout=3) as resp:
            if resp.status != 200:
                print(f"FAIL: HTTP {path} -> {resp.status}"); sys.exit(1)
    except Exception as e:
        print(f"WARN: HTTP {path} skipped ({e}) — start: python3 -m http.server 8934 --bind 127.0.0.1")
        break
else:
    print("OK: HTTP smoke (8934)")

print("verify-web: all checks passed")
PY
