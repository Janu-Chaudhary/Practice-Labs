# 10 · Twist · Which commit leaked the secret?

```
$ git log --oneline
a334702 (HEAD -> main) Add README
cfc90e8 Remove env file
40c5ef3 Add orders route
677777a Add config loader
7d44876 Add app

$ git status
On branch main
Untracked files:
	.env
```

**Context:** a secret scanner says `DB_PASSWORD` leaked through this repository. Someone committed
`.env` once and later deleted it in "Remove env file". The `.env` in your folder now is your own
local one (untracked) and must stay that way.

**Task:**
1. Find the commit that first added `.env` (search the history *of that path*, not the current
   files). Create a branch `leak` pointing at it, so the security team can inspect it.
2. Look at what leaked: print `.env` *as it was in that commit* (don't copy the value anywhere).
3. Make sure `.env` can never be committed again: create `.gitignore` in the Files panel
   (**+ New file**) with the line `.env`, save with Ctrl+S, and commit only `.gitignore` with
   message `Ignore .env`.

**Stop:** never commit `.env`, don't delete your local `.env`.

**Think:** after "Remove env file", is the password safe? (Answer in SOLUTION.md.)

**What will be checked**
- branch leak is the commit "Add config loader"
- main has 6 commits, last is "Ignore .env", which changed only .gitignore
- .env is ignored now, not in main, still on disk
