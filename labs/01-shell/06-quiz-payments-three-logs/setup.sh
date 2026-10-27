#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
mkdir logs
printf '%s\n' \
  '2026-10-22T14:00:10 service=payments method=POST status=503 1203ms' \
  '2026-10-22T14:02:44 service=users method=GET status=503 77ms' \
  '2026-10-22T14:05:01 service=payments method=GET status=200 503ms' \
  > logs/app.log.2
printf '%s\n' \
  '2026-10-23T09:10:00 service=payments method=GET status=200 31ms' \
  '2026-10-23T09:12:30 service=payments method=POST status=503 1544ms' \
  '2026-10-23T09:15:12 service=payments method=POST status=503 1610ms' \
  > logs/app.log.1
printf '%s\n' \
  '2026-10-24T08:00:00 service=health method=GET status=200 1ms' \
  '2026-10-24T08:03:21 service=payments method=POST status=503 1388ms' \
  '2026-10-24T08:04:00 service=users method=POST status=201 52ms' \
  > logs/app.log
banner "06 three logs (Quiz-style): payments+503 oldest first, archive the rotated logs"
