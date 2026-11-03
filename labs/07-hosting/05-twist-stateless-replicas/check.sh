#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "server.js stores the count under /data" 'grep -q "/data" server.js'
check "image lab75-web:1.1 exists" 'docker image inspect lab75-web:1.1'
for r in lab75-web-1 lab75-web-2; do
  check "$r runs lab75-web:1.1 on lab75-net" "[ \"\$(docker inspect -f '{{.State.Running}} {{.Config.Image}}' $r)\" = 'true lab75-web:1.1' ] && docker inspect -f '{{json .NetworkSettings.Networks}}' $r | grep -q '\"lab75-net\"'"
  check "$r mounts the named volume lab75-data at /data" "docker inspect -f '{{range .Mounts}}{{.Type}}:{{.Name}}:{{.Destination}} {{end}}' $r | grep -q 'volume:lab75-data:/data'"
done
check "load balancer lab75-lb is running on 127.0.0.1:8350" '[ "$(docker inspect -f "{{.State.Running}}" lab75-lb)" = true ] && [ "$(docker port lab75-lb 80/tcp)" = 127.0.0.1:8350 ]'
# 6 requests through the LB: counts must go up by exactly 1 each time, and both replicas must answer
check "6 requests through the LB: visits go up 1 by 1, answered by both replicas" '
  out=$(for i in 1 2 3 4 5 6; do curl -s --max-time 3 http://127.0.0.1:8350/; done)
  [ "$(echo "$out" | grep -c "^visits=[0-9]* served-by=")" -eq 6 ] || exit 1
  nums=$(echo "$out" | sed -E "s/^visits=([0-9]+) .*/\1/")
  first=$(echo "$nums" | head -1)
  [ "$nums" = "$(seq "$first" $((first+5)))" ] || exit 1
  [ "$(echo "$out" | sed -E "s/.*served-by=//" | sort -u | wc -l)" -eq 2 ]'
summary
