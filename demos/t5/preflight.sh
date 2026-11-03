#!/usr/bin/env bash
# Run before class, on good Wi-Fi.
#   ./preflight.sh         check the folders, Docker and ports; download and build everything
#   ./preflight.sh smoke   the same, then start each demo once, check one thing, and stop it
cd "$(dirname "$0")" || exit 1
source lib/demo-lib.sh

TOPIC="T5"
DEMOS="t5-pipeline t5-rollout"
IMAGES="postgres:16-alpine node:22-alpine caddy:2.8.4-alpine"
PORTS="8080"
FAILS=0
pass() { ok  "  PASS  $*"; }
fail() { bad "  FAIL  $*"; FAILS=$((FAILS + 1)); }

banner "Preflight for the $TOPIC demos"

echo; echo "${B}0. Demo folders${N}"
missing=0
for d in $DEMOS; do
  if [ -d "$d" ]; then pass "$d"; else fail "$d is missing: copy the $d folder into $(pwd)"; missing=1; fi
done
if [ "$missing" = 1 ]; then bad "Copy the missing folders, then run ./preflight.sh again."; exit 1; fi
chmod +x ./*.sh ./*/*.sh 2>/dev/null

echo; echo "${B}1. Docker${N}"
if docker info >/dev/null 2>&1; then pass "Docker is running"; else fail "Docker is not running. Open Docker Desktop first."; exit 1; fi
if docker compose version >/dev/null 2>&1; then pass "$(docker compose version)"; else fail "'docker compose' not found. Update Docker Desktop."; exit 1; fi

echo; echo "${B}2. Ports${N}"
for p in $PORTS; do
  # Linux note: fall back to ss when lsof is not installed (otherwise a busy port reads as free)
  if lsof -nP -iTCP:"$p" -sTCP:LISTEN >/dev/null 2>&1 \
     || { ! command -v lsof >/dev/null && ss -ltnH "sport = :$p" 2>/dev/null | grep -q .; }; then
    fail "port $p is in use: $(lsof -nP -iTCP:"$p" -sTCP:LISTEN | awk 'NR==2{print $1" (pid "$2")"}'). Run ./reset-all.sh, or stop that program."
  else
    pass "port $p is free"
  fi
done

echo; echo "${B}3. Download images${N}"
for img in $IMAGES; do
  if docker pull -q "$img" >/dev/null; then pass "$img"; else fail "could not pull $img"; fi
done

echo; echo "${B}4. Build the TiffinGo releases${N}"
# The pipeline builds images live in class. Building every release once here fills
# Docker's build cache, so the builds in class need no internet.
t5ok=1
for r in 2.3 2.4 2.4-rename 2.5; do
  docker build -q --build-arg RELEASE="$r" t5-pipeline/app >/dev/null 2>&1 || t5ok=0
done
if [ "$t5ok" = 1 ]; then pass "t5-pipeline (4 releases)"; else fail "t5-pipeline (run: cd t5-pipeline/app && docker build --build-arg RELEASE=2.3 .)"; fi
pass "t5-rollout (nothing to build: it runs in node:22-alpine)"

if [ "${1:-}" = "smoke" ]; then
  echo; echo "${B}5. Smoke test${N}"
  if (t5-pipeline/reset.sh >/dev/null 2>&1; t5-pipeline/setup.sh >/dev/null 2>&1 && t5-pipeline/deploy.sh 2.3 >/dev/null 2>&1 \
      && curl -sf http://localhost:8080/healthz | grep -q '"2.3"' \
      && curl -sf 'http://localhost:8080/checkout?customer=asha' | grep -q '^ok' \
      && t5-pipeline/deploy.sh 2.4 >/dev/null 2>&1 && t5-pipeline/rollback.sh 2.3 >/dev/null 2>&1 \
      && curl -sf http://localhost:8080/healthz | grep -q '"2.3"'); then
    pass "t5-pipeline: deploy 2.3, deploy 2.4, roll back to 2.3"
  else
    fail "t5-pipeline (run: cd t5-pipeline && ./setup.sh && ./deploy.sh 2.3)"
  fi
  t5-pipeline/reset.sh >/dev/null 2>&1
  if (cd t5-rollout && docker run --rm -v "$PWD":/demo -w /demo node:22-alpine node rollout.js spread | grep -q 'Buckets 0 to 9'); then
    pass "t5-rollout: 10,000 users bucketed"
  else
    fail "t5-rollout (run: cd t5-rollout && ./demo.sh)"
  fi
fi

echo
if [ "$FAILS" -eq 0 ]; then ok "${B}All good.${N}"; else bad "${B}$FAILS problem(s). Fix them before class.${N}"; fi
