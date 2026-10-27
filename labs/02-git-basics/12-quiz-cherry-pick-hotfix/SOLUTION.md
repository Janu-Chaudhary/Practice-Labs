# Solution 12

```bash
git log feature --oneline | grep divide   # e.g.  4f2c9e1 Fix divide by zero   (your hash differs)
git cherry-pick 4f2c9e1                   # copy THAT commit onto main (use your hash)
#   [main 9a8b7c6] Fix divide by zero      <- a NEW hash: new parent = new commit object
git log --oneline --graph --all --decorate
git show main:calc.py                     # has "if b == 0"
ls                                        # no power.py, no docs/
git tag -a v1.0.1 -m "Hotfix: divide by zero"   # annotated tag on HEAD (= main's tip)
git tag                                   # v1.0.0  v1.0.1
git show v1.0.1                           # tag header (Tagger, message) then the commit
git cat-file -t v1.0.1                    # tag     (lightweight tags would print: commit)
```

No-copy-paste way to grab the hash: `git cherry-pick $(git log feature --format=%h --grep="divide")`.

Why each step:
- `git cherry-pick <hash>` takes the *change* that commit made (its diff against its parent) and replays
  it on top of the current branch as a brand-new commit with the same message. Only that one change
  comes over, so power.py (added by a different commit) stays on feature.
- The new commit has a different hash from the one on feature: its parent is different, and a commit's
  hash covers its parent. Same change, different object.
- `git tag -a v1.0.1 -m ...` creates an annotated tag: a real object in .git/objects (type `tag`) with
  a tagger, date and message, pointing at the commit. With no commit given it tags HEAD.

## Common wrong attempts
- `git merge feature`: brings all three commits (power.py, docs) and makes a merge commit. Fails.
  Undo before committing anything else: `git reset --hard ORIG_HEAD`.
- Cherry-picking while on feature: "empty commit / nothing to commit" because feature already has it.
  Switch to main first.
- `git cherry-pick feature`: `feature` means feature's TIP, so you copy "Document power()" instead.
- `git tag v1.0.1`: lightweight tag (`git cat-file -t v1.0.1` says `commit`). Fix:
  `git tag -d v1.0.1` then the `-a -m` command.
- Tagging before the cherry-pick: the tag sits on "Explain how to run". Fix: `git tag -d v1.0.1`, re-tag
  (or `git tag -f -a v1.0.1 -m "..."` to move it).
