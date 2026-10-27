#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
mkdir logs
printf '%s\n' \
  '2026-09-28T09:00:03 service=orders method=GET status=200 11ms' \
  '2026-09-28T09:01:55 service=users method=GET status=200 9ms' \
  '2026-09-28T09:03:29 service=orders method=POST status=500 2987ms' \
  '2026-09-28T09:04:02 service=health method=GET status=200 1ms' \
  '2026-09-28T09:06:48 service=orders method=GET status=500 3104ms' \
  > logs/access.log
printf '%s\n' \
  '2026-09-27T10:00:01 service=orders method=GET status=200 14ms' \
  '2026-09-27T10:02:17 service=orders method=POST status=500 3021ms' \
  '2026-09-27T10:05:40 service=users method=GET status=500 88ms' \
  '2026-09-27T10:09:12 service=orders method=POST status=201 45ms' \
  > logs/access.log.1
banner "05 Quiz 1 Q18 recreation (Quiz-style): orders+500 report, then archive yesterday's log"
