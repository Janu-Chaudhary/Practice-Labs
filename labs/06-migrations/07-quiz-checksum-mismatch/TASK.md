# 07 - Checksum mismatch: fix it with the NEXT migration (Quiz-style)

**Situation.** `work/` is a git repo. Migrations 01 and 02 were committed and applied to `shop.db`
(3 users, each with a `plan`). Then a teammate "fixed" the **already-applied** `02_add_billing.up.sql` in place:
they added a `billing_email` column to it (and to its down file) and committed that.
Now `flyway migrate` refuses to run. `shop.db` is in `.gitignore` (databases are not committed).

**Task** (inside `work/`):
1. Run `flyway migrate` and read the error. Use `git log` and `git diff` to see what changed in 02.
2. Put 02 (both `.up.sql` and `.down.sql`) back exactly as it was when it was applied.
3. Move the `billing_email` change into a new migration `03_<name>.up.sql`, with a reverse
   migration `03_<name>.down.sql`.
4. `flyway migrate` so 03 is applied. Commit your work.

**Stop:** don't use `flyway repair`, don't rewrite git history (no reset/rebase/amend of the teammate's
commit), don't delete `shop.db` or any users.

**Hints**
- Old version of a file: `git show HEAD~1:migrations/02_add_billing.up.sql`, or put it back with
  `git restore --source=HEAD~1 migrations/02_add_billing.up.sql`.
- Create the 03 files in the Files panel: **+ New file**, type the path (`migrations/03_...`), write the
  SQL, save with **Ctrl+S**.
- `git revert HEAD --no-edit` undoes a whole commit with a NEW commit (history is kept).

**What will be checked**
- 02 up/down identical to the first commit; a 03 up/down pair for billing_email
- `flyway validate` passes; history has 03; 02's stored checksum is still the original (no repair)
- users has billing_email and still 3 rows with plans; teammate's commit still in history; tree clean
