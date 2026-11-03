#!/usr/bin/env bash
# Stop the T5 demos and delete their data. Safe to run any time.
cd "$(dirname "$0")" || exit 1
[ -x t5-pipeline/reset.sh ] && { echo "== t5-pipeline"; t5-pipeline/reset.sh; }
if [ -d t5-rollout ]; then
  echo "== t5-rollout"
  printf '{\n  "group_order": { "rollout_percent": 10 }\n}\n' > t5-rollout/flags.json
  rm -f t5-rollout/.state.json
  echo "flags.json reset to 10%"
fi
echo "All T5 demos stopped."
