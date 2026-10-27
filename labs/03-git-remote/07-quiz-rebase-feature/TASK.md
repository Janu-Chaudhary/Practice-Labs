# 07 · Quiz-style · Rebase feature onto main (quiz 2, Question 1 as a terminal task)

```
$ git log --graph --oneline --all --decorate
* d032d80 (feature) Strip whitespace in notes
* 1dbf664 Add notes
| * 0f708d1 (HEAD -> main) Update changelog
|/
* 47b8a42 Add README
```

**Context:** you're on `main`. `feature` was branched from "Add README" and has two commits.
Since then main got "Update changelog" (adds CHANGELOG.md). The team wants feature to sit on top
of the latest main, with no merge commit.

**Task:**
1. Switch to `feature`.
2. Rebase it onto `main`.
3. Look at `git log --graph --oneline --all` again and compare the hashes of "Add notes" and
   "Strip whitespace in notes" with the ones before. Run `ls`: CHANGELOG.md is there now.

**Stop:** don't merge, don't move main, stay on feature.

**What will be checked**
- on feature; main did not move
- feature is built on top of main, tip is "Strip whitespace in notes"
- feature has 4 commits and no merge commit; contains CHANGELOG.md
- feature commits got new ids
