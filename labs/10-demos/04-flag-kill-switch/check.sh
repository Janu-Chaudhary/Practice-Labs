#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_t5.sh"
need_docker
echo "Checking..."
check "v2.5 is live: /healthz says version 2.5" 'hz | grep -q "\"version\":\"2.5\""'
check "exactly one app container runs, from image tiffingo:2.5" \
  '[ "$(running_app | wc -l)" -eq 1 ] && running_app | grep -q " tiffingo:2.5$"'
check "the flag was ON while traffic ran: traffic.log shows ERROR ... reading 'map' ... (v2.5)" \
  'grep -q "ERROR.*reading .map.*(v2.5)" traffic.log'
check "same container, no redeploy: the live container's own docker logs show that error" \
  'docker logs "$(running_app | cut -d" " -f1)" 2>&1 | grep -q "reading .map."'
check "kill switch used: flag group_order is OFF in the flags table" \
  '[ "$(sql "SELECT enabled FROM flags WHERE name = '"'"'group_order'"'"'")" = f ]'
check "kabir's group order answers ok again (served as a single order, v2.5)" \
  'co "customer=kabir&group=1" | grep -q "^ok .*single.*(v2.5)"'
summary
