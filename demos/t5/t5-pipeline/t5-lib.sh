# Shared names and helpers for the T5 scripts. Works with macOS bash 3.2.
T5_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # this folder, wherever the script was called from
source "$T5_HOME/../lib/demo-lib.sh"

NET=tiffingo                       # the Docker network every container joins
DB=t5-db                           # the database container
PROXY=t5-proxy                     # the load balancer (Caddy) on localhost:8080
STATE="$T5_HOME/.state"   # Caddyfile + which version is live
APP_DIR="$T5_HOME/app"
DB_URL=postgres://postgres:postgres@$DB:5432/postgres

now_ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time*1000' 2>/dev/null || echo $(( $(date +%s) * 1000 )); }
secs_since() { local t=$(( $(now_ms) - $1 )); printf "%d.%d s" $((t / 1000)) $(( (t % 1000) / 100 )); }
show() { echo "         ${DIM}\$ $*${N}"; }   # print a command the way students would type it
psql_db() { docker exec -i "$DB" psql -U postgres -X -q -v ON_ERROR_STOP=1 "$@"; }

live_name()    { cat "$STATE/live" 2>/dev/null; }
live_version() { local v; v=$(cat "$STATE/live_version" 2>/dev/null); if [ -n "$v" ]; then echo "v$v"; else echo "nothing"; fi; }

# Start a container from image tiffingo:<release>, next to whatever is live.
start_container() {
  local r=$1 name
  name="tiffingo-$(echo "$r" | tr '.' '-')-$(date +%s)"
  show "docker run -d --name $name --network $NET tiffingo:$r"
  docker run -d --name "$name" --network "$NET" -e DATABASE_URL="$DB_URL" "tiffingo:$r" >/dev/null || return 1
  NEW_NAME=$name
}

# Wait until the new container answers /healthz (up to 20 s).
health_check() {
  local name=$1 i out
  show "curl http://$name:3000/healthz"
  for i in $(seq 1 40); do
    out=$(docker exec "$name" wget -qO- http://localhost:3000/healthz 2>/dev/null) && { echo "         $out"; return 0; }
    sleep 0.5
  done
  bad "         no healthy answer after 20 s:"; docker logs --tail 5 "$name"; return 1
}

# Point the load balancer at a container, then stop the old one.
switch_to() {
  local name=$1 version=$2 old
  old=$(live_name)
  write_caddyfile "reverse_proxy $name:3000"
  show "caddy reload   # load balancer now sends traffic to $name"
  docker exec "$PROXY" caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile >/dev/null 2>&1 || return 1
  echo "$name" > "$STATE/live"; echo "$version" > "$STATE/live_version"
  if [ -n "$old" ] && [ "$old" != "$name" ]; then
    sleep 1                                   # let requests already on the old version finish
    docker rm -f "$old" >/dev/null 2>&1
    echo "         old container $old stopped"
  fi
}

write_caddyfile() {
  mkdir -p "$STATE"
  cat > "$STATE/Caddyfile" <<CADDY
{
	admin localhost:2019
	auto_https off
}
:8080 {
	$1
}
CADDY
}

# ---- Coloured code for the projector ---------------------------------------
# show_diff old new ['regex::note' ...]
#   Removed lines red, added lines green, the rest dim. A line matching a regex
#   gets bold yellow and "◀ note" after it, so you can point at it.
show_diff() {
  local a=$1 b=$2 marks=""; shift 2
  for m in "$@"; do marks="$marks$m@@@"; done
  diff -u "$a" "$b" | tail -n +3 | awk -v marks="$marks" -v G="$G" -v R="$R" -v C="$C" \
      -v Y="$Y" -v B="$B" -v DIM="$DIM" -v N="$N" '
    BEGIN { n = split(marks, m, "@@@") }
    {
      note = ""
      for (i = 1; i < n; i++) {
        split(m[i], p, "::")
        if ($0 ~ p[1]) note = p[2]
      }
      c = substr($0, 1, 1)
      if (substr($0, 1, 2) == "@@") { print C $0 N; next }
      if (note != "")      print B Y $0 "   ◀ " note N
      else if (c == "+")   print G $0 N
      else if (c == "-")   print R $0 N
      else                 print DIM $0 N
    }'
}

# show_sql file
#   Comments dim. Safe changes green, changes that break old code red,
#   new tables cyan, each with a short note.
show_sql() {
  awk -v G="$G" -v R="$R" -v C="$C" -v B="$B" -v DIM="$DIM" -v N="$N" '
    /^ *--/                         { print DIM $0 N; next }
    /RENAME COLUMN|DROP COLUMN|DROP TABLE/ { print B R $0 "   ◀ breaks code that still uses the old name" N; next }
    /ADD COLUMN/                    { print B G $0 "   ◀ safe: old code ignores the new column" N; next }
    /CREATE TABLE/                  { print C $0 "   ◀ new table" N; next }
    /INSERT INTO flags/             { print C $0 "   ◀ the flag starts OFF" N; next }
                                    { print $0 }' "$1"
}
