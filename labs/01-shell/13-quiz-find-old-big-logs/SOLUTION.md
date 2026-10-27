# Solution - 13 find old and big logs

```bash
ls -l project/*/logs project/web
#   look first: sizes (column 5) and dates
mkdir reports archive backup
#   > , mv and cp don't create folders
find project -type f -name '*.log' -size +100k | sort > reports/big-logs.txt
#   files, named *.log, bigger than 100 KiB. sort: find's order is not guaranteed
find project -type f -name '*.log' | wc -l > reports/log-count.txt
#   one path per line -> wc -l counts them -> 5
find project -type f -name '*.log' -mtime +14
#   dry run: read the list (api-2026-09.log, worker-2026-09.log, access.log) BEFORE moving
find project -type f -name '*.log' -mtime +14 -exec mv {} archive/ \;
#   same search, now mv each one into archive/ (flat, names kept)
cp -r project/config backup/
#   -r copies the folder with everything inside (sub-folders, hidden files) -> backup/config/...
ls -la archive backup/config backup/config/secrets
cat reports/big-logs.txt reports/log-count.txt
```

Expected `reports/big-logs.txt`:
```
project/api/logs/api.log
project/worker/logs/worker-2026-09.log
```

Other ways that also pass:
- Step 3: `mv $(find project -type f -name '*.log' -mtime +14) archive/` (the shell replaces `$( )` with the 3 paths,
  so it becomes one `mv a b c archive/`). Fine here; it breaks on file names with spaces, `-exec` doesn't.
- Step 3: `find project -name '*.log' -mtime +14 -exec mv -t archive/ {} +` (`+` = one mv for all files).
- Step 4: `mkdir -p backup && cp -r project/config backup/config` (backup/config doesn't exist yet, so cp creates it as the copy).
- Step 2: `find project -name '*.log' | wc -l` gives 5 too (no folder here ends in `.log`), but `-type f` is the safe habit.

## Common wrong attempts
- `find project -name '*log*' | wc -l` -> 8: also matches the two `logs` folders and `logs-howto.md`. Count only `-type f -name '*.log'`.
- `find project -name *.log` (no quotes) -> works by luck here, but if a `.log` file is in the current folder the shell
  expands `*.log` first and find gets the wrong pattern (`find: paths must precede expression`).
- `ls project/*.log` -> nothing: `*` doesn't go into sub-folders. That's what find is for.
- `-size 100k` (no `+`) -> means *exactly* 100 KiB (rounded), so nothing matches. `+` = more than, `-` = less than.
- `-mtime 14` (no `+`) -> exactly 14 days old. `+14` = older than 14 days.
- Moving first, then running step 1 -> `worker-2026-09.log` is now in `archive/` and missing from the big-logs list.
- `find ... -exec mv {} archive/` without `\;` -> `find: missing argument to '-exec'`.
- `cp project/config/* backup/` -> `cp: -r not specified; omitting directory 'project/config/secrets'` (so `secrets/.keep` is lost), and
  the files land directly in `backup/` (no `config` folder).
- `mkdir -p backup/config && cp -r project/config backup/config` -> the destination already exists, so you get
  `backup/config/config/...`. Either copy to `backup/` or let cp create `backup/config`.
