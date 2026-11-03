# Solution - 06-twist-rename-trap

## 1. Restore V2 (its own commit)
```bash
cd work
git log --oneline -- migrations/V2__add_group_id.sql
#   4c7b3d8 Rename group_id to group_ref      <- the in-place edit
#   b2a6e19 Add group_id column               <- what production applied
git show b2a6e19:migrations/V2__add_group_id.sql            # ALTER TABLE orders ADD COLUMN group_id INTEGER;
git restore --source=b2a6e19 migrations/V2__add_group_id.sql   # YOUR hash
git diff                                                    # - group_ref / + group_id
git add migrations/V2__add_group_id.sql
git commit -m "Restore V2 to production version"
```
Same result: `git revert --no-commit 4c7b3d8` (the teammate's commit only touched V2) then
`git commit -m "Restore V2 to production version"`.

Why: a migration that ran in production is **history**. The database remembers its checksum; edit
the file and every deploy stops. The fix is to put the file back exactly, never to edit it again.
A real change goes in a **new** migration (here: none, the task says no group_ref migration).

## 2. Expand instead of rename
```bash
git rm migrations/V3__rename_items.sql      # never reached production, so it can be replaced
```
In the Files panel: **+ New file** `migrations/V3__add_order_items.sql`, exactly:
```sql
ALTER TABLE orders ADD COLUMN order_items TEXT;
UPDATE orders SET order_items = items WHERE order_items IS NULL;
```
Save with **Ctrl+S**, then:
```bash
git add migrations/V3__add_order_items.sql
git status                                  # deleted: V3__rename_items.sql, new file: V3__add_order_items.sql
git commit -m "Add order_items next to items"
git log --oneline                           # 6 commits
git status                                  # clean
```

Why expand/contract (parallel change):
- **Old code keeps working**: 2.3 still inserts into `items`, which still exists. The new column is
  nullable, so old inserts simply leave it NULL.
- **Rollback stays safe**: if 2.4 misbehaves, redeploying the 2.3 image works, because the schema
  still has everything 2.3 needs. With the RENAME, rollback restored the code but not the column.
- The full sequence (each step its own release):
  1. expand: `ADD COLUMN order_items` (this lab)
  2. deploy code that writes **both** columns, reads `items`
  3. backfill rows written before step 2 (`UPDATE ... WHERE order_items IS NULL`; included above)
  4. deploy code that reads `order_items` (still writes both)
  5. deploy code that only uses `order_items`
  6. contract: `ALTER TABLE orders DROP COLUMN items;` <- the **irreversible** point (data gone)

## Common wrong attempts
- Only doing step 2 (what happened in Quiz 3 Q10) -> deploys still fail on the V2 checksum.
- `git revert --no-edit 4c7b3d8` -> message `Revert "Rename group_id to group_ref"`, not the one asked.
- Writing a V4 that renames group_ref back -> the task forbids it, and V2's checksum is still wrong.
- `git reset --hard b2a6e19` -> throws away the teammate's commits (history rewritten); the check
  wants 6 commits with theirs still there.
- Restoring V2 and creating V3 in the **same** commit -> HEAD~1 must change only V2.
- `ALTER TABLE orders ADD COLUMN order_items TEXT NOT NULL;` -> SQLite: `Cannot add a NOT NULL
  column with default value NULL`; Postgres: fails on a table with rows. And the old 2.3 insert would
  break even if it worked.
- Forgetting the `UPDATE` -> existing orders have `order_items` = NULL: the new code shows empty orders.
- `ALTER TABLE orders RENAME COLUMN items TO order_items` with a "fix" later -> still breaks 2.3
  between migrate and deploy, and after any rollback.
- Deleting V3 with plain `rm` and forgetting `git add`/`git rm` -> the old file is still at main.
- `git add .` is fine here, but read `git status` first: nothing else should be staged.
