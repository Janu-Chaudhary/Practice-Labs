#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
# same_sorted FILE LINES...: FILE must equal the given lines after `sort` (same locale as the student's sort)
same_sorted() { cmp -s "$1" <(printf '%s\n' "${@:2}" | sort); }
CALLS=(
  'shop/README.md:3:TODO: document issue_refund'
  'shop/app.py:2:from payments.client import charge, issue_refund'
  'shop/app.py:8:    return issue_refund(order_id)'
  'shop/payments/refunds.py:4:    # was called issue_refund in the old design doc'
  'shop/tests/test_refund.py:2:def test_refund_calls_issue_refund():'
)
SECRETS=(shop/.env shop/payments/client.py)
RP="$WORK/reports"

check "reports/refund-calls.txt = the 5 issue_refund lines as path:line:text, sorted" 'same_sorted reports/refund-calls.txt "${CALLS[@]}"'
if [ -f "$RP/refund-calls.txt" ]; then
  grep -q '^\./' "$RP/refund-calls.txt" && hint "paths start with ./ : search the folder by name (shop), not ."
  grep -q '^shop/[^:]*:[^0-9]' "$RP/refund-calls.txt" && hint "no line numbers: add -n"
  [ "$(wc -l < "$RP/refund-calls.txt")" -lt 5 ] && hint "too few lines: -r searches every file, including README.md"
fi
check "reports/refund-defined.txt holds just 0 (issue_refund is never defined)" '[ "$(tr -d " \t\n" < reports/refund-defined.txt)" = 0 ]'
[ -f "$RP/refund-defined.txt" ] && grep -q ':' "$RP/refund-defined.txt" && hint "grep -rc prints one count PER FILE. Count all matching lines together: grep -r ... | wc -l"
check "reports/secret-files.txt = files with a filled-in API_KEY=value, sorted" 'same_sorted reports/secret-files.txt "${SECRETS[@]}"'
if [ -f "$RP/secret-files.txt" ]; then
  grep -q 'env.example' "$RP/secret-files.txt" && hint ".env.example only has an EMPTY STRIPE_API_KEY= : require at least one character after ="
  grep -q 'settings.py' "$RP/secret-files.txt" && hint "settings.py reads the key from the environment (no API_KEY=value): match 'API_KEY=' followed by something"
  grep -q ':' "$RP/secret-files.txt" && hint "only file names wanted: grep -l"
fi
check "reports/todo-count.txt holds just 4 (TODO lines in .py files only)" '[ "$(tr -d " \t\n" < reports/todo-count.txt)" = 4 ]'
[ -f "$RP/todo-count.txt" ] && [ "$(tr -d ' \t\n' < "$RP/todo-count.txt")" = 6 ] && hint "6 includes README.md's TODOs: only .py files count"
check "shop/ is unchanged (still 8 files, app.py intact)" '[ "$(find shop -type f | wc -l)" = 8 ] && grep -qx "    return issue_refund(order_id)" shop/app.py'
summary
