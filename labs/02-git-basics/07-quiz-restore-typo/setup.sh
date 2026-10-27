#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file config.py 'HOST = "localhost"
TIMEOUT = 30' "Add config"
printf 'HOST = "localhost"\nTIMEOUT = 60\n' > config.py
git add config.py
printf 'HOST = "localhost"\nTIMEOUT = 6000\n' > config.py
banner "Quiz 1 Q12: throw away only the unstaged typo"
