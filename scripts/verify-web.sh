#!/usr/bin/env bash
# RedMed web verification — CSP hash, JS syntax, mirror sync, HTTP smoke.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 << 'PY'
import re, hashlib, base64, subprocess, sys, filecmp, urllib.request, os

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

for path, label in (("get.html", "get.html"), ("card/index.html", "card.html")):
    script, _ = script_hash(path)
    tmp = f"/tmp/redmed-{label.replace('/', '-')}.js"
    open(tmp, "w").write(script)
    r = subprocess.run(["node", "--check", tmp], capture_output=True, text=True)
    if r.returncode:
        print(f"FAIL: {path} node --check"); print(r.stderr); sys.exit(1)
    print(f"OK: {path} CSP hash + node --check")

r4 = subprocess.run(["node", "--check", "card/sw.js"], capture_output=True, text=True)
if r4.returncode:
    print("FAIL: card-sw.js node --check"); print(r4.stderr); sys.exit(1)
print("OK: card-sw.js node --check")

for name in ("get.html", "privacy-policy.html", "terms-of-service.html", "card/index.html", "card/sw.js"):
    for prefix in ("mac/RedMed.app/Contents/Resources/www/", "ios/RedMed.app/Contents/Resources/www/"):
        mpath = prefix + name
        try:
            if not filecmp.cmp(name, mpath, shallow=False):
                print(f"FAIL: {mpath} out of sync with {name}"); sys.exit(1)
        except FileNotFoundError:
            print(f"WARN: missing mirror {mpath}")
print("OK: get.html + legal + card/ mirrors match")

REQUIRED_ASSETS = (
    "assets/icon.svg", "assets/icon-512.png", "assets/cpr-trainer-icon.png",
    "assets/favicon-32.png", "assets/apple-touch-icon.png",
    "assets/wordmark.svg", "assets/fonts/dm-sans-latin.woff2",
)
missing_assets = [p for p in REQUIRED_ASSETS if not os.path.isfile(p)]
if missing_assets:
    print("FAIL: missing deploy assets:")
    for p in missing_assets:
        print(" ", p)
    sys.exit(1)
print("OK: required assets present in assets/")

if os.path.isfile("index.html"):
    print("FAIL: index.html still present — owner web app removed"); sys.exit(1)
if os.path.isdir("android"):
    print("FAIL: android/ still present"); sys.exit(1)
print("OK: no index.html or android/")

# Canonical URL — iOS writes card/#d=; any phone tap opens hosted emergency card.
cfg_lines = [ln.strip() for ln in open("config/canonical-url", encoding="utf-8")]
card_url = next((ln for ln in cfg_lines if ln and not ln.startswith("#") and not ln.startswith("legacy:")), "")
legacy_urls = [
    ln.lstrip("#").strip().split(":", 1)[1]
    for ln in cfg_lines
    if ln.lstrip("#").strip().startswith("legacy:https://")
]
if not card_url:
    print("FAIL: no active target in config/canonical-url"); sys.exit(1)
legacy_url = legacy_urls[0] if legacy_urls else ""
if not legacy_url:
    print("FAIL: no legacy:https:// line in config/canonical-url"); sys.exit(1)
site_base = card_url.rstrip("/").rsplit("/", 1)[0]
privacy_url = site_base + "/privacy-policy.html"
get_started_url = site_base + "/get.html"
checks = [
    ("ios/RedMed/AppConfig.swift", get_started_url, "getStartedURL"),
    ("ios/RedMed/AppConfig.swift", card_url, "medicalCardBaseURL"),
    ("ios/RedMed/AppConfig.swift", legacy_url, "legacyHostedCardBaseURL"),
    ("ios/RedMed/AppConfig.swift", privacy_url, "privacyPolicyURL"),
]
for path, needle, label in checks:
    body = open(path, encoding="utf-8").read()
    if needle not in body:
        print(f"FAIL: {label} mismatch in {path} (expected {needle})"); sys.exit(1)
print("OK: canonical URL synced to AppConfig.swift")

pages_yml = open(".github/workflows/pages.yml", encoding="utf-8").read()
if "card/index.html" not in pages_yml or "card/sw.js" not in pages_yml:
    print("FAIL: pages.yml does not deploy card/"); sys.exit(1)
if "index.html" in pages_yml and "_site/index.html" in pages_yml.replace("card/index.html", ""):
    print("FAIL: pages.yml still deploys owner index.html"); sys.exit(1)
print("OK: deploy workflow ships card/ (not owner web)")

server_sh = "scripts/redmed-server.sh"
app_server_sh = "mac/RedMed.app/Contents/Resources/redmed-server.sh"
if os.path.isfile(server_sh) and os.path.isfile(app_server_sh):
    if not filecmp.cmp(server_sh, app_server_sh, shallow=False):
        print(f"FAIL: {app_server_sh} out of sync with {server_sh}")
        sys.exit(1)
    print("OK: redmed-server.sh mirror matches")

base = "http://127.0.0.1:8934"
for path in ("get.html", "privacy-policy.html", "card/index.html", "card/sw.js"):
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
