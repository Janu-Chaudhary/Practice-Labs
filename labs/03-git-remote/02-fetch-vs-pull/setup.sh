#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py 'print("orders api")' "Add app"
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
# a teammate pushes two commits from their own clone
TM=$(mktemp -d); git clone -q remote.git "$TM/t"
( cd "$TM/t" && git config user.name Teammate && git config user.email tm@example.com \
  && commit_file config.py 'TIMEOUT = 30' "Add config" \
  && commit_file README.md '# Orders API' "Add README" && git push -q origin main )
rm -rf "$TM"
banner "02 fetch vs pull: bring a teammate's commits into main"
