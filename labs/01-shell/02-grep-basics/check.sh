#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
L=(
  '2026-10-20T08:00:01 level=INFO service=api msg="started"'
  '2026-10-20T08:00:05 level=WARN service=api msg="slow response"'
  '2026-10-20T08:01:10 level=ERROR service=db msg="connection refused"'
  '2026-10-20T08:01:12 level=INFO service=health msg="ok"'
  '2026-10-20T08:02:30 level=error service=api msg="timeout"'
  '2026-10-20T08:03:00 level=INFO service=health msg="ok"'
  '2026-10-20T08:03:45 level=WARN service=db msg="retrying"'
  '2026-10-20T08:04:10 level=ERROR service=api msg="bad gateway"'
)
ERR=("${L[2]}" "${L[4]}" "${L[7]}")
NOH=("${L[0]}" "${L[1]}" "${L[2]}" "${L[4]}" "${L[6]}" "${L[7]}")
DBN=("3:${L[2]}" "7:${L[6]}")

check "errors.txt = all 3 error lines (ERROR and error)" 'same errors.txt "${ERR[@]}"'
[ -f "$WORK/errors.txt" ] && [ "$(wc -l < "$WORK/errors.txt")" = 2 ] && hint "only 2 lines? grep is case-sensitive - add -i"
check "warn-count.txt holds just the number 2"           'same warn-count.txt 2'
check "no-health.txt = every line except service=health" 'same no-health.txt "${NOH[@]}"'
check "db-numbered.txt = db lines with line numbers"     'same db-numbered.txt "${DBN[@]}"'
check "app.log is unchanged"                             'same app.log "${L[@]}"'
summary
