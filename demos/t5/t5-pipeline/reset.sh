#!/usr/bin/env bash
# Remove everything the T5 demo created: containers, network, images, state.
cd "$(dirname "$0")" || exit 1
source ./t5-lib.sh

for c in $(docker ps -a --format '{{.Names}}' | grep -E '^(tiffingo-|t5-db$|t5-proxy$)'); do
  docker rm -f "$c" >/dev/null && echo "removed container $c"
done
docker network rm "$NET" >/dev/null 2>&1 && echo "removed network $NET"
imgs=$(docker images tiffingo -q | sort -u)
[ -n "$imgs" ] && docker rmi -f $imgs >/dev/null 2>&1 && echo "removed tiffingo images"
rm -rf "$STATE"
ok "T5 demo reset."
