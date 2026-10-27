#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 04-baseline"
q() { sqlite3 shop.db "$1"; }
check "history table exists" 'q "SELECT 1 FROM flyway_schema_history LIMIT 1"'
check "history has a BASELINE row at version 02" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE type='"'BASELINE'"' AND version='"'02'"'")" = 1 ]'
check "01 and 02 were NOT re-run (no SQL rows for them)" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE type='"'SQL'"' AND version IN ('"'01'"','"'02'"')")" = 0 ]'
check "03 applied by flyway (Success)" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'03'"' AND success=1 AND type='"'SQL'"'")" = 1 ]'
check "orders still has its 3 rows" '[ "$(q "SELECT count(*) FROM orders")" = 3 ]'
check "every order has currency INR" '[ "$(q "SELECT count(*) FROM orders WHERE currency='"'INR'"'")" = 3 ]'
summary
