#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf 'def main():\n    print("Shop v1")\n' > app.py
printf 'flask==3.0.0\nrequests==2.31.0\n' > requirements.txt
git add . && git commit -q -m "Add app"
git switch -q -c feature
printf 'flask==3.0.0\nrequests==2.31.0\npytest==8.2.0\n' > requirements.txt
git add . && git commit -q -m "Add pytest"
git switch -q -c experiment main
printf 'def main():\n    print("!!! EXPERIMENTAL SHOP !!!")\n' > app.py
git add . && git commit -q -m "Try experimental banner"
git switch -q main
printf 'def main():\n    print("Shop v2")\n' > app.py
printf 'flask==3.0.0\nrequests==2.31.0\ngunicorn==22.0.0\n' > requirements.txt
git add . && git commit -q -m "Add gunicorn, bump to v2"
# the teammate's half-finished merge of the WRONG branch
git merge experiment >/dev/null 2>&1 || true
banner "Twist: abort a teammate's wrong merge, then merge feature keeping BOTH sides"
