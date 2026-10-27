#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
TODAY=(
  '2026-09-28T09:00:03 service=orders method=GET status=200 11ms'
  '2026-09-28T09:01:55 service=users method=GET status=200 9ms'
  '2026-09-28T09:03:29 service=orders method=POST status=500 2987ms'
  '2026-09-28T09:04:02 service=health method=GET status=200 1ms'
  '2026-09-28T09:06:48 service=orders method=GET status=500 3104ms'
)
YDAY=(
  '2026-09-27T10:00:01 service=orders method=GET status=200 14ms'
  '2026-09-27T10:02:17 service=orders method=POST status=500 3021ms'
  '2026-09-27T10:05:40 service=users method=GET status=500 88ms'
  '2026-09-27T10:09:12 service=orders method=POST status=201 45ms'
)
EXP=("${YDAY[1]}" "${TODAY[2]}" "${TODAY[4]}")

check "reports/orders-500.txt has the expected content" 'same reports/orders-500.txt "${EXP[@]}"'
if [ -f "$WORK/reports/orders-500.txt" ]; then
  grep -q 'logs/' "$WORK/reports/orders-500.txt" && hint "file names in the lines: use -h, or grep each log separately (> then >>)"
  grep -q 'users' "$WORK/reports/orders-500.txt" && hint "users lines got in: the second grep must read the pipe, so don't give it a file"
  head -n1 "$WORK/reports/orders-500.txt" | grep -q '09-28' && hint "today's lines came first: yesterday (access.log.1) must come first"
fi
check "logs/archive/access.log.1 exists with its original contents" 'same logs/archive/access.log.1 "${YDAY[@]}"'
check "logs/access.log.1 is gone"                        '[ ! -e logs/access.log.1 ]'
check "logs/access.log is still there and unchanged"     'same logs/access.log "${TODAY[@]}"'
summary
