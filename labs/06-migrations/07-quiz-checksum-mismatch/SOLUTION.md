# Solution - 07 checksum mismatch

```bash
cd work
flyway migrate
# ERROR: Validate failed: Migrations have failed validation
# Migration checksum mismatch for migration version 02
# -> Applied to database : -1234567890
# -> Resolved locally    : 987654321
# Either revert the changes to the migration, or run repair to update the schema history.
git log --oneline                      # teammate's "Fix billing migration" on top
git diff HEAD~1 HEAD                   # 02 gained the billing_email line
git restore --source=HEAD~1 migrations/02_add_billing.up.sql migrations/02_add_billing.down.sql   # 02 back to applied version
echo "ALTER TABLE users ADD COLUMN billing_email TEXT;" > migrations/03_add_billing_email.up.sql
echo "ALTER TABLE users DROP COLUMN billing_email;"     > migrations/03_add_billing_email.down.sql
flyway migrate                         # validate OK now; applies 03 only
flyway info                            # 01 02 03 Success
git add -A
git commit -m "Move billing_email into migration 03; restore applied 02"
git status                             # clean (shop.db ignored)
```
Alternative for step 2: `git revert HEAD --no-edit` (new commit that undoes the teammate's commit),
then add the 03 files and commit them. Both keep history.

**Why not edit 02?** Flyway stores a checksum of every applied file. Changing the file changes the
checksum, and Flyway stops *before running anything* (append-only, ordered, checksum-verified log).
Also: production already ran the old 02, so editing it would never add billing_email there.
The fix goes in the next migration.

**Why not `flyway repair`?** repair rewrites the stored checksum to match the edited file. Flyway is
happy, but `billing_email` is never created (02 is "done"), and every other database that already
ran 02 silently differs from a fresh one. Use repair only when the edit changes nothing in the
schema (e.g. you reverted the file, or changed a comment/whitespace) - or to clean a failed row.

**Common wrong attempts**
- `git reset --hard HEAD~1` -> loses the teammate's commit (history rewritten; check fails).
- Only restoring the up file -> down file still mentions billing_email for 02 (check fails).
- Restoring 02 but forgetting `flyway migrate` -> no history row for 03.
- Naming the file `03_add_billing_email.sql` -> not `.up.sql`, so Flyway doesn't see it.
