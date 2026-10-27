#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py 'print("feed service")' "Add app"
printf 'import os\nDB_PASSWORD = os.environ["DB_PASSWORD"]\n' > config.py
printf 'DB_PASSWORD=Summer2024!\n' > .env
git add config.py .env; git commit -q -m "Add config loader"
commit_file orders.py 'def list_orders(): return []' "Add orders route"
git rm -q .env; git commit -q -m "Remove env file"
commit_file README.md '# Feed service' "Add README"
# your local .env (new password) sits untracked in the folder
printf 'DB_PASSWORD=local-dev-only\n' > .env
banner "10 twist: find the commit that leaked a secret, and stop it happening again"
