#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_t5.sh"
need_docker
COLS="SELECT column_name FROM information_schema.columns WHERE table_name = 'orders'"
export COLS
echo "Checking..."
check "2.4-rename went through the pipeline: its migration is in schema_migrations" \
  'sql "SELECT version FROM schema_migrations" | grep -qx 2.4-rename'
check "traffic.log shows the trap: ERROR column \"items\" ... does not exist (v2.3)" \
  'grep -q "ERROR.*column \"items\".*does not exist.*(v2.3)" traffic.log'
check "rolled back: /healthz says version 2.3" 'hz | grep -q "\"version\":\"2.3\""'
check "exactly one app container runs, from image tiffingo:2.3" \
  '[ "$(running_app | wc -l)" -eq 1 ] && running_app | grep -q " tiffingo:2.3$"'
check "fixed forward: the orders table has the column items again" 'sql "$COLS" | grep -qx items'
check "the column order_items is gone (renamed back, not added twice)" '! sql "$COLS" | grep -qx order_items'
check "checkouts work again: asha and kabir's group order answer ok (v2.3)" \
  'co "customer=asha&group=0" | grep -q "^ok .*(v2.3)" && co "customer=kabir&group=1" | grep -q "^ok .*(v2.3)"'
summary
