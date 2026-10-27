# 02 - branch and switch (Drill)

## Situation
```
$ git log --oneline --graph --all --decorate
* xxxxxxx (HEAD -> main) Add app
* xxxxxxx Add readme
```

## Task
1. Create a branch `docs` and switch to it in **one** command.
2. In the Files panel open `README.md`, add a new last line `## Install`, save with Ctrl+S.
   Then commit with message `Add install section`.
3. Switch back to `main`.
4. Create a branch `hotfix` from main **without** switching to it.
5. Run `git log --oneline --graph --all --decorate` and find each branch label.

## Stop
No commits on main. End on main.

## What will be checked
- branches docs and hotfix exist; hotfix = main
- main has 2 commits, docs has 3, docs tip is "Add install section"
- README.md at docs has `## Install`, at main it does not
- current branch main, working tree clean
