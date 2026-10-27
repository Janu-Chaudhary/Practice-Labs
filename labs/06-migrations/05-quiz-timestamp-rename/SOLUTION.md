# Solution - 05 timestamp rename (Q17)

```bash
cd work
git branch --show-current       # search  (be on the right branch first)
git mv migrations/04_add_search_index.sql migrations/202610071517_add_search_index.sql   # rename, staged
git commit -m "Rename search index migration to timestamp version"                       # commit the rename
git merge main --no-edit        # bring 04_add_coupons.sql in; merge commit with the default message
ls migrations                   # 01 02 03 04_add_coupons 202610071517_add_search_index
git log --oneline --graph --all # merge commit on search, main untouched
```

Order also works the other way round (merge first, then `git mv` + commit). Both end with main
merged into search and only the timestamp file for your migration.

Why a timestamp? Sequence numbers (04) are handed out by two people at once and collide.
A timestamp (yyyyMMddHHmm) is unique without coordination and sorts by when it was written.
Git sees two *different file names*, so it merges cleanly; only the runner sees "two version 04".

**Common wrong attempts**
- `mv` instead of `git mv`, then `git commit -am ...` -> `-a` stages the deletion but **not** the new
  untracked file: the commit loses your migration. Use `git mv`, or `git add -A migrations` after `mv`.
- Renaming to `202610071517.sql` or `V202610071517__add_search_index.sql` -> the check wants the exact name.
- `git merge search` while on main -> changes main, and the task says bring main INTO search.
- `git rebase main` -> rewrites search; the task asks for main merged in (a merge commit).
- Renaming `04_add_coupons.sql` too -> "leave the coupons migration as it is".
- Forgetting `--no-edit` and panicking in vim: `:wq` saves the default message and finishes the merge.
