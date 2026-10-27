#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "notes-api is still running" '[ "$(docker inspect -f "{{.State.Running}}" notes-api)" = true ]'
check "port= is the host port published for 3000" 'p=$(docker port notes-api 3000/tcp | head -1); grep -qx "port=${p##*:}" answers.txt'
check "token= matches the startup token in the logs" 't=$(docker logs notes-api 2>&1 | sed -n "s/^startup token: //p" | head -1); [ -n "$t" ] && grep -qx "token=$t" answers.txt'
check "motd= matches /tmp/motd.txt inside the container" 'm=$(docker exec notes-api cat /tmp/motd.txt); grep -qx "motd=$m" answers.txt'
check "hostpid= is the host PID of the container main process" 'h=$(docker inspect -f "{{.State.Pid}}" notes-api); grep -qx "hostpid=$h" answers.txt'
summary
