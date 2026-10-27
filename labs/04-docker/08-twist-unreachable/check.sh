#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "image inventory:1.1 exists" 'docker image inspect inventory:1.1'
check "image inventory:1.0 was kept (not deleted)" 'docker image inspect inventory:1.0'
check "container inventory is running from inventory:1.1" '[ "$(docker inspect -f "{{.State.Running}} {{.Config.Image}}" inventory)" = "true inventory:1.1" ]'
check "inventory publishes host 8083 -> 3000" 'docker port inventory 3000/tcp | grep -q ":8083$"'
check "curl http://localhost:8083/health answers ok" 'curl -s --max-time 3 http://localhost:8083/health | grep -qx ok'
summary
