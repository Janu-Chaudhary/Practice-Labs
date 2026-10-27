#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
# gen SERVICE DATE N: N realistic log lines (same generator is used by check.sh)
gen() { local i; for ((i = 0; i < $3; i++)); do
  printf '%sT%02d:%02d:%02d service=%s method=GET status=200 %dms\n' "$2" $((i / 3600 % 24)) $((i / 60 % 60)) $((i % 60)) "$1" $((i % 97 + 3))
done; }
fresh_work
mkdir -p project/api/logs project/worker/logs project/web project/docs project/config/secrets
gen api    2026-10-27 3000 > project/api/logs/api.log               # big (~170 KB), fresh
gen api    2026-09-15 40   > project/api/logs/api-2026-09.log        # small, old
gen worker 2026-10-27 50   > project/worker/logs/worker.log          # small, fresh
gen worker 2026-09-15 2500 > project/worker/logs/worker-2026-09.log  # big, old
gen web    2026-10-05 30   > project/web/access.log                  # small, old
printf '%s\n' "# How to read the logs" "Logs live in each service's logs/ folder." > project/docs/logs-howto.md
printf '%s\n' "port: 8080" "log_level: info" > project/config/app.yml
printf '%s\n' "host: db" "name: shop" > project/config/db.yml
: > project/config/secrets/.keep
touch -d '40 days ago' project/api/logs/api-2026-09.log project/worker/logs/worker-2026-09.log
touch -d '20 days ago' project/web/access.log
banner "13 find old and big logs (Quiz-style): find -name -type -size -mtime, wc -l, mv \$(find), cp -r"
