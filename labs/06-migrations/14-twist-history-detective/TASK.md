# 14 - History table detective + a harmless edit (Twist)

**Situation.** Course naming. `work/` is a git repo; `shop.db` (in `.gitignore`) has a long story:
it was built partly by hand, adopted by Flyway, and one migration arrived late. Nobody wrote the story
down, but the **history table** `flyway_schema_history` remembers, and `flyway info` shows it.
Then, in the last commit, someone added a `--` comment to the already-applied `03_add_city.up.sql`,
and now `flyway validate` fails.

**Task part A - answer from `flyway info`** (inside `work/`). Run `flyway info` and read it carefully
(also `ls migrations`). Save each answer in its own file: in the Files panel click **+ New file**, type the
name (`q1.txt` ...), write **only the answer**, save with **Ctrl+S**.
1. `q1.txt`: the **version** of the migration Flyway executed **most recently** (the last one it ran).
2. `q2.txt`: the **current schema version** of this database.
3. `q3.txt`: the **State** that `flyway info` shows for the migration in your answer to q1.
4. `q4.txt`: the version of the migration whose file exists in `migrations/`, but whose SQL Flyway
   **never executed** on this database.

**Task part B - fix validate.**
5. Run `flyway validate`, read the error. Use git to see exactly what changed in 03.
6. The change is only a comment and the team wants to keep it. Make `flyway validate` pass **without
   touching 03 or git history**. Then `flyway migrate` says up to date.

**Stop:** don't edit/revert/rename migration files; don't commit or rewrite history; don't change
`shop.db` except through Flyway; don't delete `shop.db`.

**Hints**
- `flyway info` lists applied rows in the order Flyway **ran** them, with `Installed On` times.
  That is not always version order.
- Highest applied version is not always the last one run.
- The `Type` column says `SQL` (Flyway ran a file) or `BASELINE` (a marker: "everything up to here was
  already there"). Look at the State of the 01 file.
- Lab 07 said "don't repair". Ask yourself what is different here: does the edit change what the SQL does?

**What will be checked**
- q1..q4 contain the right values (whitespace and upper/lower case ignored)
- `flyway validate` passes; the stored checksum of 03 now matches the commented file
- 03 still has the comment; no files changed or committed (HEAD is still the comment commit, tree clean)
- data intact: 3 users, 3 orders, history still has 5 rows
