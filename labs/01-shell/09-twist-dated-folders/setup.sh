#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
mkdir incoming
printf '%s\n' \
  '2026-10-24T09:00:00 service=orders method=GET status=200 45ms' \
  '2026-10-24T09:05:00 service=orders method=POST status=500 2500ms' \
  '2026-10-24T09:20:00 service=users method=GET status=200 999ms' \
  > incoming/app-2026-10-24.log
printf '%s\n' \
  '2026-10-24T09:01:00 query=select-orders 1200ms' \
  '2026-10-24T09:30:00 query=update-users 80ms' \
  > incoming/db-2026-10-24.log
printf '%s\n' \
  '2026-10-25T10:00:00 service=orders method=GET status=200 1000ms' \
  '2026-10-25T10:10:00 service=search method=GET status=200 10500ms' \
  > incoming/app-2026-10-25.log
printf '%s\n' \
  '2026-10-25T09:59:00 query=select-search 3400ms' \
  '2026-10-25T10:20:00 query=vacuum 15ms' \
  > incoming/db-2026-10-25.log
printf '%s\n' "Drop zone for log files. Do not delete this file." > incoming/readme.txt
banner "09 dated folders + slow requests (Twist): mkdir -p, mv with *, grep -E, sort"
