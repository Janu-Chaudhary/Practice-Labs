# 10 - Two branches, two migration 05s (Twist)

**Situation.** Course naming (`NN_name.up.sql` + `NN_name.down.sql`). `main` and your local
`shop.db` are at 04. You are on branch `reviews`, which adds `05_create_reviews` (up + down).
Meanwhile a teammate merged `05_create_wishlist` (up + down) into `main`. `shop.db` is in `.gitignore`.

Unlike lab 05, here **both** files of your migration must move, and you finish by actually running Flyway.

**Task** (inside `work/`):
1. (Optional, to see the problem) `git merge main --no-edit`, then `flyway info` -> error. Undo with `git reset --hard HEAD~1` *only* if you merged (that merge is your own, unpushed).
2. Give your migration the timestamp version `202610261030`: rename **both** reviews files
   (`202610261030_create_reviews.up.sql` / `.down.sql`) and commit.
3. Merge `main` into `reviews`.
4. Run `flyway migrate` so your local `shop.db` gets both new tables. Check `flyway info`.

**Stop:** don't touch main's wishlist migration, don't change `main`, don't delete `shop.db`.

**Hints**
- `git mv` one file at a time.
- Flyway sorts versions as numbers: 05 < 202610261030, so wishlist runs first, then reviews.
- `git merge main` opens an editor; use `--no-edit`.

**What will be checked**
- both timestamp files at reviews, both `05_create_reviews.*` gone, wishlist files unchanged
- main merged into reviews, main unchanged, tree clean
- history has 05 (wishlist) and 202610261030 (reviews); both tables exist; `flyway validate` passes
