# Solution - 12 health-check script, streams and exit codes

```bash
cat bin/healthcheck.sh
#   always read a script before running it
chmod +x bin/healthcheck.sh
#   add the execute permission; without it ./bin/healthcheck.sh -> "Permission denied"
mkdir reports
./bin/healthcheck.sh > reports/ok.txt 2> reports/errors.txt
#   > (same as 1>) catches stdout, 2> catches stderr -> two files, nothing on screen
./bin/healthcheck.sh > reports/all.txt 2>&1
#   first point stdout at the file, THEN "2>&1" = stderr goes where stdout goes now (the file)
./bin/healthcheck.sh > /dev/null 2>&1; echo $? > reports/exit-code.txt
#   ; runs the next command no matter what. $? = exit code of the script (1: some are down)
echo "down: $(wc -l < reports/errors.txt)" > reports/summary.txt
#   $( ) is replaced by wc's output (2). "< file" so wc prints only the number. Double quotes keep $( ) working
./bin/healthcheck.sh > /dev/null 2>&1 && echo "$(date +%F) all up" >> status.txt || echo "$(date +%F) ALERT services down" >> status.txt
#   script fails (exit 1) -> the && part is skipped -> the || part runs. >> appends, keeps the old lines
cat reports/*.txt status.txt
```

Expected `reports/all.txt` (same order as the script prints them):
```
OK    orders
ERROR payments is down
OK    users
ERROR search is down
OK    health
```

Other ways that also pass:
- Step 1: `chmod 755 bin/healthcheck.sh` (rwx for you, r-x for others). `chmod u+x` also works.
- Step 3: `./bin/healthcheck.sh &> reports/all.txt` (bash shortcut for "both streams").
- Step 4: run the script on its own line, then `echo $? > reports/exit-code.txt` as the **very next** command.
- Step 5: `echo "down: $(grep -c ERROR reports/errors.txt)" > reports/summary.txt`.
- Step 6 with if: `if ./bin/healthcheck.sh > /dev/null 2>&1; then echo "$(date +%F) all up" >> status.txt; else echo "$(date +%F) ALERT services down" >> status.txt; fi`

## Common wrong attempts
- `healthcheck.sh` typed alone (e.g. after `cd bin`) -> `command not found`: a bare name is only looked up in the
  PATH folders, never the current folder. Give a path: `./healthcheck.sh` or `./bin/healthcheck.sh`.
- `bash bin/healthcheck.sh` runs it without chmod, but the task (and the check) wants the file executable.
- `./bin/healthcheck.sh > reports/ok.txt` alone -> the ERROR lines still print on the screen and `errors.txt` is never made.
- `./bin/healthcheck.sh 2>&1 > reports/all.txt` -> only the OK lines reach the file; ERRORs still go to the screen.
- `./bin/healthcheck.sh > out; cat out; echo $?` -> prints `0`: that is cat's exit code, not the script's.
- `echo 'down: $(wc -l < reports/errors.txt)'` -> single quotes: the file gets the text `$(wc ...)` literally.
- `echo "down: $(wc -l reports/errors.txt)"` -> `down: 2 reports/errors.txt` (wc adds the file name).
- `... && echo ... > status.txt` -> `>` wipes the 2 old lines. Logs are appended with `>>`.
- Running step 6 twice -> two ALERT lines. If it happens, open `status.txt` in the Files panel, delete the extra
  line, save with Ctrl+S; or run `./setup.sh` in the lab folder to start over (that resets everything).
