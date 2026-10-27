#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
# edited in the editor: a missing newline after the last line is fine
typed() { [ -f "$1" ] && [ "$(cat "$1")" = "$(printf '%s\n' "${@:2}")" ]; }
L=(
  '2026-10-25T07:59:58 level=INFO service=api msg="boot"'
  '2026-10-25T08:00:12 level=WARN service=db msg="pool at 90%"'
  '2026-10-25T08:00:40 level=ERROR service=api msg="upstream timeout"'
  '2026-10-25T08:01:05 level=INFO service=api msg="request ok"'
  '2026-10-25T08:02:17 level=ERROR service=db msg="deadlock detected"'
  '2026-10-25T08:02:20 level=DEBUG service=db msg="ERROR count reset"'
  '2026-10-25T08:03:33 level=WARN service=api msg="retry 1"'
  '2026-10-25T08:04:00 level=INFO service=api msg="request ok"'
)
P=("${L[1]}" "${L[2]}" "${L[4]}" "${L[6]}")

check "reports/problems.txt = the 4 WARN/ERROR lines"      'same reports/problems.txt "${P[@]}"'
grep -q DEBUG "$WORK/reports/problems.txt" 2>/dev/null && hint "the DEBUG line got in: match 'level=ERROR', not just 'ERROR'"
check "reports/error-count.txt holds just 2"               'same reports/error-count.txt 2'
check "backup/app-2026-10-25.log is an identical copy"     'same backup/app-2026-10-25.log "${L[@]}"'
check "notes.txt = 2 old lines + '2026-10-25 checked by me'" 'typed notes.txt "On-call notes" "2026-10-24 checked by Sam" "2026-10-25 checked by me"'
[ -f "$WORK/notes.txt" ] && ! grep -q "checked by Sam" "$WORK/notes.txt" && hint "notes.txt lost its old lines: keep them and add the new line at the end"
[ -f "$WORK/notes.txt" ] && ! grep -q "checked by me" "$WORK/notes.txt" && hint "the new line is missing: did you save notes.txt with Ctrl+S?"
check "logs/app.log is unchanged and still in logs/"       'same logs/app.log "${L[@]}"'
summary
