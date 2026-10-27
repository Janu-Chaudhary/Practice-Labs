# 03 - A reverse migration can't bring data back (Drill)

**Situation** (this is Quiz 2 Q9 / the "bio" slide, made real). This lab uses the **course naming**:
`NN_name.up.sql` is the migration, `NN_name.down.sql` is its reverse migration.
`flyway.toml` tells Flyway that only `.up.sql` files are migrations. Flyway (free edition) has no
"undo" command, so a `.down.sql` file is something **you** run by hand with sqlite3.

Users Asha ("Likes chess") and Ravi ("Builds robots") were created, then migration 02 ran:
`02_drop_bio.up.sql` = `ALTER TABLE users DROP COLUMN bio;`

**Task** (inside `work/`):
1. `flyway info` - 01 and 02 are Success. Look at `users` with sqlite3: no bio column.
2. Run the reverse migration `02_drop_bio.down.sql` on `shop.db` with sqlite3.
3. Look at `users` again. What is in `bio`?
4. Flyway still has a history row saying 02 is applied, which is now false. Delete that row from
   `flyway_schema_history` so `flyway info` shows 02 as **Pending** (this is what an undo tool does for you).
5. `flyway info` to confirm. (Do NOT run `flyway migrate` now - it would drop bio again.)

**Stop:** don't edit or delete the migration files.

**Hints**
- Run a SQL file: `sqlite3 shop.db < migrations/02_drop_bio.down.sql` (`<` feeds the file as input).
- Delete a row: `DELETE FROM flyway_schema_history WHERE version = '02';` (version is text: quote it).

**What will be checked**
- users has a bio column, 2 rows, bio NULL in both
- history: no row for 02, row for 01 still there
- files unchanged
