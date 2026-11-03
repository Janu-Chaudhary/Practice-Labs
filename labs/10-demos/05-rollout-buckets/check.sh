#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
# value of key in answers.txt: lower case, no spaces, no thousands commas for numbers
ans() { grep -E "^$1=" answers.txt | head -1 | cut -d= -f2- | tr -d ' \r' | tr 'A-Z' 'a-z'; }
num() { ans "$1" | tr -d ','; }
users() { ans "$1" | tr ',' '\n' | grep . | sort | paste -sd, -; }
export -f ans num users
echo "Checking..."
check "1. ON at 10%: meena only (bucket 5 < 10)" '[ "$(users on_at_10)" = meena ]'
check "2. ON at 10%: 1005 of 10,000 users" '[ "$(num count_at_10)" = 1005 ]'
check "3. 10% -> 50%: 0 users turned off (buckets never move)" '[ "$(num turned_off)" = 0 ]'
check "4. overlap of two 10% flags: 99 users (about 1%)" '[ "$(num overlap)" = 99 ]'
check "5. ON at 25%: meena and ravi (buckets 5 and 14)" '[ "$(users on_at_25)" = meena,ravi ]'
check "flags.json is valid JSON with group_order.rollout_percent = 25" \
  'python3 -c "import json,sys; sys.exit(0 if json.load(open(\"flags.json\"))[\"group_order\"][\"rollout_percent\"] == 25 else 1)"'
summary
