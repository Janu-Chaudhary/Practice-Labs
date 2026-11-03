# Shared helpers for every demo.sh. Works with the bash 3.2 that ships on macOS.
# Usage inside a demo:  source "$(dirname "$0")/../lib/demo-lib.sh"

if [ -t 1 ]; then
  B=$'\033[1m'; DIM=$'\033[2m'; R=$'\033[31m'; G=$'\033[32m'
  Y=$'\033[33m'; C=$'\033[36m'; N=$'\033[0m'
else
  B=""; DIM=""; R=""; G=""; Y=""; C=""; N=""
fi

# Big title at the start of a demo.
banner() {
  echo
  echo "${B}${C}==============================================================${N}"
  echo "${B}${C}  $1${N}"
  echo "${B}${C}==============================================================${N}"
}

# One step: a number, a title, and a one-line caption the class can read.
step() {
  echo
  echo "${B}${Y}--- STEP $1 · $2 ---${N}"
  [ -n "${3:-}" ] && echo "${DIM}$3${N}"
  echo
}

# Show a command on screen, then run it.
run() {
  echo "${B}\$ $*${N}"
  eval "$@"
}

# Wait for the presenter. Ctrl-C leaves everything running.
pause() {
  [ "${DEMO_NOPAUSE:-}" = 1 ] && return 0
  echo
  printf "%s" "${DIM}[Enter] next step   [Ctrl-C] stop here${N}"
  read -r _ </dev/tty
}

ok()   { echo "${G}$*${N}"; }
bad()  { echo "${R}$*${N}"; }
note() { echo "${C}$*${N}"; }

# Fail early if Docker is not running.
need_docker() {
  if ! docker info >/dev/null 2>&1; then
    bad "Docker is not running. Open Docker Desktop, wait for the whale icon to settle, then try again."
    exit 1
  fi
}

# Run steps from $1 (default 1) to the last one. Each step is a function step_N.
# The counter has an unusual name on purpose: bash lets a called function change
# its caller's variables, so a step that used "i" would otherwise skip steps.
run_steps() {
  local _demo_step="${1:-1}" _demo_last="$2"
  while [ "$_demo_step" -le "$_demo_last" ]; do
    "step_$_demo_step"
    _demo_step=$((_demo_step + 1))
  done
}

# Last step of every demo: offer to clean up.
finish() {
  echo
  if [ "${DEMO_NOPAUSE:-}" != 1 ]; then
    printf "%s" "${DIM}[Enter] stop and clean up   [Ctrl-C] leave it running${N}"
    read -r _ </dev/tty
  fi
  run "docker compose down -v"
}
