#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
printf '%s\n' \
  '2026-10-20T08:00:01 level=INFO service=api msg="started"' \
  '2026-10-20T08:00:05 level=WARN service=api msg="slow response"' \
  '2026-10-20T08:01:10 level=ERROR service=db msg="connection refused"' \
  '2026-10-20T08:01:12 level=INFO service=health msg="ok"' \
  '2026-10-20T08:02:30 level=error service=api msg="timeout"' \
  '2026-10-20T08:03:00 level=INFO service=health msg="ok"' \
  '2026-10-20T08:03:45 level=WARN service=db msg="retrying"' \
  '2026-10-20T08:04:10 level=ERROR service=api msg="bad gateway"' \
  > app.log
banner "02 grep basics (Drill): grep, -i, -c, -v, -n, > "
