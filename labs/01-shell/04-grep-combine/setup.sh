#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
mkdir logs
printf '%s\n' \
  '2026-10-21T10:00:00 service=orders method=GET status=200 user=7 12ms' \
  '2026-10-21T10:00:04 service=orders method=POST status=201 user=71 40ms' \
  '2026-10-21T10:00:09 service=users method=POST status=500 user=7 2100ms' \
  '2026-10-21T10:00:15 service=orders method=DELETE status=204 user=3 18ms' \
  '2026-10-21T10:00:20 service=orders method=POST status=500 user=7 3050ms' \
  '2026-10-21T10:00:31 service=users method=GET status=200 user=71 9ms' \
  > logs/a.log
printf '%s\n' \
  '2026-10-21T11:00:02 service=orders method=GET status=500 user=12 2900ms' \
  '2026-10-21T11:00:07 service=users method=DELETE status=200 user=7 15ms' \
  '2026-10-21T11:00:11 service=orders method=POST status=201 user=3 33ms' \
  > logs/b.log
banner "04 combining greps (Drill): AND with |, OR with -E, -h, -w"
