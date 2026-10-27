#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
# norm FILE: squeeze spaces/tabs, drop leading/trailing ones (uniq -c pads counts with spaces)
norm() { sed -e 's/[[:space:]]\+/ /g' -e 's/^ //' -e 's/ $//' "$1"; }
L=(
  '2026-10-25T10:00:01 service=orders method=GET status=200 12ms'
  '2026-10-25T10:00:05 service=users method=GET status=502 90ms'
  '2026-10-25T10:00:09 service=orders method=POST status=500 2988ms'
  '2026-10-25T10:00:12 service=payments method=POST status=503 1500ms'
  '2026-10-25T10:00:20 service=orders method=GET status=500 3100ms'
  '2026-10-25T10:00:25 service=health method=GET status=200 1ms'
  '2026-10-25T10:00:31 service=orders method=POST status=504 5000ms'
  '2026-10-25T10:00:40 service=users method=GET status=200 8ms'
  '2026-10-25T10:00:44 service=payments method=GET status=500 2200ms'
  '2026-10-25T10:00:52 service=users method=POST status=201 30ms'
  '2026-10-25T10:01:00 service=search method=GET status=200 500ms'
)
check "reports/failures.txt = 3 orders, 2 payments, 1 users (A-Z)" \
  '[ "$(norm reports/failures.txt)" = "$(printf "%s\n" "3 service=orders" "2 service=payments" "1 service=users")" ]'
F="$WORK/reports/failures.txt"
if [ -f "$F" ]; then
  grep -q search "$F" && hint "search got in: its 500ms is a time. Filter on 'status=5'"
  grep -q '^ *2 service=orders' "$F" && hint "orders shows 2: 504 is a failure too - match every 5xx, not only 500"
fi
check "reports/top.txt = the orders line (most failures)" '[ "$(norm reports/top.txt)" = "3 service=orders" ]'
check "logs/access.log is unchanged"                     'same logs/access.log "${L[@]}"'
summary
