# 08 - Someone ran a migration's SQL by hand (Quiz-style, Quiz 2 Q8 made real)

**Situation.** Migrations 01 and 02 are applied to `shop.db` (3 users). Two new migrations came from git:
`03_add_full_name.up.sql` and `04_add_phone.up.sql`. Flyway has not applied them yet.
But "to test it", your teammate Ravi ran 03's statement **by hand**, straight on `shop.db`, without Flyway.
He left a note: `NOTE.txt`.

**Task** (inside `work/`):
1. Run `flyway info`. Is 03 Pending or Success? Why, if its column already exists?
2. Run `flyway migrate` and read the error.
3. Open `NOTE.txt` and `migrations/03_add_full_name.up.sql` in the Files panel (or `cat` them).
   Is what Ravi ran exactly the SQL of 03?
4. Get Flyway's history table to tell the truth, using only `flyway` commands:
   - 03 must be **recorded** as applied, but its SQL must **not** run again (the column is already there).
   - 04 must really **run** (Ravi did not touch it).
5. `flyway info` shows 01-04 Success; `flyway migrate` says up to date.

**Stop:** don't edit, rename or delete migration files; don't delete `shop.db`; don't change the database
outside Flyway.

**Hints**
- Flyway can *record* migrations without running their SQL: `flyway migrate -skipExecutingMigrations=true`.
  This is only safe if what was run by hand is **exactly** the file's SQL.
- Careful: it skips **every** pending migration it reaches. `-target=03` makes it stop at 03.
- Flags go after the command: `flyway migrate -target=03 ...`.

**What will be checked**
- 03 file unchanged; history has 03 and 04 Success; `flyway validate` passes
- `full_name` exists once and `phone` exists (04 really ran); users keep names and plans
