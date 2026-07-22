#!/usr/bin/env python3
"""Local RedMed static server for PC / Mac / Linux.

Uses a threaded HTTP/1.1 server so browsers (and Cursor preview) can load
index.html + fonts/assets without empty-response resets from the stock
single-thread HTTP/1.0 `python -m http.server`.

Usage:
  python3 scripts/serve-local.py
  python3 scripts/serve-local.py --open
  python3 scripts/serve-local.py --root RedMed.app/Contents/Resources/www --port 8934
"""
from __future__ import annotations

import argparse
import os
import sys
import threading
import time
import webbrowser
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class RedMedHandler(SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def end_headers(self) -> None:
        self.send_header("Cache-Control", "no-store")
        self.send_header("Connection", "close")
        super().end_headers()

    def log_message(self, fmt: str, *args) -> None:
        sys.stderr.write("%s - %s\n" % (self.log_date_time_string(), fmt % args))


def wait_ready(host: str, port: int, timeout: float = 8.0) -> bool:
    import urllib.request

    url = f"http://{host}:{port}/index.html"
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(url, timeout=1.0) as resp:
                if resp.status == 200:
                    return True
        except Exception:
            time.sleep(0.1)
    return False


def main() -> int:
    here = os.path.dirname(os.path.abspath(__file__))
    repo = os.path.dirname(here)
    parser = argparse.ArgumentParser(description="Serve RedMed on localhost")
    parser.add_argument(
        "--root",
        default=repo,
        help="Directory to serve (default: repo root)",
    )
    parser.add_argument("--host", default=os.environ.get("REDMED_HOST", "127.0.0.1"))
    parser.add_argument(
        "--port",
        type=int,
        default=int(os.environ.get("REDMED_PORT", "8934")),
    )
    parser.add_argument(
        "--open",
        action="store_true",
        help="Open the app in the default browser once ready",
    )
    args = parser.parse_args()

    root = os.path.abspath(args.root)
    index = os.path.join(root, "index.html")
    if not os.path.isfile(index):
        sys.stderr.write(f"error: index.html not found in {root}\n")
        return 1

    os.chdir(root)
    handler = partial(RedMedHandler, directory=root)
    try:
        httpd = ThreadingHTTPServer((args.host, args.port), handler)
    except OSError as exc:
        sys.stderr.write(
            f"error: cannot bind {args.host}:{args.port} ({exc}). "
            "Quit the other process or set REDMED_PORT.\n"
        )
        return 1

    url = f"http://{args.host}:{args.port}/index.html"
    sys.stderr.write(f"RedMed local server: {url}\n")
    sys.stderr.write(f"Serving: {root}\n")
    sys.stderr.write("Press Ctrl+C to stop.\n")

    if args.open:
        def _open() -> None:
            if wait_ready(args.host, args.port):
                webbrowser.open(url)

        threading.Thread(target=_open, daemon=True).start()

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        sys.stderr.write("\nStopped.\n")
    finally:
        httpd.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
