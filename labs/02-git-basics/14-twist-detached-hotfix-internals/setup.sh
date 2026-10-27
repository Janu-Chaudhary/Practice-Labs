#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf 'print("Shop")\n' > app.py
printf 'RETRIES = 0\n' > config.py
git add . && git commit -q -m "Add app and config"
printf '# Shop\n' > README.md
git add . && git commit -q -m "Add readme"
git tag -a v1.0 -m "Release 1.0"
printf 'print("Shop v2")\n' > app.py
git add . && git commit -q -m "Start v2"
printf 'RETRIES = 5\nTIMEOUT = 10\n' > config.py
printf 'Welcome to Shop\n' > banner.txt
printf 'Shop Ltd, 2026\n' > footer.txt
printf 'Welcome to Shop\n' > motd.txt
git add . && git commit -q -m "Add texts, tune config"
# answers.txt is the student's answer sheet: keep it out of git status
echo "answers.txt" >> .git/info/exclude
git rev-parse main > .git/lab-main-tip
git rev-parse v1.0^{commit} > .git/lab-v10
banner "Twist: hotfix an old release from detached HEAD, then read git's objects"
