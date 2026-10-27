# 12 - Quiz-style: copy one commit to main, then tag the hotfix

```
$ git log --graph --oneline --all --decorate
* xxxxxxx (feature) Document power()
* xxxxxxx Fix divide by zero
* xxxxxxx Add power()
| * xxxxxxx (HEAD -> main) Explain how to run
|/
* xxxxxxx (tag: v1.0.0) Add calc

$ git status
On branch main
nothing to commit, working tree clean
```
Context: you're on main. feature has three commits. One of them, "Fix divide by zero", fixes a crash
in calc.py that users hit today. power() and its docs are NOT finished and must not reach main yet.
v1.0.0 is an annotated tag on the first commit. Nothing has been pushed.

## Task
1. Bring **only** the "Fix divide by zero" commit onto main. main gets exactly one new commit
   with the same message. Do not merge feature.
2. Tag main's new tip with an **annotated** tag `v1.0.1` with message `Hotfix: divide by zero`.

Hints:
- You need the commit's hash. `git log feature --oneline` (or pipe it into `grep divide`).
- `git cherry-pick <hash>` copies one commit onto the branch you are on. It does not open an editor.
- `git tag -a NAME` without `-m` OPENS AN EDITOR. Use `-m "..."`.
- `git tag NAME` (no `-a`, no `-m`) makes a *lightweight* tag: just a name, not an object. Not what's asked.

## Stop
No merge commit, no other commits. Don't change or delete feature. Don't move v1.0.0.

## What will be checked
- main has 3 commits; tip is "Fix divide by zero" with one parent; below it "Explain how to run"
- calc.py at main has the zero check; power.py and docs/USAGE.md are not on main
- feature not merged and unchanged
- v1.0.1 is an annotated tag on main's tip with the message above; v1.0.0 unchanged
- on main, clean tree
