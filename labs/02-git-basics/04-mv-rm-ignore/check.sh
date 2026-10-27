#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 04-mv-rm-ignore"
check "main has exactly 4 commits (one new commit)" '[ "$(git rev-list --count main)" = 4 ]'
check "latest commit message is \"Tidy repository\"" '[ "$(git log -1 --format=%s)" = "Tidy repository" ]'
check "helpers.py at HEAD (renamed from utils.py)" 'git show HEAD:helpers.py | grep -q "def slug"'
check "utils.py gone from HEAD and disk" '! git cat-file -e HEAD:utils.py 2>/dev/null && [ ! -e utils.py ]'
check "old_notes.txt gone from HEAD and disk" '! git cat-file -e HEAD:old_notes.txt 2>/dev/null && [ ! -e old_notes.txt ]'
check ".env no longer tracked at HEAD" '! git cat-file -e HEAD:.env 2>/dev/null'
check ".env still on disk with the password" 'grep -q DB_PASSWORD .env'
check ".gitignore at HEAD contains .env" 'git show HEAD:.gitignore | grep -qx "\.env"'
check "working tree clean (.env is ignored)" '[ -z "$(git status --porcelain)" ]'
summary
