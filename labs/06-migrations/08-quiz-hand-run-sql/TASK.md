# 08 - Someone ran a migration's SQL by hand (Quiz-style, Quiz 2 Q8 made real)

**Situation.** Migrations 01 and 02 are applied to `shop.db` (3 users). Migration
`03_add_full_name.up.sql` (`ALTER TABLE users ADD COLUMN full_name text;`) is new and was not applied
by Flyway yet. But "to test it", a teammate ran that statement **by hand** in sqlite3 on `shop.db`.

**Task** (inside `work/`):
1. Run `flyway info`. Is 03 Pending or Success? Why?
2. Run `flyway migrate` and read the error.
3. Get `shop.db` to the state where Flyway has recorded 03 as applied, `full_name` exists, and the
   3 users keep their data. Then `flyway info` shows 03 Success and `flyway migrate` says up to date.

**Stop:** don't edit, rename or delete `03_add_full_name.up.sql`; don't delete users or `shop.db`;
don't insert rows into `flyway_schema_history` by hand (you would have to fake a checksum).

**Hints**
- Before you remove anything, check it holds no data: `SELECT count(*) FROM users WHERE full_name IS NOT NULL;`
- SQLite can drop a column: `ALTER TABLE users DROP COLUMN full_name;`
- Flyway can also *record* a migration without running it: `flyway migrate -skipExecutingMigrations=true -target=03`.
  Only safe if what was run by hand is exactly the file's SQL.

**What will be checked**
- 03 file unchanged; history has 03 Success; `flyway validate` passes
- `full_name` exists once; users keep names and plans
