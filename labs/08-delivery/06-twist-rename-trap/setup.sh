#!/usr/bin/env bash
# Twist: the 2.4-rename trap. (1) Q10-style: an applied migration was edited -> restore it as its own
# commit. (2) Replace the unsafe RENAME migration with an expand step (add + backfill, keep old column).
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
mkdir migrations
cat > migrations/V1__create_orders.sql <<'SQL'
CREATE TABLE orders (
  id       INTEGER PRIMARY KEY,
  customer TEXT NOT NULL,
  items    TEXT NOT NULL,
  total    INTEGER NOT NULL
);
SQL
cat > app.py <<'PY'
# TiffinGo 2.3 (the version running in production). It still writes the column "items".
def save_order(db, customer, items, total):
    db.execute("INSERT INTO orders (customer, items, total) VALUES (?, ?, ?)",
               (customer, ", ".join(items), total))
PY
git add migrations app.py
git commit -q -m "Add orders table"
cat > migrations/V2__add_group_id.sql <<'SQL'
ALTER TABLE orders ADD COLUMN group_id INTEGER;
SQL
git add migrations; git commit -q -m "Add group_id column"
# teammate edits an ALREADY APPLIED migration in place
git config user.name "Teammate"; git config user.email "teammate@example.com"
cat > migrations/V2__add_group_id.sql <<'SQL'
ALTER TABLE orders ADD COLUMN group_ref INTEGER;
SQL
git add migrations; git commit -q -m "Rename group_id to group_ref"
cat > migrations/V3__rename_items.sql <<'SQL'
-- v2.4-rename: the new code wants the column to be called order_items
ALTER TABLE orders RENAME COLUMN items TO order_items;
SQL
git add migrations; git commit -q -m "Rename items to order_items"
git config user.name "Student"; git config user.email "student@example.com"
banner "06-twist-rename-trap (Twist): restore V2, then replace the RENAME with an expand migration"
