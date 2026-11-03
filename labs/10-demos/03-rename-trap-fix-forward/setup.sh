#!/usr/bin/env bash
# Stage 3 start state: platform up, v2.3 deployed through the pipeline (end of stage 1).
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_t5.sh"
t5_fresh_pipeline
t5_up_with_23
banner "Demos 03: deploy 2.4-rename (renames a column), roll back, then fix forward"
