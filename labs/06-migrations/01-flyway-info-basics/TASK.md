# 01 - Read `flyway info`, then migrate step by step (Drill)

**Situation.** `work/` holds `flyway.toml` (Flyway's settings), a `migrations/` folder and `shop.db`.
This lab uses the **course naming**: `NN_name.up.sql` is a migration, `NN_name.down.sql` is its reverse.
Some migrations are already applied to `shop.db`. Some new ones just came from git.
You never open `shop.db` yourself: Flyway's **history table** remembers what is applied, and
`flyway info` prints it for you.

**Task** (inside `work/`):
1. Run `ls migrations` to see the files. Then run `flyway info`.
   Read two things: the line `Schema version: ...` above the table, and the **State** column.
2. In the Files panel click **+ New file**, type `answer.txt`, and write two lines:
   - line 1: the schema version `flyway info` printed
   - line 2: how many migrations are in state **Pending**

   Save with **Ctrl+S**.
3. Apply **only up to 03**, not 04 (04 is for next week's release).
4. Run `flyway info` again. Which state does 04 show now? What is the schema version now?

**Stop:** don't edit or delete migration files; don't delete `shop.db`; don't apply 04.

**Hints**
- `flyway` is a small script that runs Flyway inside Docker. If you get `command not found`, run the
  `export PATH=...` line that `setup.sh` printed.
- Flags go **after** the command: `flyway migrate -target=03` stops at version 03.
- `.down.sql` files never show up in `flyway info`: Flyway (free edition) does not run them.

**What will be checked**
- `answer.txt`: line 1 = schema version before you migrated, line 2 = number of Pending migrations
- history: 01, 02, 03 Success; 04 not applied
- data kept, files unchanged
