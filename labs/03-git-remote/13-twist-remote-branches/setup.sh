#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py $'def handle(request):\n    return "ok"' "Add app"
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
# two old branches that live on origin (you only have origin/... copies of them)
git switch -q -c experiment
commit_file try.py 'print("trying things")' "Try a cache"
git push -q origin experiment
git switch -q main
git switch -q -c old-ui
commit_file ui.html '<h1>old</h1>' "Old UI"
git push -q origin old-ui
git switch -q main
git branch -q -D experiment old-ui
# your own new branch, never pushed
git switch -q -c report
commit_file report.py $'def sales_report():\n    return []' "Add sales report"
git rev-parse HEAD > .git/lab-report
# meanwhile a teammate: deletes old-ui on origin, pushes a new branch search, and a commit on main
TM=$(mktemp -d); git clone -q remote.git "$TM/t"
( cd "$TM/t" && git config user.name Teammate && git config user.email tm@example.com \
  && git push -q origin --delete old-ui \
  && git switch -q -c search && commit_file search.py $'def search(q):\n    return []' "Add search" \
  && git push -q origin search && git rev-parse HEAD > "$WORK/.git/lab-search" \
  && git switch -q main && commit_file README.md '# Shop API' "Add README" \
  && git push -q origin main && git rev-parse HEAD > "$WORK/.git/lab-main" )
rm -rf "$TM"
banner "13 tidy up remote branches: prune, track, push -u, delete on origin, catch main up"
