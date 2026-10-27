#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py $'def handle(request):\n    return "ok"' "Add request handler"
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
commit_file README.md '# Orders API' "Add README"
# earlier: detached HEAD at the first commit, one commit made there, then back to main
git checkout -q --detach HEAD~1 2>/dev/null
commit_file limits.py 'RATE_LIMIT = 100  # requests per minute' "Add rate limit config"
git switch -q main 2>/dev/null
banner "05 (quiz 1 Q19) find a lost detached commit, branch it, merge, push"
