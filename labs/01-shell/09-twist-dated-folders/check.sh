#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
A24=('2026-10-24T09:00:00 service=orders method=GET status=200 45ms'
     '2026-10-24T09:05:00 service=orders method=POST status=500 2500ms'
     '2026-10-24T09:20:00 service=users method=GET status=200 999ms')
D24=('2026-10-24T09:01:00 query=select-orders 1200ms'
     '2026-10-24T09:30:00 query=update-users 80ms')
A25=('2026-10-25T10:00:00 service=orders method=GET status=200 1000ms'
     '2026-10-25T10:10:00 service=search method=GET status=200 10500ms')
D25=('2026-10-25T09:59:00 query=select-search 3400ms'
     '2026-10-25T10:20:00 query=vacuum 15ms')
SLOW=("${D24[0]}" "${A24[1]}" "${D25[0]}" "${A25[0]}" "${A25[1]}")

check "archive/2026-10-24/app-2026-10-24.log in place, unchanged" 'same archive/2026-10-24/app-2026-10-24.log "${A24[@]}"'
check "archive/2026-10-24/db-2026-10-24.log in place, unchanged"  'same archive/2026-10-24/db-2026-10-24.log "${D24[@]}"'
check "archive/2026-10-25/app-2026-10-25.log in place, unchanged" 'same archive/2026-10-25/app-2026-10-25.log "${A25[@]}"'
check "archive/2026-10-25/db-2026-10-25.log in place, unchanged"  'same archive/2026-10-25/db-2026-10-25.log "${D25[@]}"'
check "no .log files left in incoming"                            '! ls incoming/*.log'
check "incoming/readme.txt is untouched"                          'same incoming/readme.txt "Drop zone for log files. Do not delete this file."'
check "reports/slow.txt = the 5 slow lines, oldest first"          'same reports/slow.txt "${SLOW[@]}"'
S="$WORK/reports/slow.txt"
if [ -f "$S" ]; then
  grep -q ' 999ms' "$S" && hint "999ms is under 1000ms: you need 4 or more digits before ms"
  grep -q ' 1000ms' "$S" || hint "1000ms is missing: 'or more' includes exactly 1000"
  grep -q 'archive/' "$S" && hint "file names in the lines: use grep -h"
fi
summary
