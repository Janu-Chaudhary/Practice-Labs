#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
gen() { local i; for ((i = 0; i < $3; i++)); do
  printf '%sT%02d:%02d:%02d service=%s method=GET status=200 %dms\n' "$2" $((i / 3600 % 24)) $((i / 60 % 60)) $((i % 60)) "$1" $((i % 97 + 3))
done; }
# is FILE SERVICE DATE N: FILE exists and has exactly the generated content
is() { [ -f "$1" ] && cmp -s "$1" <(gen "$2" "$3" "$4"); }
same_sorted() { cmp -s "$1" <(printf '%s\n' "${@:2}" | sort); }
RP="$WORK/reports"

check "reports/big-logs.txt = the 2 .log files over 100 KB, sorted"  'same_sorted reports/big-logs.txt project/api/logs/api.log project/worker/logs/worker-2026-09.log'
if [ -f "$RP/big-logs.txt" ]; then
  grep -q '^archive/' "$RP/big-logs.txt" && hint "you listed after moving: step 1 is about the files where they were at the start (do it first)"
  grep -q '^\./' "$RP/big-logs.txt" && hint "paths start with ./ : run  find project ...  not  find . ..."
fi
check "reports/log-count.txt holds just 5"                           '[ "$(tr -d " \t\n" < reports/log-count.txt)" = 5 ]'
[ -f "$RP/log-count.txt" ] && [ "$(tr -d ' \t\n' < "$RP/log-count.txt")" -gt 5 ] 2>/dev/null && hint "too many: '*log*' also matches the logs/ folders and logs-howto.md. Use -type f -name '*.log'"
check "archive/ holds exactly the 3 old logs"                        '[ "$(ls -A archive | sort | tr "\n" " ")" = "$(printf "%s\n" access.log api-2026-09.log worker-2026-09.log | sort | tr "\n" " ")" ]'
check "archive/ logs are unchanged"                                  'is archive/api-2026-09.log api 2026-09-15 40 && is archive/worker-2026-09.log worker 2026-09-15 2500 && is archive/access.log web 2026-10-05 30'
check "old logs are gone from project/, fresh ones stay"             '[ ! -e project/api/logs/api-2026-09.log ] && [ ! -e project/worker/logs/worker-2026-09.log ] && [ ! -e project/web/access.log ] && is project/api/logs/api.log api 2026-10-27 3000 && is project/worker/logs/worker.log worker 2026-10-27 50'
check "backup/config is a full copy (app.yml, db.yml, secrets/.keep)" 'cmp -s backup/config/app.yml project/config/app.yml && cmp -s backup/config/db.yml project/config/db.yml && [ -f backup/config/secrets/.keep ]'
[ -f "$WORK/backup/app.yml" ] && hint "files landed directly in backup/: copy the FOLDER (cp -r project/config backup/), not its contents"
[ -d "$WORK/backup/config/config" ] && hint "backup/config/config exists: cp -r into an existing backup/config nests it. Copy to backup/ instead"
check "project/config and project/docs untouched"                    '[ -f project/config/secrets/.keep ] && [ -f project/config/app.yml ] && [ -f project/docs/logs-howto.md ]'
summary
