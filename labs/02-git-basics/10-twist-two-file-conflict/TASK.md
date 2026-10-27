# 10 - Twist: two conflicting files and a new file

```
$ git log --graph --oneline --all --decorate
* xxxxxxx (HEAD -> main) Warmer greeting, port 8080
| * xxxxxxx (feature) Rework greeting, move port, add docs
|/
* xxxxxxx Add greet and config
```
Both branches changed greet.py's return line and config.py's PORT line. feature also added docs/USAGE.md.

## Task
1. Merge feature into main.
2. Resolve so that (edit greet.py in the Files panel and save with Ctrl+S):
   - greet.py is exactly
     ```python
     def greet(name):
         return f"Hi, {name}! Good to see you."
     ```
   - config.py is feature's version (`PORT = 9000`, `DEBUG = False`).
   - docs/USAGE.md from feature is kept.
3. Finish the merge (no editor needed: `--no-edit`, or `-m "..."`).

## Stop
No other commits. Don't delete feature.

## What will be checked
- feature merged; main has 4 commits; tip has 2 parents
- greet.py and config.py at main as above; docs/USAGE.md at main
- no conflict markers in any file at main; clean tree on main
