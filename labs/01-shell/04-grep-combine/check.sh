#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
A=(
  '2026-10-21T10:00:00 service=orders method=GET status=200 user=7 12ms'
  '2026-10-21T10:00:04 service=orders method=POST status=201 user=71 40ms'
  '2026-10-21T10:00:09 service=users method=POST status=500 user=7 2100ms'
  '2026-10-21T10:00:15 service=orders method=DELETE status=204 user=3 18ms'
  '2026-10-21T10:00:20 service=orders method=POST status=500 user=7 3050ms'
  '2026-10-21T10:00:31 service=users method=GET status=200 user=71 9ms'
)
B=(
  '2026-10-21T11:00:02 service=orders method=GET status=500 user=12 2900ms'
  '2026-10-21T11:00:07 service=users method=DELETE status=200 user=7 15ms'
  '2026-10-21T11:00:11 service=orders method=POST status=201 user=3 33ms'
)
check "orders-post.txt = orders AND POST lines from a.log" 'same orders-post.txt "${A[1]}" "${A[4]}"'
check "all-500.txt = status=500 from a.log then b.log"     'same all-500.txt "${A[2]}" "${A[4]}" "${B[0]}"'
grep -q '^logs/' "$WORK/all-500.txt" 2>/dev/null && hint "lines start with logs/...: - add -h so grep doesn't print file names"
check "get-or-delete.txt = GET or DELETE lines from a.log" 'same get-or-delete.txt "${A[0]}" "${A[3]}" "${A[5]}"'
check "user7.txt = user=7 lines only (not user=71)"        'same user7.txt "${A[0]}" "${A[2]}" "${A[4]}"'
check "logs/a.log is unchanged"                            'same logs/a.log "${A[@]}"'
check "logs/b.log is unchanged"                            'same logs/b.log "${B[@]}"'
summary
