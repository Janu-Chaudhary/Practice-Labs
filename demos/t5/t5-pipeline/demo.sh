#!/usr/bin/env bash
# T5 · TiffinGo: deploy, break, go back, and switch a flag.
#   Part A (slide 14) steps 1-6:  deploy v2.3, deploy broken v2.4, roll back
#   Part B (slide 15) steps 7-9:  the renamed column that rollback can't undo
#   Part C (slide 18) steps 10-12: the same bug behind a flag
# Run:  ./demo.sh       (from step 1)
#       ./demo.sh 10    (start at step 10, if the platform is already up)
cd "$(dirname "$0")" || exit 1
source ./t5-lib.sh
need_docker

LAST=12
health() { run "curl -s http://localhost:8080/healthz"; }

step_1() {
  banner "T5 · TiffinGo · safe delivery"
  step 1 "Start the platform and deploy v2.3" \
    "A database, a load balancer on localhost:8080, and v2.3 deployed through the pipeline."
  ./reset.sh >/dev/null 2>&1
  run "./setup.sh"
  echo
  run "./deploy.sh 2.3"
  echo
  note "Second terminal now:  cd cps-demos/t5-pipeline && ./traffic.sh"
  pause
}

step_2() {
  step 2 "Which version is live?" "/healthz reports the version. It's Friday, 19:00."
  health
  pause
}

step_3() {
  step 3 "v2.4: group order" "The change, and its migration."
  echo "${B}\$ diff -u app/releases/2.3/server.js app/releases/2.4/server.js${N}"
  show_diff app/releases/2.3/server.js app/releases/2.4/server.js \
    'const GROUPS::only the developer'"'"'s own account has a saved group' \
    'members[.]map::kabir has no saved group, so members is undefined'
  echo
  echo "${B}\$ cat app/releases/2.4/migrate.sql${N}"
  show_sql app/releases/2.4/migrate.sql
  note "The migration only ADDS a column. Keep that in mind."
  pause
}

step_4() {
  step 4 "19:00 · Deploy v2.4" "Watch the second terminal."
  run "./deploy.sh 2.4"
  echo
  note "Tests passed. Health check passed. And 1 in 5 checkouts fail: every group order."
  pause
}

step_5() {
  step 5 "19:11 · What can we go back to?" "Every version we built is still an image with its own tag."
  run "docker images tiffingo"
  pause
}

step_6() {
  step 6 "Redeploy the previous image" "No test, no build, no migration. Watch the timer."
  run "./rollback.sh 2.3"
  echo
  health
  note "On a hosted platform this takes about a minute (pull the image, start it). Locally, seconds."
  note "Next: slide 15. Press Enter when you're there."
  pause
}

step_7() {
  step 7 "The slide 6 poll, for real: v2.4 renames a column" \
    "Same code, but the migration renames items to order_items."
  echo "${B}\$ cat app/releases/2.4-rename/migrate.sql${N}"
  show_sql app/releases/2.4-rename/migrate.sql
  echo
  run "./deploy.sh 2.4-rename"
  note "Watch terminal 2: during the deploy, v2.3 was still serving and already failing."
  pause
}

step_8() {
  step 8 "Roll back to v2.3 again" "It worked last time. Watch terminal 2."
  run "./rollback.sh 2.3"
  echo
  health
  bad "Healthy, and every checkout fails: column \"items\" does not exist."
  echo "${B}\$ docker exec t5-db psql -U postgres -c '\\d orders'${N}"
  docker exec t5-db psql -U postgres -c '\d orders' | grep -E 'items|Column' \
    | sed "s/order_items/${B}${R}order_items${N}/"
  note "v2.3 asks for items. The table only has order_items."
  note "The code went back. The column didn't. Code is reversible, data is not."
  pause
}

step_9() {
  step 9 "The only way out: forward" "A new migration that renames the column back."
  run "docker exec t5-db psql -U postgres -c 'ALTER TABLE orders RENAME COLUMN order_items TO items;'"
  note "Terminal 2 recovers. With expand-contract, v2.4 would have added order_items and kept items."
  note "Next: slides 16 and 17, then the flags demo at slide 18. Press Enter when you're there."
  pause
}

step_10() {
  step 10 "v2.5: the same group-order code, behind a flag" "The only change: an if-statement reading a flag."
  echo "${B}\$ diff -u app/releases/2.4/server.js app/releases/2.5/server.js${N}"
  show_diff app/releases/2.4/server.js app/releases/2.5/server.js \
    'SELECT enabled FROM flags::the value lives in the database, read on every request' \
    'flagOn[(]db, "group_order"[)]::the only real change: an if around the old code' \
    'members[.]map::the same bug, still here, now behind the flag'
  echo
  echo "${B}\$ cat app/releases/2.5/migrate.sql${N}"
  show_sql app/releases/2.5/migrate.sql
  echo
  run "./deploy.sh 2.5"
  note "The flag starts OFF, so group orders go through as single orders. No errors."
  pause
}

step_11() {
  step 11 "Switch the flag on" "Like turning on the new feature for everyone. Watch terminal 2."
  run "./flag.sh on"
  note "Errors appear on the next group order. No deploy happened."
  pause
}

step_12() {
  step 12 "The kill switch" "Switch it off. Count the seconds."
  run "./flag.sh off"
  health
  note "Still v2.5. Everything else in v2.5 kept running."
  echo
  if [ "${DEMO_NOPAUSE:-}" != 1 ]; then
    printf "%s" "${DIM}[Enter] stop and clean up (Ctrl-C terminal 2 first)   [Ctrl-C] leave it running${N}"
    read -r _ </dev/tty
  fi
  run "./reset.sh"
}

run_steps "${1:-1}" "$LAST"
