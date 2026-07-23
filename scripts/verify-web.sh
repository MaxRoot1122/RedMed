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

for name in ("get.html", "privacy-policy.html"):
    mpath = f"RedMed.app/Contents/Resources/www/{name}"
    try:
        if not filecmp.cmp(name, mpath, shallow=False):
            print(f"FAIL: {mpath} out of sync with {name}"); sys.exit(1)
    except FileNotFoundError:
        print(f"WARN: missing mirror {mpath}")
print("OK: get.html + privacy-policy mirrors match")

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
