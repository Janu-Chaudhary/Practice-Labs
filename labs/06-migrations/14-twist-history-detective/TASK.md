# 14 - History table detective + a harmless edit (Twist)

**Situation.** Course naming. `work/` is a git repo; `shop.db` (in `.gitignore`) has a long story:
it was built partly by hand, adopted by Flyway, and one migration arrived late. Nobody wrote the story
down, but the **history table** `flyway_schema_history` remembers. Then, in the last commit, someone added
a `--` comment to the already-applied `03_add_city.up.sql`, and now `flyway validate` fails.

**Task part A - answer from the history table** (inside `work/`). Use sqlite3 queries on
`flyway_schema_history` (and `flyway info`), and save each answer as a single value with a redirect:
1. `q1.txt`: the **version** of the migration Flyway executed **most recently** (the last one it ran).
2. `q2.txt`: the **current schema version** of this database (what `flyway info` prints as "Schema version").
3. `q3.txt`: the **checksum stored in the history table** for version 03 (right now, before part B).
4. `q4.txt`: the version of the migration whose file exists in `migrations/`, but whose SQL Flyway
   **never executed** on this database.

**Task part B - fix validate.**
5. Run `flyway validate`, read the error. Use git to see exactly what changed in 03.
6. The change is only a comment and the team wants to keep it. Make `flyway validate` pass **without
   touching 03 or git history**. Then `flyway migrate` says up to date.

**Stop:** don't edit/revert/rename migration files; don't commit or rewrite history; don't run SQL that
changes `flyway_schema_history` by hand; don't delete `shop.db`. Do part A (q3!) before part B.

**Hints**
- Columns worth knowing: `installed_rank` (1, 2, 3... in the order Flyway ran them), `version`, `type`
  (`SQL` or `BASELINE`), `script`, `checksum`, `success`.
- Highest version is not always the last one run. `ORDER BY installed_rank DESC LIMIT 1`.
- One value only: `sqlite3 shop.db "SELECT ... ;" > q1.txt`. Versions are text here: `'03'`, not `3`.
- Lab 07 said "don't repair". Ask yourself what is different here: does the edit change what the SQL does?

**What will be checked**
- q1..q4 contain the right values (whitespace ignored)
- `flyway validate` passes; the history checksum of 03 now matches the commented file
- 03 still has the comment; no files changed or committed (HEAD is still the comment commit, tree clean)
- data intact: 3 users, 3 orders, history still has 5 rows
