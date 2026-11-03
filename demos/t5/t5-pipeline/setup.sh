#!/usr/bin/env bash
# Start the "platform": a network, Postgres, and a load balancer on localhost:8080.
cd "$(dirname "$0")" || exit 1
source ./t5-lib.sh
need_docker

if docker ps -a --format '{{.Names}}' | grep -qx "$DB"; then
  bad "Already set up. Run ./reset.sh first for a clean start."; exit 1
fi

echo "Network:       $NET";   docker network create "$NET" >/dev/null
echo "Database:      $DB (postgres:16-alpine)"
docker run -d --name "$DB" --network "$NET" -e POSTGRES_PASSWORD=postgres postgres:16-alpine >/dev/null
until docker exec "$DB" pg_isready -U postgres -h 127.0.0.1 >/dev/null 2>&1; do sleep 1; done
psql_db -c "CREATE TABLE schema_migrations (version text PRIMARY KEY, applied_at timestamptz DEFAULT now());"

echo "Load balancer: $PROXY (caddy) on http://localhost:8080"
write_caddyfile 'respond "TiffinGo: nothing deployed yet" 503'
rm -f "$STATE/live" "$STATE/live_version"
docker run -d --name "$PROXY" --network "$NET" -p 8080:8080 -v "$STATE:/etc/caddy" caddy:2.8.4-alpine >/dev/null
sleep 1
ok "Platform ready. Nothing deployed yet."
