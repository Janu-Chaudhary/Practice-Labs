#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "volume tally-data exists" 'docker volume inspect tally-data'
check "tally-web is running from tally:1.0" '[ "$(docker inspect -f "{{.State.Running}} {{.Config.Image}}" tally-web)" = "true tally:1.0" ]'
check "tally-web publishes 3000 on 127.0.0.1:8082" '[ "$(docker port tally-web 3000/tcp)" = 127.0.0.1:8082 ]'
check "tally-web mounts volume tally-data at /data" 'docker inspect -f "{{range .Mounts}}{{.Type}}:{{.Name}}:{{.Destination}} {{end}}" tally-web | grep -q "volume:tally-data:/data"'
check "limited to half a CPU (--cpus=0.5)" '[ "$(docker inspect -f "{{.HostConfig.NanoCpus}}" tally-web)" = 500000000 ]'
check "limited to 256 MB memory (--memory=256m)" '[ "$(docker inspect -f "{{.HostConfig.Memory}}" tally-web)" = 268435456 ]'
check "count.txt in the volume is 5" 'docker volume inspect tally-data >/dev/null && [ "$(docker run --rm -v tally-data:/data alpine:3.24 cat /data/count.txt)" = 5 ]'
check "current tally-web is a NEW container: its logs show count=5 but not count=4" 'l=$(docker logs tally-web 2>&1); echo "$l" | grep -q "request count=5" && ! echo "$l" | grep -q "request count=4"'
check "answers.txt: no_volume_count= is correct" 'grep -qx "no_volume_count=1" answers.txt'
summary
