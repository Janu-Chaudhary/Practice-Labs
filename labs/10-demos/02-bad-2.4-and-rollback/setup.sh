#!/usr/bin/env bash
# Stage 2 start state: platform up, v2.3 deployed through the pipeline (end of stage 1).
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_t5.sh"
t5_fresh_pipeline
t5_up_with_23
banner "Demos 02: Friday 19:00, deploy v2.4 (1 in 5 checkouts fail), then roll back to v2.3"
