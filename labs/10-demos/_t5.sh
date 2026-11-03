# Shared helpers for the 10-demos stages. Sourced by setup.sh / check.sh AFTER common.sh.
# The stages run the professor's own scripts from demos/t5, copied into work/ so the
# terminal and the Files panel can see them.
T5_SRC="$(cd "$LAB_DIR/../../../demos/t5" && pwd)"
TOPIC_DIR="$(cd "$LAB_DIR/.." && pwd)"

# Stop any ./traffic.sh loop started from a 10-demos work/ folder (it runs in the background).
stop_traffic() {
  local pid cwd script
  for pid in $(pgrep -f 'traffic\.sh' 2>/dev/null); do
    # only a bash that is running a traffic.sh script (argv[1]), not any command mentioning it
    script=$(tr '\0' '\n' < "/proc/$pid/cmdline" 2>/dev/null | sed -n 2p)
    case "$script" in traffic.sh|*/traffic.sh) ;; *) continue ;; esac
    cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null) || continue
    case "$cwd" in "$TOPIC_DIR"/*) kill "$pid" 2>/dev/null ;; esac
  done
}

# The base images must be on this machine (demos/t5/preflight.sh pulls them).
need_images() {
  local img missing=""
  for img in node:22-alpine caddy:2.8.4-alpine postgres:16-alpine; do
    docker image inspect "$img" >/dev/null 2>&1 || missing="$missing $img"
  done
  if [ -n "$missing" ]; then
    echo "${R}Missing Docker images:${N}$missing"
    echo "Run this once (on good Wi-Fi, takes a few minutes), then press Reset lab again:"
    echo "  ${B}$T5_SRC/preflight.sh${N}"
    exit 1
  fi
}

port_8080_busy() { ss -ltnH 'sport = :8080' 2>/dev/null | grep -q .; }

# Reset the demo (the demos' own reset.sh), then a fresh work/ with the pipeline scripts.
t5_fresh_pipeline() {
  need_docker
  need_images
  stop_traffic
  bash "$T5_SRC/t5-pipeline/reset.sh" >/dev/null 2>&1
  if port_8080_busy; then
    echo "${R}Port 8080 is in use by another program:${N}"
    ss -ltnpH 'sport = :8080' 2>/dev/null
    echo "Stop it (or run $T5_SRC/reset-all.sh), then press Reset lab again."
    exit 1
  fi
  fresh_work
  cp -r "$T5_SRC/t5-pipeline/app" .
  for f in setup.sh deploy.sh rollback.sh flag.sh traffic.sh reset.sh t5-lib.sh; do
    cp "$T5_SRC/t5-pipeline/$f" .
  done
  mkdir lib && cp "$T5_SRC/lib/demo-lib.sh" lib/
  # the only change to the copies: lib/ sits inside work/ instead of next to it
  sed -i 's#\$T5_HOME/\.\./lib/demo-lib\.sh#$T5_HOME/lib/demo-lib.sh#' t5-lib.sh
  sed -i 's#^source \.\./lib/demo-lib\.sh#source lib/demo-lib.sh#' traffic.sh
  chmod +x ./*.sh
}

# Bring the platform up and deploy v2.3 (start state of stages 2-4).
t5_up_with_23() {
  echo "Starting the platform (./setup.sh) ..."
  ./setup.sh >/dev/null 2>&1 || { echo "${R}./setup.sh failed${N}"; exit 1; }
  echo "Deploying v2.3 (./deploy.sh 2.3) ..."
  ./deploy.sh 2.3 >/dev/null 2>&1 || { echo "${R}./deploy.sh 2.3 failed${N}"; exit 1; }
  echo "Live: $(curl -s -m 3 http://localhost:8080/healthz)"
}

# ---- helpers for check.sh ----
hz()  { curl -s -m 3 http://localhost:8080/healthz; }
co()  { curl -s -m 5 "http://localhost:8080/checkout?$1"; }
sql() { docker exec t5-db psql -U postgres -X -tAc "$1"; }
# "name image" of every running app container
running_app() { docker ps --format '{{.Names}} {{.Image}}' | grep '^tiffingo-'; }
