# Solution - 04 baseline

```bash
cd work
flyway migrate
# ERROR: Found non-empty schema(s) "main" but no schema history table.
#        Use baseline() or set baselineOnMigrate to true to initialize the schema history table.
flyway baseline -baselineVersion=02     # create flyway_schema_history with a BASELINE row "02"
flyway info                             # 01 Below Baseline, 02 Baseline, 03 Pending
flyway migrate                          # runs only 03
sqlite3 -header -column shop.db "SELECT * FROM orders;"   # currency = INR on all 3 rows
```

Why the error? Flyway refuses to run 01 (`CREATE TABLE orders`) on a database that already has
tables but no history: it can't know what was done by hand. A baseline is you telling it.

Why INR in the old rows? `ADD COLUMN ... NOT NULL DEFAULT 'INR'` fills existing rows with the default.
(SQLite refuses `ADD COLUMN ... NOT NULL` with no default when the table has rows.)

**Common wrong attempts**
- `flyway baseline` with no version -> baseline is version `1`, then Flyway runs `02` and fails:
  `index idx_orders_user already exists`. (Fix: `./setup.sh` and redo with `-baselineVersion=02`.)
- Deleting shop.db and running migrate -> schema is right, but the 3 orders are gone. Never on real data.
- `flyway -baselineVersion=02 baseline` actually works too (flags can go anywhere), but keep one style.
