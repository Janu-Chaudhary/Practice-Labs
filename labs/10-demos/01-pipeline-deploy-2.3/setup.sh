#!/usr/bin/env bash
# Stage 1: nothing running, the demo scripts copied into work/. The student starts the
# platform, deploys v2.3 through the pipeline and starts the traffic loop.
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_t5.sh"
t5_fresh_pipeline
banner "Demos 01: start the platform and deploy TiffinGo v2.3 through the pipeline"
