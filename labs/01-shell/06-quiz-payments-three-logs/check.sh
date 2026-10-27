#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
L2=(
  '2026-10-22T14:00:10 service=payments method=POST status=503 1203ms'
  '2026-10-22T14:02:44 service=users method=GET status=503 77ms'
  '2026-10-22T14:05:01 service=payments method=GET status=200 503ms'
)
L1=(
  '2026-10-23T09:10:00 service=payments method=GET status=200 31ms'
  '2026-10-23T09:12:30 service=payments method=POST status=503 1544ms'
  '2026-10-23T09:15:12 service=payments method=POST status=503 1610ms'
)
L0=(
  '2026-10-24T08:00:00 service=health method=GET status=200 1ms'
  '2026-10-24T08:03:21 service=payments method=POST status=503 1388ms'
  '2026-10-24T08:04:00 service=users method=POST status=201 52ms'
)
EXP=("${L2[0]}" "${L1[1]}" "${L1[2]}" "${L0[1]}")
R="$WORK/reports/payments-503.txt"

check "reports/payments-503.txt has the expected 4 lines, oldest first" 'same reports/payments-503.txt "${EXP[@]}"'
if [ -f "$R" ]; then
  grep -q ' 503ms' "$R" && hint "the 503ms line got in: grep 'status=503', not just '503'"
  grep -q '^logs/' "$R" && hint "file names in front: add -h (or grep one file at a time with > then >>)"
fi
check "logs/archive/2026-10/app.log.2 exists, unchanged" 'same logs/archive/2026-10/app.log.2 "${L2[@]}"'
check "logs/archive/2026-10/app.log.1 exists, unchanged" 'same logs/archive/2026-10/app.log.1 "${L1[@]}"'
check "logs/app.log.2 and logs/app.log.1 are gone"       '[ ! -e logs/app.log.2 ] && [ ! -e logs/app.log.1 ]'
check "logs/app.log is still in place and unchanged"     'same logs/app.log "${L0[@]}"'
summary
