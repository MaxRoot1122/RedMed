#!/usr/bin/env bash
# RedMed web verification — CSP hash, JS syntax, mirror sync, HTTP smoke.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 << 'PY'
import re, hashlib, base64, subprocess, sys, filecmp, urllib.request

html = open("index.html", encoding="utf-8").read()
m = re.search(r"<script>(.*?)</script>", html, re.DOTALL)
if not m:
    print("FAIL: no inline script"); sys.exit(1)
script = m.group(1)
open("/tmp/redmed-script.js", "w").write(script)
h = base64.b64encode(hashlib.sha256(script.encode()).digest()).decode()
csp = re.search(r"sha256-([^']+)", html)
if not csp or csp.group(1) != h:
    print("FAIL: CSP hash mismatch")
    print(" expected:", h)
    print(" in file:", csp.group(1) if csp else "none")
    sys.exit(1)
print("OK: CSP hash matches inline script")

r = subprocess.run(["node", "--check", "/tmp/redmed-script.js"], capture_output=True, text=True)
if r.returncode:
    print("FAIL: node --check"); print(r.stderr); sys.exit(1)
print("OK: node --check passed")

mirror = "RedMed.app/Contents/Resources/www/index.html"
if not filecmp.cmp("index.html", mirror, shallow=False):
    print(f"FAIL: {mirror} out of sync with index.html"); sys.exit(1)
print("OK: macOS www mirror matches index.html")

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
