# Terminal practice pack

Hands-on practice for the terminal tasks in the Creative Problem Solving quizzes.

## Start here
1. Open `guide.html` in your browser and read **Start here**. Do the one-time setup it lists.
2. Practise in the quiz-style browser tool:
   ```
   ~/Desktop/csp/practice/start-lab-tool.sh
   ```
   It opens http://127.0.0.1:8765. Keep that terminal open; Ctrl+C stops it.

## What's inside
| Path | What it is |
|---|---|
| `guide.html` | Topic guides: mental models, commands, errors, traps, worked scenarios, cheat sheets |
| `start-lab-tool.sh`, `lab-tool/` | The browser tool: task, file panel, real terminal, Check button |
| `labs/01-shell` … `labs/06-migrations` | The labs: each folder has `TASK.md`, `setup.sh`, `check.sh`, `SOLUTION.md` |
| `labs/bin/flyway` | Runs Flyway through Docker (put `labs/bin` on your PATH, see the guide) |
| `_build/` | Source of `guide.html`. Rebuild with `python3 _build/assemble.py` |

## Without the browser tool
```
cd labs/02-git-basics/05-quiz-fix-greeting
./setup.sh && cd work      # fresh scenario
# ...solve TASK.md...
../check.sh                # grade
cd .. && ./setup.sh        # start over
```
