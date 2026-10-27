# 02 - Your first `flyway migrate` (Drill)

**Situation.** `work/` holds a `flyway.toml` (Flyway's settings: which database, where the files are)
and a `migrations/` folder with one migration, `V1__create_users.sql`. There is no `shop.db` yet.
This lab uses **Flyway's default file naming**: `V<version>__<description>.sql` (capital V, **two** underscores).

**Task** (inside `work/`):
1. Run `flyway info` and read the table: V1 is **Pending**.
2. Run `flyway migrate`. Flyway creates `shop.db`, runs V1, and records it in `flyway_schema_history`.
3. Look at the history table with sqlite3.
4. Write a new migration `migrations/V2__add_email.sql` that adds a column `email` (type `TEXT`) to `users`.
5. Run `flyway migrate` again, then `flyway info`. Run `flyway migrate` a third time and read what it says.

**Stop:** don't edit `V1__create_users.sql` (it is already applied).

**Hints**
- `flyway` is a small script that runs Flyway inside Docker. If you get `command not found`, run the
  `export PATH=...` line that `setup.sh` printed.
- Create the file with `code migrations/V2__add_email.sql`, `nano ...`, or `echo '...' > ...`.
- SQL: `ALTER TABLE users ADD COLUMN email TEXT;`

**What will be checked**
- `shop.db` exists; history has versions 1 and 2, both successful
- `V2__add_email.sql` exists and adds `email`; `users` has an `email` column and still 3 rows
- V1 unchanged
