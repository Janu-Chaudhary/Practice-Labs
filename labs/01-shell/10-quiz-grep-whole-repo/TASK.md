# 10 - Search a whole repository (Quiz-style, 8 marks)

## Situation
An AI assistant wrote a pull request for the `shop` app. It calls a function `issue_refund`.
Before merging you **validate** it against the real code (Quiz 1 Q14: "grep -rn finds nothing ... the method
doesn't exist"). While you are in there, you also check for hard-coded secrets (Topic 1: secrets belong in
the environment, never in committed code).

The current folder (`work/`) has a folder `shop` with sub-folders (`payments`, `config`, `tests`) and some
**hidden** files whose names start with a dot (`ls -la shop` shows them, plain `ls` doesn't).
There is no `reports` folder yet. Run every command from `work/` and search the folder **`shop`** by name.

## Task
1. `reports/refund-calls.txt`: every line, in **any file** under `shop`, that mentions `issue_refund`,
   in the form `path:line-number:text` (for example `shop/app.py:8:    return ...`), **sorted** with `sort`.
2. `reports/refund-defined.txt`: just the **number** of lines under `shop` that **define** it
   (a Python definition looks like `def issue_refund`). One number for the whole folder, not one per file.
3. `reports/secret-files.txt`: the **paths only** (one per line, sorted) of the files under `shop` that
   contain a hard-coded key: `API_KEY=` immediately followed by **at least one character**.
   An empty template line like `STRIPE_API_KEY=` is not a secret, and `STRIPE_API_KEY = os.environ[...]`
   (spaces, read from the environment) is not either.
4. `reports/todo-count.txt`: just the **number** of lines containing `TODO` in the **`.py` files** under `shop`
   (all sub-folders). `TODO`s in other files (like `README.md`) don't count.

## Stop
- Don't change, move or delete anything inside `shop`.
- Every report is the output of commands saved with `>`. Don't type or fix reports in the editor.

## Hints
- `grep -r PATTERN shop` searches every file in `shop` and its sub-folders and prefixes each line with the path.
- `-n` adds line numbers, `-l` prints only the names of files that match.
- In `grep -E`, `.` means "any one character" and `+` means "one or more of the thing before".
- `grep -c` with `-r` prints one count **per file** (`shop/app.py:1`, ...). To count across all files, pipe the lines into `wc -l`.
- To search only some files: `grep -r --include='*.py' ...`, or give the `.py` files yourself (`find shop -name '*.py'`).
- `grep -r` visits files in no guaranteed order. That's why the task says sort.

## What will be checked
- `reports/refund-calls.txt` is exactly the 5 matching lines as `shop/...:N:text`, sorted
- `reports/refund-defined.txt` holds just `0` (spaces/newline around it are fine)
- `reports/secret-files.txt` is exactly the 2 secret files, sorted
- `reports/todo-count.txt` holds just `4`
- nothing in `shop` changed
