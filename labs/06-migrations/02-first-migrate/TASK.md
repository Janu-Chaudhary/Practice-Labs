# 02 - Your first `flyway migrate` (Drill)

**Situation.** `work/` holds a `flyway.toml` (Flyway's settings: which database, where the files are)
and a `migrations/` folder with one migration, `V1__create_users.sql`. There is no `shop.db` yet.
This lab uses **Flyway's default file naming**: `V<version>__<description>.sql` (capital V, **two** underscores).

**Task** (inside `work/`):
1. Run `flyway info` and read the table: V1 is **Pending**.
2. Run `flyway migrate`. Flyway creates `shop.db`, runs V1, and records it in its history table
   `flyway_schema_history`.
3. Run `flyway info` again. V1 is now **Success** and has an `Installed On` time: that is its history row.
4. Write a new migration that adds a column `email` (type `TEXT`) to `users`:
   in the Files panel click **+ New file**, type `migrations/V2__add_email.sql`, write

   ```sql
   ALTER TABLE users ADD COLUMN email TEXT;
   ```
   and save with **Ctrl+S**.
5. Run `flyway info` (V2 Pending), then `flyway migrate`, then `flyway info`.
   Run `flyway migrate` a third time and read what it says.

**Stop:** don't edit `V1__create_users.sql` (it is already applied).

**Hints**
- `flyway` is a small script that runs Flyway inside Docker. If you get `command not found`, run the
  `export PATH=...` line that `setup.sh` printed.
- If V2 does not show up in `flyway info`, its name is wrong. Look at the name in the Files panel.

**What will be checked**
- `shop.db` exists; history has versions 1 and 2, both successful
- `V2__add_email.sql` exists and adds `email`; `users` has an `email` column and still 3 rows
- V1 unchanged
