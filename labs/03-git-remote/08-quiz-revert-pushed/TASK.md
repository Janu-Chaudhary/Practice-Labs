# 08 · Quiz-style · Undo a commit that's already pushed

```
$ git log --graph --oneline --all --decorate
* dd073f4 (HEAD -> main, origin/main) Add order totals
* 0866799 Disable auth check
* d46757f Add orders route
* aa9edaf Add auth check

$ git status
On branch main
Your branch is up to date with 'origin/main'.
```

**Context:** "Disable auth check" made `is_allowed` always return `True` (a testing hack). It was
pushed, and teammates have already pulled main. After it came a good commit, "Add order totals".

**Task:**
1. Undo the change made by "Disable auth check" **without rewriting history** (teammates already
   have these commits), keeping "Add order totals".
2. Push main to origin.

**Hints:** look at the commit with `git show <hash>`. The command you need makes a new commit and
opens an editor for its message; `--no-edit` accepts git's default message.

**Stop:** no force push, make exactly one new commit.

**What will be checked**
- the old pushed tip is still in main (history not rewritten)
- main has 5 commits, last is `Revert "Disable auth check"`
- auth.py at main has `return user.is_logged_in`; orders.py still has `order_total`
- remote main == local main
