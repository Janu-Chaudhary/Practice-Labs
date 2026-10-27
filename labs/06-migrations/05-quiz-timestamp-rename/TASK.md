# 05 - Rename a migration to a timestamp version and merge main (Quiz-style, Quiz 2 Q17)

```
952786f (main) Add coupons migration
eb08df8 (HEAD -> search) Add search index migration
d674b52 Add migrations 01 to 03
```
(your hashes differ)
```
$ git status
On branch search
nothing to commit, working tree clean
$ ls
migrations
```

**Context:** you're on the `search` branch, which adds `migrations/04_add_search_index.sql`. Your
teammate's `migrations/04_add_coupons.sql` is already on `main` and `search` does not have it yet. Git
merges the two branches without a conflict (different file names!), but the migration runner refuses
two migrations with version 04.

**Task:** make `search` safe to merge. Give your migration the timestamp version `202610071517` in place
of `04`, bring everything from `main` into `search`, and commit.

**Stop:** don't push, and leave the coupons migration as it is.

**Hints**
- Version = everything before the first `_`. So the new name is `migrations/202610071517_add_search_index.sql`.
- Rename with `git mv old new` (it stages the delete + add in one go).
- `git merge main` opens an editor for the merge-commit message. Add `--no-edit` to accept the default.
  (If vim opens: type `:wq` Enter. If nano: Ctrl+O, Enter, Ctrl+X.)

**What will be checked**
- `migrations/202610071517_add_search_index.sql` at search contains "CREATE INDEX"
- `migrations/04_add_search_index.sql` is gone
- `migrations/04_add_coupons.sql` exists (unchanged)
- main is merged into search (and main itself is unchanged); tree clean; nothing pushed
