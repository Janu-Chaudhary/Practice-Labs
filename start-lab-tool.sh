#!/usr/bin/env bash
# Starts the browser lab tool on http://127.0.0.1:8765 and opens it.
cd "$(dirname "$0")/lab-tool" || exit 1
( sleep 1; xdg-open "http://127.0.0.1:8765" >/dev/null 2>&1 ) &
exec python3 server.py
