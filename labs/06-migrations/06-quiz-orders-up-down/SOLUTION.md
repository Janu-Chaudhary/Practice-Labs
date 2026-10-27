# Solution - 06 orders up/down (Q18 reconstruction)

```bash
cd work
flyway info                       # 01, 02 Success. Nothing pending.
```
In the Files panel create 4 files with **+ New file** (type the path, write the SQL, save with **Ctrl+S**):

`migrations/03_add_currency.up.sql`
```sql
ALTER TABLE orders ADD COLUMN currency TEXT NOT NULL DEFAULT 'INR';
```
`migrations/03_add_currency.down.sql`
```sql
ALTER TABLE orders DROP COLUMN currency;
```
`migrations/04_create_coupons.up.sql`
```sql
CREATE TABLE coupons (code TEXT PRIMARY KEY, percent INTEGER NOT NULL);
```
`migrations/04_create_coupons.down.sql`
```sql
DROP TABLE coupons;
```
```bash
ls migrations                     # 6 files: 01, 02, and your 4
flyway info                       # 03 and 04 Pending (down files are not listed: correct)
flyway migrate                    # Migrating ... "03 - add currency", "04 - create coupons"
flyway info                       # 01..04 Success, Schema version: 04
flyway validate                   # Successfully validated 4 migrations
```

**Why each piece**
- New change = new file with the next version (03, 04). Never edit 01/02: they are applied (checksums).
- `NOT NULL DEFAULT 'INR'`: SQLite fills old rows with the default; without DEFAULT, migrate fails with
  `Cannot add a NOT NULL column with default value NULL` (rolled back, no history row: fix 03 and migrate again).
- Down = the opposite statement. Run in reverse order (04 then 03). Dropping `currency` loses its values
  (fine here: they were all the default), see lab 03.
- Flyway runs each migration in a transaction on SQLite: if 04 fails, 04 rolls back, 03 stays applied.

**Common wrong attempts**
- `03-add-currency.up.sql` / `3.up.sql` / `03_add_currency.sql` -> `Invalid ... name` or the file is not a
  migration at all. Version, then `_`, then description, then `.up.sql`.
- `V3__add_currency.sql` -> that is Flyway's *default* naming; this project is configured for `03_...up.sql`.
- Two files with the same version (e.g. `03_add_currency.up.sql` and `03_create_coupons.up.sql`) ->
  `ERROR: Found more than one migration with version 03`.
- Typing only `03_add_currency.up.sql` in **+ New file** -> the file lands next to `flyway.toml`, not in
  `migrations/`; Flyway never sees it. Type the `migrations/` part too.
- Forgetting Ctrl+S before `flyway migrate` -> Flyway runs what is on disk (maybe an empty file).
- `04.down` = `DROP TABLE coupons; ALTER TABLE orders DROP COLUMN currency;` -> a down undoes only its own
  migration; 03's down already drops currency.
- Fixing a mistake in 03 **after** it was applied by editing the file -> checksum mismatch (lab 07).
  Before it is applied (still Pending), editing is fine.
