#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file routes.txt 'GET /orders' "Add orders route"
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
TM=$(mktemp -d); git clone -q remote.git "$TM/t"
( cd "$TM/t" && git config user.name Teammate && git config user.email tm@example.com \
  && commit_file routes.txt $'GET /orders\nGET /health' "Add health endpoint" && git push -q origin main \
  && git rev-parse HEAD > "$WORK/.git/lab-teammate" )
rm -rf "$TM"
commit_file routes.txt $'GET /orders\nGET /search' "Add search endpoint"
banner "09 twist: teammate pushed first, team wants a linear history (rebase)"
