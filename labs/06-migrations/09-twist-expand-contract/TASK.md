# 09 - Rename a column without downtime: expand / backfill / contract (Twist)

**Situation.** `users(id, user_name)` has 3 rows and is used by a running app with several instances
(rolling deploys: old and new code run at the same time). The product manager wants `user_name`
renamed to `full_name`. A direct `RENAME COLUMN` would break every old instance at once (Quiz 2 Q11).

**Task** (inside `work/`, course naming `NN_name.up.sql` / `.down.sql`): do it as the lecture's four steps,
as separate migrations, applied **in stages**:
1. **Expand** `02_add_full_name.up.sql`: add `full_name text`. Reverse: `02_add_full_name.down.sql`.
   Apply only up to 02.  *(Now the app is changed to write both columns.)*
2. **Backfill** `03_backfill_full_name.up.sql`: copy `user_name` into `full_name` for rows where it is NULL.
   Apply up to 03. *(No reverse needed: it only fills a column that 02.down would drop anyway.)*
   *(Transition: the app now reads `full_name`, still writes both. No SQL.)*
3. **Contract** `04_drop_user_name.up.sql`: drop `user_name`. Apply it.
   Its reverse `04_drop_user_name.down.sql` must be a **deliberate repair**: re-add `user_name` **and copy
   the names back** from `full_name` (a plain ADD COLUMN would give NULLs).

**Stop:** don't edit 01; don't run down files on `shop.db`.

**Hints**
- Apply up to a version: `flyway migrate -target=02`. Then `flyway info` shows 03/04 still Pending if they exist.
- A down file may hold several statements, each ending in `;`.
- After step 1, check `SELECT * FROM users;` - full_name NULL everywhere; after step 2 - filled.

**What will be checked**
- history has 02, 03, 04 with those exact file names; `flyway validate` passes
- users = `id, full_name` with all 3 names
- 02 and 04 down files exist; on a copy, 04.down gives `user_name` = `full_name` for every row,
  then 02.down leaves `id, user_name` with the names
