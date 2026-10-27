#!/usr/bin/env bash
# Drill: build an image (tag + build context) and build from a second Dockerfile with -f.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# clean what this lab creates
docker ps -aq --filter ancestor=hello-cli:1.0 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker ps -aq --filter ancestor=hello-cli:dev 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker image rm -f hello-cli:1.0 hello-cli:dev >/dev/null 2>&1
fresh_work
echo "Hello from the hello-cli image" > greeting.txt
cat > Dockerfile <<'DF'
FROM alpine:3.24
WORKDIR /app
COPY greeting.txt ./
CMD ["cat", "/app/greeting.txt"]
DF
cat > Dockerfile.dev <<'DF'
FROM alpine:3.24
WORKDIR /app
ENV MODE=dev
COPY greeting.txt ./
CMD ["sh", "-c", "echo mode=$MODE; cat /app/greeting.txt"]
DF
banner "01-build-tag (Drill): build hello-cli:1.0 and hello-cli:dev"
