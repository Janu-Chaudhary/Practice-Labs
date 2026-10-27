# 13 - Two late migrations: one gets outOfOrder, one gets a new version (Twist)

**Situation.** Course naming with **timestamp versions** (`yyyyMMddHHmm_name.up.sql` / `.down.sql`).
`work/` is a git repo on `main`; `shop.db` is in `.gitignore`. Your local `shop.db` has
`202610201000_create_orders` and `202610251200_create_coupons` applied (3 orders).
Two files with **lower** timestamps have just appeared:

- `202610221500_add_order_status` (up + down): a teammate's hotfix you just pulled (last commit).
  It is **already applied in production with that version**.
- `202610231000_add_order_notes` (up + down): your own work from Oct 23 that you forgot about.
  **Never committed, never applied anywhere.**

Both are lower than 202610251200, which is already applied, so Flyway refuses to migrate.

**Task** (inside `work/`):
1. Run `flyway info`. Write the **State** it shows for the two late files (one word) into `answer.txt`
   (Files panel: **+ New file**, type `answer.txt`, write the word, save with **Ctrl+S**).
   Run `flyway migrate` and read the error.
2. Decide per file:
   - The hotfix must keep its version (production's history table already has 202610221500).
   - Your notes migration ran nowhere, so give it a fresh timestamp **`202610271100`** (both up and down),
     so it is simply the newest migration. Commit the renamed files.
3. Apply everything with a single `flyway migrate` that allows the hotfix out of order. Check `flyway info`.

**Stop:** don't rename or edit the teammate's files; don't rewrite git history; don't delete `shop.db` or
orders; don't add `outOfOrder` to `flyway.toml` (allow it only for this run); and **rename your file
before** you run anything with outOfOrder (otherwise your old version gets applied too).

**Hints**
- `git mv` only works on files git already tracks. Your notes files are **untracked**: use plain `mv`,
  then `git add`.
- Flags go after the command: `flyway migrate -outOfOrder=true`.
- `flyway info` shows a migration applied out of order with its own state name - look for it.
- `flyway info` lists applied migrations in the order they **ran** (see `Installed On`), not by version.

**What will be checked**
- `answer.txt` = the state word; hotfix files unchanged with the same name; notes files renamed to 202610271100
- history: 202610221500 applied after 202610251200; 202610271100 applied; 202610231000 never; 4 rows, none failed
- `flyway.toml` unchanged; `flyway validate` passes; orders: 3 rows with status `placed` and a notes column
- teammate's commit still in history; the renamed files committed; tree clean (answer.txt may stay untracked)
