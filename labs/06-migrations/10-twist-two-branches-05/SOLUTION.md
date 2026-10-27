# Solution - 10 two branches, two 05s

```bash
cd work
git log --oneline --graph --all        # main and reviews both have a commit after "01 to 04"
# (optional) see the collision:
git merge main --no-edit               # merges cleanly - git sees different file names
flyway info                            # ERROR: Found more than one migration with version 05
git reset --hard HEAD~1                # undo YOUR unpushed merge only
# the fix
git mv migrations/05_create_reviews.up.sql   migrations/202610261030_create_reviews.up.sql
git mv migrations/05_create_reviews.down.sql migrations/202610261030_create_reviews.down.sql
git commit -m "Use timestamp version for reviews migration"
git merge main --no-edit               # bring wishlist 05 in
flyway info                            # 05 Pending, 202610261030 Pending
flyway migrate                         # runs 05 then 202610261030
flyway info
```

**Why it works:** versions are compared as numbers. `202610261030` sorts after any small sequence
number, and is unique because two people rarely write a migration in the same minute.

**Trap - out of order:** if your laptop had already applied a version *higher* than a migration that
arrives later (e.g. you applied 202610261030 *before* merging main's 05), `flyway migrate` refuses:
`Detected resolved migration not applied to database: 05 ... To allow executing this migration, set -outOfOrder=true`.
Then `flyway migrate -outOfOrder=true` runs it (info shows `Out of Order`). Once a project uses
timestamps, all new migrations should use timestamps too.

**Common wrong attempts**
- Renaming only the `.up.sql` -> `05_create_reviews.down.sql` is left behind and now pairs with nothing.
- Renaming main's wishlist file instead -> other databases already recorded 05 = wishlist.
- `mv` + `git commit -am` -> new names are untracked, not committed.
