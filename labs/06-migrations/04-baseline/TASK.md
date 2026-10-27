# 04 - Adopting Flyway on an existing database: baseline (Drill)

**Situation.** `shop.db` was built by hand before the team used migrations. It already has the
`orders` table and its index (exactly what `01_...` and `02_...` create) and 3 real orders, but **no**
`flyway_schema_history` table. Now there is a new migration `03_add_currency.up.sql`.

**Task** (inside `work/`):
1. Run `flyway migrate` and read the error.
2. Tell Flyway "this database is already at version 02" with `flyway baseline`, then check `flyway info`.
3. Apply 03 with `flyway migrate`.

**Stop:** don't delete `shop.db` or the orders (deleting the file and migrating from zero would lose the 3 orders).

**Hints**
- `flyway baseline -baselineVersion=02` creates the history table with one BASELINE row.
  Migrations at or below the baseline are then treated as already done.
- Flags go **after** the command: `flyway <command> -name=value`.

**What will be checked**
- history has a BASELINE row at 02, no rows that ran 01/02, and 03 Success
- orders keeps 3 rows, all with currency INR
