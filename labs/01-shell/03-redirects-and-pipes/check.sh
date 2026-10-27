#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
# typed in the editor: a missing newline after the last line is fine
typed() { [ -f "$1" ] && [ "$(cat "$1")" = "$(printf '%s\n' "${@:2}")" ]; }
V=(maya liam zoe maya arjun liam maya ben)

check "hello.txt = 'first line' then 'second line'" 'typed hello.txt "first line" "second line"'
[ -f "$WORK/hello.txt" ] && [ ! -s "$WORK/hello.txt" ] && hint "hello.txt is empty on disk: save it in the editor with Ctrl+S"
check "top3.txt = first 3 visitors"                 'same top3.txt maya liam zoe'
check "line-count.txt holds just the number 8"      '[ "$(tr -d " \t\n" < line-count.txt)" = 8 ]'
grep -q visitors "$WORK/line-count.txt" 2>/dev/null && hint "the file name got in: use  wc -l < visitors.txt  or  cat visitors.txt | wc -l"
check "unique.txt = each name once, A-Z"            'same unique.txt arjun ben liam maya zoe'
check "visitors.txt is unchanged"                   'same visitors.txt "${V[@]}"'
summary
