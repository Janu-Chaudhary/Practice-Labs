# Solution - 01 files and folders

Run these inside `work/`:

```bash
mkdir -p project/src/utils          # -p = create every missing parent (project, project/src) too; no error if it exists
touch project/src/utils/__init__.py # touch makes an empty file if it doesn't exist (only updates the time if it does)
mv notes.txt README.md              # mv to a name that is NOT an existing folder = rename
mkdir docs                          # the destination folder must exist first
mv draft.txt docs/                  # mv into an existing folder = move, name kept -> docs/draft.txt
cp config.yml config.yml.bak        # cp leaves the original; the second name is the new copy
rm -r tmp                           # -r = recursive: needed to delete a folder and everything inside it
ls -la                              # look at the result
```

## Common wrong attempts
- `mkdir project/src/utils` (no `-p`) -> `mkdir: cannot create directory 'project/src/utils': No such file or directory`, because `project` does not exist yet.
- `mv draft.txt docs` **before** `mkdir docs` -> no error at all! It silently renames `draft.txt` to a *file* called `docs`. Writing `mv draft.txt docs/` (trailing slash) is safer: it fails with `Not a directory` instead of renaming.
- `rm tmp` -> `rm: cannot remove 'tmp': Is a directory`. Folders need `-r`. (`rmdir tmp` only works for empty folders.)
- `cp config.yml.bak config.yml` (arguments swapped) -> `No such file or directory`: the order is always `cp SOURCE DEST`.
- `rm -rf` with a typo or a stray space (`rm -rf tmp /`) deletes things for good. There is no recycle bin in the terminal - read the line before pressing Enter.
