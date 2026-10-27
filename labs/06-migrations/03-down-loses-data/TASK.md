# 03 - A reverse migration can't bring data back (Drill)

**Situation** (this is Quiz 2 Q9 / the "bio" slide, made real). This lab uses the **course naming**:
`NN_name.up.sql` is the migration, `NN_name.down.sql` is its reverse migration.
`flyway.toml` tells Flyway that only `.up.sql` files are migrations. Flyway (free edition) has **no undo
command**: it never runs a `.down.sql`. So on a shared database the way back is to **roll forward**:
write the reverse SQL as the **next** migration.

Users Asha ("Likes chess") and Ravi ("Builds robots") were created, then migration 02 ran:
`02_drop_bio.up.sql` = `ALTER TABLE users DROP COLUMN bio;`
Now the product team says: "we want the bio column back".

**Task** (inside `work/`):
1. Run `flyway info`. 01 and 02 are Success. Is `02_drop_bio.down.sql` in the table?
2. Open `migrations/02_drop_bio.down.sql` in the Files panel (or `cat` it). That is the reverse SQL.
3. Roll forward. In the Files panel click **+ New file**, type `migrations/03_restore_bio.up.sql`, write
   ```sql
   ALTER TABLE users ADD COLUMN bio TEXT;
   ```
   and save with **Ctrl+S**. Then create its reverse `migrations/03_restore_bio.down.sql` the same way:
   ```sql
   ALTER TABLE users DROP COLUMN bio;
   ```
4. Apply it with Flyway, then check `flyway info`.
5. Think: what is in `bio` for Asha now? Create `answer.txt` (**+ New file**) with one word:
   `Likes chess`? or `NULL`? Save it.

**Stop:** don't edit or delete the 01/02 files; don't delete `shop.db`.

**Hints**
- A new change is a new file with the next version (03). Never edit 02: it is applied.
- The history table stores version, script name and checksum. Does it store the old bio values?

**What will be checked**
- `03_restore_bio.up.sql` adds bio; `03_restore_bio.down.sql` drops it; history has 03 Success
- users has a bio column again, 2 rows, bio NULL in both; `answer.txt` says NULL
- 01/02 files unchanged
