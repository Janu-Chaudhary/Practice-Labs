# Solution - 12 repeatable view

```bash
cd work
flyway info
#  | Versioned  | 1 | create users | SQL | ... | Success |
#  | Versioned  | 2 | create orders| SQL | ... | Success |
#  | Repeatable |   | active users | SQL | ... | Success |   <- Category "Repeatable", Version EMPTY
```
In the Files panel click **+ New file**, type `migrations/V3__add_city.sql`, write (versioned: runs once):
```sql
ALTER TABLE users ADD COLUMN city TEXT;
```
Save with **Ctrl+S**. Then open `migrations/R__active_users.sql` and change the SELECT line, so the file is:
```sql
-- Repeatable: Flyway re-runs this file whenever its checksum changes.
DROP VIEW IF EXISTS active_users;
CREATE VIEW active_users AS
  SELECT id, name, city FROM users WHERE active = 1;
```
Save with **Ctrl+S**.
```bash
flyway info                              # old R active users row "Outdated" (checksum changed), plus a new
                                         # R active users row "Pending" (the re-run to come); V3 Pending
```
**+ New file** `migrations/R__user_order_totals.sql`:
```sql
DROP VIEW IF EXISTS user_order_totals;
CREATE VIEW user_order_totals AS
  SELECT user_id, SUM(total) AS order_total FROM orders GROUP BY user_id;
```
Save with **Ctrl+S**.
```bash
flyway info                              # + R user order totals Pending
flyway migrate                           # runs V3, then R active users, then R user order totals
flyway info                              # all Success; the old R active users row shows as "Superseded"
                                         # -> R__active_users.sql now has 2 rows: Superseded + Success
flyway validate                          # Successfully validated
```

**Why each step**
- A repeatable has no version (empty Version column in `flyway info`, NULL in the history table):
  Flyway identifies it by description and checksum.
- V3 is a new versioned file: schema changes to tables are append-only, one new version each time.
- The view is redefined by **editing** its repeatable. The new checksum makes Flyway mark it Outdated and
  re-run it. No new version number needed, and git shows the view's full current definition in one file.
- `DROP VIEW IF EXISTS` first: a repeatable runs many times, so it must work on a database that already
  has the view (otherwise: `view active_users already exists`, rolled back).
- One migrate is enough: Flyway always runs pending versioned migrations before repeatables, so the
  `city` column exists when the view is created.

**Common wrong attempts**
- Writing `V4__active_users_city.sql` with the new view -> works once, but now the view lives in two
  places, and the next R change would overwrite it anyway (check: only 3 V files).
- Editing V1 to add city -> checksum mismatch for version 1 (lab 07).
- `R_active_users.sql` (one underscore) or `r__...` -> invalid name error (validateMigrationNaming=true).
- Forgetting `DROP VIEW IF EXISTS` in the new R file -> it works the first time, but fails as soon as you
  edit it later. (Check stays green here, but it is a bug waiting.)
- Running `flyway migrate` after adding V3 only, then again after the R edits -> still correct, but the task
  says one migrate; the check does not depend on it.
