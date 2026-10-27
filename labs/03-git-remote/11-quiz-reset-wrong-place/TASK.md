# 11 · Quiz-style (hard) · reset --hard to the wrong place, then you kept working

```
$ git log --graph --oneline --all --decorate
* 807663c (HEAD -> main) Fix typo in README
* 98ef414 (origin/main) Add README
* 55d4497 Add app

$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```
(Your hashes will be different.)

**Context:** "Add app" and "Add README" were pushed. Then you committed "Add cart" (cart.py) and
"Add discount" (discount.py), **not pushed**. You wanted to throw away a messy uncommitted
experiment and typed `git reset --hard origin/main`. That also moved main back past your two
commits. You didn't notice, and committed "Fix typo in README" on top. Now `cart.py` and
`discount.py` are gone from your folder and from `git log`.

**Task:**
1. Find "Add cart" and "Add discount" again (they still exist; `git reflog` shows every place HEAD
   has been, newest first).
2. Make main a straight line, in this order:
   `Add app → Add README → Add cart → Add discount → Fix typo in README`.
   "Add cart" and "Add discount" must be the **original** commits (same hashes), and the typo fix
   must sit on top of them.
3. Push main to origin.

**Stop:** no merge commit, no force push, don't lose the typo fix, don't re-create cart.py or
discount.py by hand (that makes new commits with new hashes).

**Hints:**
- `git reset --hard <hash>` alone gets the two commits back but loses the typo fix. Which command
  replays *only the commits you have that another commit doesn't*, on top of that commit?
  Or: which command copies one commit onto where you are now?
- If something goes wrong: `git reflog` again. Nothing is really lost until garbage collection.

**What will be checked**
- on main, nothing in progress, working tree clean
- main has 5 commits, no merge commit
- main~2 is the original "Add cart", main~1 the original "Add discount", tip is "Fix typo in README"
- cart.py and discount.py exist at main; README is `# Orders API`
- remote main == local main
