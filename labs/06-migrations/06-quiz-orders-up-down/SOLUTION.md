# Solution - 06 orders up/down (Q18 reconstruction)

```bash
cd work
flyway info                       # 01, 02 Success. Nothing pending.
echo "ALTER TABLE orders ADD COLUMN currency TEXT NOT NULL DEFAULT 'INR';" > migrations/03_add_currency.up.sql
echo "ALTER TABLE orders DROP COLUMN currency;"                             > migrations/03_add_currency.down.sql
echo "CREATE TABLE coupons (code TEXT PRIMARY KEY, percent INTEGER NOT NULL);" > migrations/04_create_coupons.up.sql
echo "DROP TABLE coupons;"                                                  > migrations/04_create_coupons.down.sql
flyway info                       # 03 and 04 Pending (down files are not listed: correct)
flyway migrate                    # Migrating ... "03 - add currency", "04 - create coupons"
flyway info                       # 01..04 Success
sqlite3 -header -column shop.db "SELECT * FROM orders;"                       # currency INR x3
sqlite3 shop.db ".schema coupons"
sqlite3 -header -column shop.db "SELECT version, script, success FROM flyway_schema_history;"
# test the reverse migrations on a copy, newest first
cp shop.db /tmp/t.db
sqlite3 /tmp/t.db < migrations/04_create_coupons.down.sql
sqlite3 /tmp/t.db < migrations/03_add_currency.down.sql
sqlite3 /tmp/t.db ".schema"        # back to orders + index only
```

Tip: using `echo "..." > file` with **double** quotes outside lets you put **single** quotes ('INR') inside.
Or just write the files in VS Code: `code migrations/03_add_currency.up.sql`.

**Why each piece**
- New change = new file with the next version (03, 04). Never edit 01/02: they are applied (checksums).
- `NOT NULL DEFAULT 'INR'`: SQLite fills old rows with the default; without DEFAULT it errors
  `Cannot add a NOT NULL column with default value NULL`.
- Down = the opposite statement, applied in reverse order. Dropping `currency` loses its values
  (fine here: they were all the default), see lab 03.
- Flyway runs each migration in a transaction on SQLite: if 04 fails, 04 rolls back, 03 stays applied.

**Common wrong attempts**
- `03-add-currency.up.sql` / `3.up.sql` / `03_add_currency.sql` -> `Invalid ... name` or the file is not a
  migration at all. Version, then `_`, then description, then `.up.sql`.
- `V3__add_currency.sql` -> that is Flyway's *default* naming; this project is configured for `03_...up.sql`.
- Two files with the same version (e.g. `03_add_currency.up.sql` and `03_create_coupons.up.sql`) ->
  `ERROR: Found more than one migration with version 03`.
- Running the down files on shop.db "to test" -> schema no longer matches history. Use a copy.
- Fixing a mistake in 03 **after** it was applied by editing the file -> checksum mismatch (lab 07).
  Before it is applied (still Pending), editing is fine.
