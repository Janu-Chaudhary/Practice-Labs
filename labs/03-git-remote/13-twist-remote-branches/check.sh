#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "you are on report, working tree clean" '[ "$(git branch --show-current)" = report ] && [ -z "$(git status --porcelain)" ]'
check "stale origin/old-ui is gone from your repo (pruned)" '! git show-ref --verify -q refs/remotes/origin/old-ui'
check "experiment is deleted on origin (and origin/experiment gone locally)" '! git -C remote.git show-ref --verify -q refs/heads/experiment && ! git show-ref --verify -q refs/remotes/origin/experiment'
check "local branch search exists, is the teammate's commit, tracks origin/search" '[ "$(git rev-parse search)" = "$(cat .git/lab-search)" ] && [ "$(git rev-parse --abbrev-ref search@{upstream})" = origin/search ]'
check "report is on origin, unchanged (1 commit on top of Add app)" '[ "$(git -C remote.git rev-parse report)" = "$(cat .git/lab-report)" ] && [ "$(git rev-parse report)" = "$(cat .git/lab-report)" ]'
check "report tracks origin/report (pushed with -u)" '[ "$(git rev-parse --abbrev-ref report@{upstream})" = origin/report ]'
check "local main caught up with origin's main (fast-forward, no merge commit)" '[ "$(git rev-parse main)" = "$(cat .git/lab-main)" ] && [ "$(git -C remote.git rev-parse main)" = "$(cat .git/lab-main)" ]'
check "origin has exactly the branches main, report, search" '[ "$(git -C remote.git for-each-ref --format="%(refname:short)" refs/heads | sort | tr "\n" " ")" = "main report search " ]'
summary
