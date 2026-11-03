#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "lab72-api has restart policy unless-stopped" '[ "$(docker inspect -f "{{.HostConfig.RestartPolicy.Name}}" lab72-api)" = unless-stopped ]'
check "lab72-api is the original container (changed in place, not recreated: still has --init)" '[ "$(docker inspect -f "{{.HostConfig.Init}}" lab72-api)" = true ]'
check "lab72-api crashed and Docker restarted it (RestartCount >= 1, running)" '[ "$(docker inspect -f "{{.State.Running}}" lab72-api)" = true ] && [ "$(docker inspect -f "{{.RestartCount}}" lab72-api)" -ge 1 ]'
check "lab72-migrate runs lab72-jobs:1.0 with volume lab72-state at /state" '[ "$(docker inspect -f "{{.Config.Image}}" lab72-migrate)" = lab72-jobs:1.0 ] && docker inspect -f "{{range .Mounts}}{{.Name}}:{{.Destination}} {{end}}" lab72-migrate | grep -q "lab72-state:/state"'
check "lab72-migrate has restart policy on-failure" '[ "$(docker inspect -f "{{.HostConfig.RestartPolicy.Name}}" lab72-migrate)" = on-failure ]'
check "lab72-migrate retried until it succeeded and then stayed finished (exited, code 0)" '[ "$(docker inspect -f "{{.State.Status}} {{.State.ExitCode}}" lab72-migrate)" = "exited 0" ] && [ "$(docker inspect -f "{{.RestartCount}}" lab72-migrate)" -ge 2 ]'
check "lab72-legacy was stopped by hand and stayed stopped (not removed)" '[ "$(docker inspect -f "{{.State.Status}}" lab72-legacy)" = exited ]'
summary
