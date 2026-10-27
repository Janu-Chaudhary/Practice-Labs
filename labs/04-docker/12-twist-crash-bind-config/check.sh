#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
mnt() { docker inspect -f '{{range .Mounts}}{{if eq .Destination "/config"}}{{.Type}}|{{.Source}}|{{.RW}}{{end}}{{end}}' lab12-report; }
check "answers.txt: first_exit_code= is the exit code of the first crash" 'grep -qx "first_exit_code=3" answers.txt'
check "config/settings.json is valid JSON with title \"Weekly report\"" 'docker run --rm -i node:24-alpine node -e "const c=JSON.parse(require(\"fs\").readFileSync(0,\"utf8\")); process.exit(c.title===\"Weekly report\"?0:1)" < config/settings.json'
check "lab12-report is running from lab12-report:1.0 (no rebuild)" '[ "$(docker inspect -f "{{.State.Running}} {{.Config.Image}}" lab12-report)" = "true lab12-report:1.0" ]'
check "lab12-report publishes 3000 on 127.0.0.1:8112" '[ "$(docker port lab12-report 3000/tcp)" = 127.0.0.1:8112 ]'
check "work/config is BIND-mounted at /config" 'm=$(mnt); t=$(echo "$m" | cut -d"|" -f1); s=$(echo "$m" | cut -d"|" -f2); [ "$t" = bind ] && { [ "$s" = "$(pwd -P)/config" ] || [ "$s" = "$(pwd)/config" ]; }'
check "the /config mount is read-only" '[ "$(mnt | cut -d"|" -f3)" = false ]'
check "curl http://127.0.0.1:8112/ answers: report: Weekly report" 'curl -s --max-time 3 http://127.0.0.1:8112/ | grep -qx "report: Weekly report"'
check "same container served \"Daily report\" first, then was restarted for \"Weekly report\"" 'l=$(docker logs lab12-report 2>&1); echo "$l" | grep -q "title=\"Daily report\"" && echo "$l" | grep -q "title=\"Weekly report\""'
summary
