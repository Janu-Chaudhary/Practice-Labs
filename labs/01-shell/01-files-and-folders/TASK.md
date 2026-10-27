# 01 - Files and folders (Drill)

## Situation
Your current folder (`work/`) is messy. It holds:

```
notes.txt  draft.txt  config.yml  tmp/  (tmp has cache files and a sub-folder)
```

There is no `project` folder and no `docs` folder yet.

## Task
1. Create the folder `project/src/utils` with **one** command (the parent folders don't exist yet).
2. Create an empty file `project/src/utils/__init__.py`.
3. Rename `notes.txt` to `README.md` (same folder, same contents).
4. Move `draft.txt` into a **new** folder `docs`, keeping its name (`docs/draft.txt`).
5. Make a copy of `config.yml` called `config.yml.bak`. The original must stay.
6. Delete the `tmp` folder and everything inside it.

## Stop
- Don't change the contents of any file.
- Don't delete anything except `tmp`.

## Hints
- Run `ls -la` often to see what you have. `pwd` tells you where you are.
- `mkdir --help` - look for the option that creates parent folders.
- Careful with step 4: if `docs` does not exist yet, `mv draft.txt docs` does **not** make a folder.

## What will be checked
- `project/src/utils/__init__.py` exists and is empty
- `README.md` has the old notes contents, `notes.txt` is gone
- `docs` is a folder and `docs/draft.txt` has the draft contents; `draft.txt` is gone from the top
- `config.yml` and `config.yml.bak` both exist with the same contents
- `tmp` is gone
