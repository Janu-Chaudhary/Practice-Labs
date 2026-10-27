# Solution - 03 down loses data

```bash
cd work
flyway info                              # 01 Success, 02 Success. No .down.sql rows: Flyway ignores them
cat migrations/02_drop_bio.down.sql      # ALTER TABLE users ADD COLUMN bio text;
```
In the Files panel click **+ New file**, type `migrations/03_restore_bio.up.sql`, write:
```sql
ALTER TABLE users ADD COLUMN bio TEXT;
```
Save with **Ctrl+S**. Then **+ New file** `migrations/03_restore_bio.down.sql`:
```sql
ALTER TABLE users DROP COLUMN bio;
```
Save with **Ctrl+S**.
```bash
flyway info                              # 03 Pending
flyway migrate                           # Migrating schema "main" to version "03 - restore bio"
flyway info                              # 01, 02, 03 Success
```
**+ New file** `answer.txt`:
```
NULL
```
Save with **Ctrl+S**.

**Why NULL?** The reverse SQL is *new SQL* that runs after the drop committed. `ADD COLUMN bio TEXT`
makes an empty column with the right name and type. The old values were deleted by 02 and are not stored
anywhere (not in the history table either: it only stores version, script name, checksum, who and when).
Only a **backup restore** gets them back. ROLLBACK can't help: the drop was committed long ago.
It is the same whether you run `02_drop_bio.down.sql` with an undo tool or roll forward with 03.

**Why roll forward and not "undo 02"?** Flyway free has no undo command. Rolling forward keeps the history
table honest: it says 01, 02, 03 ran, which is exactly what happened. Every other database (CI, production)
gets the same three steps in the same order. Tools with built-in down support (`migrate down`, Flyway
Teams `undo`) run the down file and remove the history row for you, but the data is still gone.

**Why a down file for 03?** Every migration gets its reverse, so 03 can be undone later by a tool or a person.

**Common wrong attempts**
- Editing `02_drop_bio.up.sql` (e.g. deleting the DROP) -> checksum mismatch for 02 (lab 07), and bio is
  still not back.
- `03_restore_bio.sql` (no `.up`) -> not a migration in this project; `flyway info` does not list it.
- `03-restore-bio.up.sql` -> `Invalid ... name` error: the separator is `_`.
- `answer.txt` = `Likes chess` -> that is what a backup restore would give, not a reverse migration.
