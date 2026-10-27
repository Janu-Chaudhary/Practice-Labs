#!/usr/bin/env bash
# Shared helpers for every lab. Source it from setup.sh / check.sh:
#   source "$(dirname "$0")/../../lib/common.sh"
# Each exercise folder has: TASK.md setup.sh check.sh SOLUTION.md
# setup.sh builds ./work fresh; the student works inside ./work; check.sh grades ./work.

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[1]:-$0}")" && pwd)"
WORK="$LAB_DIR/work"
G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1m'; N=$'\e[0m'
_pass=0; _fail=0

# fresh_work: delete and recreate ./work, cd into it
fresh_work() { rm -rf "$WORK"; mkdir -p "$WORK"; cd "$WORK" || exit 1; }

# git_repo [dir]: git init with a fixed identity, main branch, no pager surprises
git_repo() {
  local d="${1:-.}"; mkdir -p "$d"
  git -C "$d" init -q -b main
  git -C "$d" config user.name "Student"
  git -C "$d" config user.email "student@example.com"
}

# commit_file <file> <content> <message>: write file, add, commit (setup helper)
commit_file() { printf '%s\n' "$2" > "$1"; git add "$1"; git commit -q -m "$3"; }

# check "<description>" <command...>: run command silently, print ✓/✗
check() {
  local desc="$1"; shift
  if ( cd "$WORK" 2>/dev/null && eval "$@" ) >/dev/null 2>&1; then
    echo "  ${G}✓${N} $desc"; _pass=$((_pass+1))
  else
    echo "  ${R}✗${N} $desc"; _fail=$((_fail+1))
  fi
}

# hint "<text>": print a hint line (use after a failing check if helpful)
hint() { echo "    ${Y}hint:${N} $*"; }

# summary: print score, exit 0 if all passed
summary() {
  local total=$((_pass+_fail))
  echo
  if [ "$_fail" -eq 0 ]; then echo "${G}${B}All $total checks passed. Nice!${N}"; exit 0
  else echo "${R}${B}$_pass/$total checks passed.${N} Fix the ✗ items and run ./check.sh again (or ./setup.sh to start over)."; exit 1; fi
}

# banner "<title>": used at the end of setup.sh
banner() {
  echo "${B}Lab ready:${N} $1"
  echo "Now run:  ${B}cd work${N}   then read ../TASK.md and solve it."
  echo "When done: ${B}cd .. && ./check.sh${N}"
}

# need_docker: abort politely if docker isn't usable
need_docker() { docker info >/dev/null 2>&1 || { echo "${R}Docker isn't running.${N} Start it and retry."; exit 1; }; }
