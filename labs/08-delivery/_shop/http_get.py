# Checker helper (the student never runs this): print the body of an HTTP GET, even on a 500.
#   python3 http_get.py http://127.0.0.1:8402/healthz
import sys
import urllib.error
import urllib.request

try:
    with urllib.request.urlopen(sys.argv[1], timeout=3) as r:
        sys.stdout.write(r.read().decode())
except urllib.error.HTTPError as e:
    sys.stdout.write(e.read().decode())
    sys.exit(0)
except Exception as e:  # connection refused etc.
    sys.stdout.write(f"NO ANSWER {e}\n")
    sys.exit(1)
