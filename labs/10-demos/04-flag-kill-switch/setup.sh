#!/usr/bin/env bash
# Stage 4 start state: platform up, v2.3 deployed through the pipeline (end of stage 1).
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_t5.sh"
t5_fresh_pipeline
t5_up_with_23
banner "Demos 04: deploy v2.5 (group orders behind a flag), flag on, flag off"
