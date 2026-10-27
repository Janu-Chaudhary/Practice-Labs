#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
ctr() { docker ps -q --filter ancestor=counter:1.0 --filter status=running 2>/dev/null; }
check "image counter:1.0 was built" 'docker image inspect counter:1.0'
check "volume counter-data exists" 'docker volume inspect counter-data'
check "a running container from counter:1.0 publishes port 8080 to 3000" 'for c in $(ctr); do docker port $c 3000/tcp; done | grep -q ":8080$"'
check "a running container from counter:1.0 mounts counter-data at /data" 'for c in $(ctr); do docker inspect -f "{{range .Mounts}}{{.Type}}:{{.Name}}:{{.Destination}} {{end}}" $c; done | grep -q "volume:counter-data:/data"'
check "curl http://localhost:8080/health answers ok" 'curl -s --max-time 3 http://localhost:8080/health | grep -qx ok'
summary
