#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py $'def handle(request):\n    return "ok"' "Add app"
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
TM=$(mktemp -d); git clone -q remote.git "$TM/t"
( cd "$TM/t" && git config user.name Teammate && git config user.email tm@example.com \
  && commit_file README.md '# Orders API' "Add README" && git push -q origin main \
  && git rev-parse HEAD > "$WORK/.git/lab-teammate" )
rm -rf "$TM"
commit_file app.py $'def handle(request):\n    print("request:", request)\n    return "ok"' "Log each request"
git rev-parse HEAD > .git/lab-mine
git push -q origin main 2>/dev/null   # rejected, like in the quiz
git fetch -q origin
banner "06 (quiz 1 Q11) diverged from origin: get both commits onto origin"
