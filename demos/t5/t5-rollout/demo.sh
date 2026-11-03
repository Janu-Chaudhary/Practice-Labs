#!/usr/bin/env bash
# T5 slide 19 · Percentage rollout: how "10% of users" actually works.
# Runs Node inside Docker. No database, no server: just a flag file and a function.
# Run:  ./demo.sh       (from step 1)
#       ./demo.sh 5     (start at step 5)
cd "$(dirname "$0")" || exit 1
source ../lib/demo-lib.sh
need_docker

LAST=9
TT=""; [ -t 1 ] && TT="-t"

# Show the command as students would type it, then run it in a Node container.
js() {
  echo "${B}\$ node rollout.js $*${N}"
  docker run --rm $TT -v "$PWD":/demo -w /demo node:22-alpine node rollout.js "$@"
}

# Write the flag file, showing the edit on screen.
set_percent() {
  echo "${B}\$ echo '{ \"group_order\": { \"rollout_percent\": $1 } }' > flags.json${N}"
  printf '{\n  "group_order": { "rollout_percent": %s }\n}\n' "$1" > flags.json
}

step_1() {
  banner "T5 · Percentage rollout · TiffinGo group orders"
  set_percent 10 >/dev/null; rm -f .state.json
  step 1 "Where the flag lives" "Outside the code. Here a JSON file. In v2.5 it was a database table."
  run "cat flags.json"
  note "The code never contains the number 10. It reads it from here."
  pause
}

step_2() {
  step 2 "The whole trick: one function" "Turn (flag name, user id) into a number from 0 to 99. ON if it's below the percentage."
  run "sed -n '/BEGIN bucket/,/END bucket/p' rollout.js"
  pause
}

step_3() {
  step 3 "Five users, one at a time" "Hash, take a big number, keep the remainder after dividing by 100."
  js explain asha ravi meena kabir zoya
  note "Each user gets a bucket. The bucket never changes for that user and flag."
  pause
}

step_4() {
  step 4 "Is it skewed? 10,000 users" "If 10% get it, the 10 green buckets should hold about 1,000 users."
  js spread
  note "Single buckets wobble. Ten of them together come out close to 10%."
  pause
}

step_5() {
  step 5 "More users, less wobble: 1,000,000" "Same function. Watch the smallest and largest bucket."
  js spread 1000000
  pause
}

step_6() {
  step 6 "Why not just Math.random()?" "asha opens the app 10 times."
  js random asha
  pause
}

step_7() {
  step 7 "Roll out: 10% → 50% → 100%" "Only the number in flags.json changes. Watch 'turned off'."
  rm -f .state.json
  js rollout
  pause
  set_percent 50
  js rollout
  pause
  set_percent 100
  js rollout
  note "Nobody who had the feature lost it. Buckets don't move, only the line does."
  pause
}

step_8() {
  step 8 "Kill switch: back to 0" "Something broke. One edit, no deploy."
  set_percent 0
  js rollout
  pause
}

step_9() {
  step 9 "Why the flag name is inside the hash" "Two flags, both at 10%."
  js overlap
  note "About 1% overlap is what chance gives: 10% of 10%."
  set_percent 10 >/dev/null; rm -f .state.json
  ok "flags.json reset to 10%."
}

run_steps "${1:-1}" "$LAST"
