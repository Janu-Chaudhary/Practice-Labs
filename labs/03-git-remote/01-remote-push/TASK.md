# 01 · Drill · Connect a remote and push

```
$ git log --graph --oneline --all --decorate
* af141ef (HEAD -> main) Add tests
* 89e1b03 Add app

$ git remote -v
(no output: this repo has no remote yet)
```
(Your hashes will differ.)

**Context:** you're on `main` with two commits. The folder `remote.git` is an empty *bare*
repository. It plays the role of GitHub: a repository with no working directory that you only
push to and fetch from. (It is hidden from `git status` for you.)

**Task:**
1. Add `remote.git` as a remote called `origin`. Check it with `git remote -v`.
2. Push `main` to `origin` and make `main` track `origin/main` (use `-u`).
3. Create `docs.md` (any content), commit it with message `Add docs`, and push it with plain
   `git push` (no extra words: `-u` from step 2 is what makes this work).

**Stop:** don't create other branches.

**What will be checked**
- a remote called origin exists and points at remote.git
- remote.git main == local main
- main tracks origin/main
- main has 3 commits, the last is "Add docs"; docs.md is on origin

Hint: `git status` after step 2 should say `Your branch is up to date with 'origin/main'`.
