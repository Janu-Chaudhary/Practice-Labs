#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 07-quiz-restore-typo"
check "still 1 commit (nothing committed)" '[ "$(git rev-list --count HEAD)" = 1 ]'
check "last commit still has TIMEOUT = 30" 'git show HEAD:config.py | grep -qx "TIMEOUT = 30"'
check "staging area has TIMEOUT = 60" 'git show :config.py | grep -qx "TIMEOUT = 60"'
check "working directory has TIMEOUT = 60" 'grep -qx "TIMEOUT = 60" config.py'
check "typo 6000 is gone" '! grep -q 6000 config.py'
check "nothing unstaged left (git diff is empty)" 'git diff --quiet'
check "change is still staged (git diff --staged not empty)" '! git diff --staged --quiet'
summary
