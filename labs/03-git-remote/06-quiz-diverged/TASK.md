# 06 · Quiz-style · Diverged from origin (quiz 1, Question 11 as a terminal task)

```
$ git log --graph --oneline --all --decorate
* 0c4b258 (HEAD -> main) Log each request
| * 1894d77 (origin/main) Add README
|/
* aec22f7 Add app

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean
```

**Context:** a teammate pushed "Add README" to origin's main. You committed "Log each request"
locally, and your `git push` was rejected. The two commits change different files.

**Task:** get your commit onto origin and keep the teammate's commit there. Integrate with a
**merge** (the classic `git pull` or `git fetch` + `git merge origin/main`), then push.

**Stop:** no force push, don't throw away either commit, make no other commits.

**Heads-up:** on git 2.27+ a plain `git pull` on diverged branches may stop with
`fatal: Need to specify how to reconcile divergent branches.` Read it: it is asking *merge or
rebase?*. Answer with `git pull --no-rebase` (merge). The merge opens an editor for the message
unless you add `--no-edit`.

**What will be checked**
- teammate's "Add README" is still on origin (same commit, not rewritten)
- your "Log each request" is on origin
- remote main == local main
- main has 4 commits (Add app, both commits, merge commit)
