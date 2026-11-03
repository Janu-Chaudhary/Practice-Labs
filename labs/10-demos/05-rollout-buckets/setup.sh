#!/usr/bin/env bash
# Stage 5: the t5-rollout demo (no server, no database): rollout.js + flags.json at 10%.
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_t5.sh"
need_docker
need_images
stop_traffic
fresh_work
cp "$T5_SRC/t5-rollout/rollout.js" "$T5_SRC/t5-rollout/flags.json" .
printf '{\n  "group_order": { "rollout_percent": 10 }\n}\n' > flags.json   # the demo's start value
cat > answers.txt <<'EOF'
# Write each answer after the = sign (Files panel, then Save). No spaces needed.
# 1. With rollout_percent 10: which of asha ravi meena kabir zoya are ON? (comma separated)
on_at_10=
# 2. With rollout_percent 10: how many of the 10,000 users are ON? (node rollout.js rollout)
count_at_10=
# 3. You moved 10 -> 50 and ran rollout again. How many users "turned off"?
turned_off=
# 4. node rollout.js overlap: with the flag name in the hash, how many users are in BOTH groups?
overlap=
# 5. After you set rollout_percent to 25 in flags.json: which of the five users are ON?
on_at_25=
EOF
banner "Demos 05: percentage rollout with sticky buckets (rollout.js + flags.json)"
