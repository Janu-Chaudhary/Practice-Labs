#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
mkdir -p app routes
commit_file app/server.py 'def handle(payload):
    return payload["data"]' "Add server"
# working-directory changes the student must sort out
cat > app/server.py <<'PY'
def handle(payload):
    if not payload:
        return None
    return payload["data"]
PY
cat > routes/webhooks.py <<'PY'
def webhook(event):
    return {"ok": True, "event": event}
PY
echo "DEBUG 09:00 server started" > debug.log
banner "status / add / commit: two clean commits, one ignored log"
