# 06 - The rename trap: restore an applied migration, then expand instead of rename (Twist)

```
$ git log --oneline
9e1f0a2 (HEAD -> main) Rename items to order_items
4c7b3d8 Rename group_id to group_ref
b2a6e19 Add group_id column
70d5c41 Add orders table

$ ls migrations
V1__create_orders.sql  V2__add_group_id.sql  V3__rename_items.sql
```

**Context:** TiffinGo's pipeline runs **migrate, then deploy** (old code keeps serving while the
migration runs) and checks that applied migrations were not edited (checksums).
- **Production** has applied V1 and V2 exactly as they were in the commit "Add group_id column".
  It runs `app.py` 2.3, which inserts into the column `items`.
- Since then a teammate edited the applied `V2__add_group_id.sql` in place
  ("Rename group_id to group_ref"). Every deploy now stops with
  `Migration checksum mismatch for migration version 2`.
- Then "Rename items to order_items" added `V3__rename_items.sql` for release 2.4-rename. It has
  **not** reached production. In staging it did what the lecture showed: during the deploy, and
  even after rolling back to the 2.3 image, every checkout failed with `no such column: items`.
  Code went back, the column did not.

**Task** (inside `work/`, in this order):
1. Make V2 exactly what production applied, as **one new commit** with the message
   `Restore V2 to production version` (that commit changes only V2).
2. Replace the unsafe rename with the **expand** step of expand/contract: delete
   `V3__rename_items.sql` and create `migrations/V3__add_order_items.sql` that
   - adds a new column `order_items` (TEXT) to `orders`, and
   - copies every existing row's `items` into `order_items` (backfill),
   - **keeps** `items`, so the running 2.3 code still works.

   Commit both changes together as **one** commit with message `Add order_items next to items`.

**Done when:** main has exactly 6 commits, V2 is byte-for-byte the production version, and the
migrations work on a database that already has rows, with old code still able to insert.

**Stop rules:** don't rewrite history (no reset/rebase/amend of existing commits), don't push, don't
edit V1 or app.py, don't write a migration for the group_ref rename. No `DROP` or `RENAME` anywhere:
dropping `items` (the **contract** step) is a later release, once no running code uses it.

**Hints**
- See what changed: `git log --oneline -- migrations/V2__add_group_id.sql`, `git show <hash>`.
- An old version of a file: `git show <hash>:migrations/V2__add_group_id.sql`; put it back with
  `git restore --source=<hash> migrations/V2__add_group_id.sql`.
- `git rm <file>` deletes a file and stages the deletion.
- Create the new file in the **Files panel**: **+ New file**, type the path
  `migrations/V3__add_order_items.sql`, write the SQL, save with **Ctrl+S**. Each statement ends with `;`.
- A new column added to a table that already has rows must be **nullable** (or have a default):
  `NOT NULL` without a default fails, and would also break the old code's inserts.
- No flyway and no database here: the checker applies your committed migrations to a test copy.

**What will be checked**
- 6 commits; teammate's commits still there; `HEAD~1` = `Restore V2 to production version`, touching only V2
- V2 at main is identical to the "Add group_id column" version
- `HEAD` = `Add order_items next to items`; migrations are V1, V2, `V3__add_order_items.sql`; no RENAME/DROP
- applied to a db with 3 existing orders: `items` and `order_items` both exist and match on every row;
  the old 2.3 insert still works; tree clean
