#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
V="python3 $LAB_DIR/_verify.py"
export V
echo "Checking..."
check "teammate's commits are still in history (nothing rewritten)" 'git log --format=%s main | grep -qx "Rename group_id to group_ref" && git log --format=%s main | grep -qx "Rename items to order_items"'
check "main has exactly 6 commits" '[ "$(git rev-list --count main)" -eq 6 ]'
check "HEAD~1 is \"Restore V2 to production version\" and changes only V2" '[ "$(git log -1 --format=%s main~1)" = "Restore V2 to production version" ] && [ "$(git diff-tree --no-commit-id --name-only -r main~1)" = migrations/V2__add_group_id.sql ]'
check "V2__add_group_id.sql at main is exactly what production applied" '$V v2-restored'
check "HEAD is \"Add order_items next to items\"" '[ "$(git log -1 --format=%s main)" = "Add order_items next to items" ]'
check "migrations/ at main = V1, V2, V3__add_order_items.sql (V3__rename_items.sql gone)" '$V files'
check "no migration contains RENAME or DROP" '$V no-rename-drop'
check "applied on a db with 3 old rows: items AND order_items exist, every row backfilled" '$V expand'
check "after V3, old 2.3 code can still insert, and new code can write both columns" '$V old-code'
check "working tree clean" '[ -z "$(git status --porcelain)" ]'
summary
