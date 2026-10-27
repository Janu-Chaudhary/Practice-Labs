#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 02-branch-switch"
check "branch docs exists" 'git rev-parse --verify -q refs/heads/docs'
check "branch hotfix exists" 'git rev-parse --verify -q refs/heads/hotfix'
check "main still has 2 commits (nothing committed on main)" '[ "$(git rev-list --count main)" = 2 ]'
check "docs has 3 commits" '[ "$(git rev-list --count docs)" = 3 ]'
check "docs tip message is \"Add install section\"" '[ "$(git log -1 --format=%s docs)" = "Add install section" ]'
check "README.md at docs contains \"## Install\"" 'git show docs:README.md | grep -q "^## Install"'
check "README.md at main does NOT contain \"## Install\"" '! git show main:README.md | grep -q "Install"'
check "hotfix points at the same commit as main" '[ "$(git rev-parse hotfix)" = "$(git rev-parse main)" ]'
check "you are on branch main" '[ "$(git branch --show-current)" = main ]'
check "working tree clean" '[ -z "$(git status --porcelain)" ]'
summary
