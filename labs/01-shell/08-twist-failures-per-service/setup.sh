#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
mkdir logs
printf '%s\n' \
  '2026-10-25T10:00:01 service=orders method=GET status=200 12ms' \
  '2026-10-25T10:00:05 service=users method=GET status=502 90ms' \
  '2026-10-25T10:00:09 service=orders method=POST status=500 2988ms' \
  '2026-10-25T10:00:12 service=payments method=POST status=503 1500ms' \
  '2026-10-25T10:00:20 service=orders method=GET status=500 3100ms' \
  '2026-10-25T10:00:25 service=health method=GET status=200 1ms' \
  '2026-10-25T10:00:31 service=orders method=POST status=504 5000ms' \
  '2026-10-25T10:00:40 service=users method=GET status=200 8ms' \
  '2026-10-25T10:00:44 service=payments method=GET status=500 2200ms' \
  '2026-10-25T10:00:52 service=users method=POST status=201 30ms' \
  '2026-10-25T10:01:00 service=search method=GET status=200 500ms' \
  > logs/access.log
banner "08 failures per service (Twist): grep | cut | sort | uniq -c"
