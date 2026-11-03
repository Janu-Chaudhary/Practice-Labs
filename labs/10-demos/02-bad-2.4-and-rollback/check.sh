#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_t5.sh"
need_docker
echo "Checking..."
check "v2.4 went through the pipeline: image tiffingo:2.4 exists" 'docker image inspect tiffingo:2.4'
check "traffic.log shows the v2.4 bug (ERROR ... reading 'map' ... (v2.4))" 'grep -q "ERROR.*reading .map.*(v2.4)" traffic.log'
check "rolled back: http://localhost:8080/healthz says version 2.3" 'hz | grep -q "\"version\":\"2.3\""'
check "exactly one app container runs, from image tiffingo:2.3 (none from 2.4)" \
  '[ "$(running_app | wc -l)" -eq 1 ] && running_app | grep -q " tiffingo:2.3$"'
check "the database was NOT rolled back: the 2.4 migration is still in schema_migrations" \
  'sql "SELECT version FROM schema_migrations" | grep -qx 2.4'
check "the column group_id (added by 2.4) is still in the orders table" \
  'sql "SELECT column_name FROM information_schema.columns WHERE table_name = '"'"'orders'"'"'" | grep -qx group_id'
check "kabir's group order works again: ok ... (v2.3)" 'co "customer=kabir&group=1" | grep -q "^ok .*(v2.3)"'
summary
