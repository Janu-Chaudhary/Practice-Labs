#!/usr/bin/env bash
# Go back by redeploying an image that already exists: ./rollback.sh 2.3
# No test, no build, no migration. That is why it is fast.
cd "$(dirname "$0")" || exit 1
source ./t5-lib.sh
need_docker

REL=${1:?usage: ./rollback.sh <release>}
docker image inspect "tiffingo:$REL" >/dev/null 2>&1 || { bad "No image tiffingo:$REL. It was never built."; exit 1; }
T0=$(now_ms)

echo "${B}Rolling back to v$REL${N} from image tiffingo:$REL   (live now: $(live_version))"
echo "${DIM}         nothing to test, build or migrate: the image already exists${N}"
echo "${B}[1/3] Start${N}";        start_container "$REL" || exit 1
echo "${B}[2/3] Check health${N}"; health_check "$NEW_NAME" || exit 1
echo "${B}[3/3] Switch${N}";       switch_to "$NEW_NAME" "$REL" || exit 1
ok "${B}Back on v$REL in $(secs_since "$T0").${N}"
