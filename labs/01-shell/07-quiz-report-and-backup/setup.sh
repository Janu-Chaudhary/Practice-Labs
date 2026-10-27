#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
mkdir logs
printf '%s\n' \
  '2026-10-25T07:59:58 level=INFO service=api msg="boot"' \
  '2026-10-25T08:00:12 level=WARN service=db msg="pool at 90%"' \
  '2026-10-25T08:00:40 level=ERROR service=api msg="upstream timeout"' \
  '2026-10-25T08:01:05 level=INFO service=api msg="request ok"' \
  '2026-10-25T08:02:17 level=ERROR service=db msg="deadlock detected"' \
  '2026-10-25T08:02:20 level=DEBUG service=db msg="ERROR count reset"' \
  '2026-10-25T08:03:33 level=WARN service=api msg="retry 1"' \
  '2026-10-25T08:04:00 level=INFO service=api msg="request ok"' \
  > logs/app.log
printf '%s\n' "On-call notes" "2026-10-24 checked by Sam" > notes.txt
banner "07 report and backup (Quiz-style): -E, -c, cp into new folder, add a note in the editor"
