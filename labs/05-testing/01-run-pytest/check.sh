#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 01-run-pytest"
line() { sed -n "${1}p" answer.txt | tr -d '[:space:]'; }
check "answer.txt exists" '[ -f answer.txt ]'
check "line 1: the name of the failing test" '[ "$(line 1 | sed "s/.*:://")" = test_total_with_tax_adds_15_percent ]'
check "line 2: the exit code pytest returned" '[ "$(line 2)" = 1 ]'
check "line 3: how many tests passed" '[ "$(line 3)" = 5 ]'
check "line 4: the value total_with_tax([100]) actually returned" 'python3 -c "import sys; sys.exit(0 if abs(float(\"$(line 4)\")-15.0)<1e-9 else 1)"'
check "cart.py and test_cart.py not changed (you only read the output)" 'git diff --quiet HEAD -- cart.py test_cart.py'
summary
