#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file utils.py 'def slug(s):
    return s.lower().replace(" ", "-")' "Add utils"
commit_file old_notes.txt 'remember to delete me' "Add notes"
commit_file .env 'DB_PASSWORD=hunter2' "Add env"
banner "git mv / git rm / git rm --cached / .gitignore"
