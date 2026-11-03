#!/usr/bin/env bash
# The pipeline: ./deploy.sh 2.4
# Test, build the image, migrate, start beside the old version, check health, switch traffic.
cd "$(dirname "$0")" || exit 1
source ./t5-lib.sh
need_docker

REL=${1:?usage: ./deploy.sh <release>   (2.3, 2.4, 2.4-rename, 2.5)}
[ -d "app/releases/$REL" ] || { bad "No release $REL in app/releases/"; exit 1; }
T0=$(now_ms)
fail() { bad "  ✗ $*"; bad "Pipeline stopped. Production is unchanged: still $(live_version)."; exit 1; }

echo "${B}Deploying TiffinGo v$REL${N}   (live now: $(live_version))"

echo "${B}[1/6] Test${N}          unit tests in a fresh container"
show "docker run --rm node:22-alpine node --test common/pricing.test.js"
out=$(docker run --rm -v "$APP_DIR/common:/t:ro" -w /t node:22-alpine node --test pricing.test.js 2>&1) \
  || { echo "$out" | tail -15; fail "tests failed"; }
echo "         $(echo "$out" | grep -E '^# pass' | awk '{print $3}') tests passed"

ID=$(cd app && cat Dockerfile package.json common/*.js releases/"$REL"/* | { shasum 2>/dev/null || sha1sum; } | cut -c1-7)   # Linux note: sha1sum if no shasum (same SHA-1)
echo "${B}[2/6] Build${N}         one image, tagged with the version and the code's id"
show "docker build -t tiffingo:$REL -t tiffingo:$ID ."
docker build -q --build-arg RELEASE="$REL" -t "tiffingo:$REL" -t "tiffingo:$ID" app >/dev/null || fail "build failed"
echo "         tiffingo:$REL = tiffingo:$ID"

echo "${B}[3/6] Migrate${N}       releases/$REL/migrate.sql"
if [ -n "$(psql_db -tAc "SELECT 1 FROM schema_migrations WHERE version = '$REL'")" ]; then
  echo "         already applied"
else
  show_sql "app/releases/$REL/migrate.sql" | sed 's/^/         /'
  mout=$(psql_db < "app/releases/$REL/migrate.sql" 2>&1) || { echo "$mout"; fail "migration failed"; }
  psql_db -c "INSERT INTO schema_migrations (version) VALUES ('$REL');"
fi

echo "${B}[4/6] Deploy${N}        start v$REL beside the old version (old one still serving)"
start_container "$REL" || fail "could not start the container"

echo "${B}[5/6] Check health${N}"
health_check "$NEW_NAME" || { docker rm -f "$NEW_NAME" >/dev/null; fail "new version is not healthy"; }

echo "${B}[6/6] Switch${N}        send traffic to v$REL"
switch_to "$NEW_NAME" "$REL" || fail "could not switch the load balancer"

ok "Deployed v$REL in $(secs_since "$T0")."
