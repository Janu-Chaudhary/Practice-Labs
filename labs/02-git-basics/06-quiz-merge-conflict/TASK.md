# 06 - Quiz-style: resolve a merge conflict (recreates Quiz 1 Q17, 6 marks)

```
$ git log --graph --oneline --all --decorate
* xxxxxxx (HEAD -> main) Welcome returning users
| * xxxxxxx (feature) Use friendlier greeting
|/
* xxxxxxx Add greet

$ git status
On branch main
nothing to commit, working tree clean
```
greet.py on main
```python
def greet(name):
    return f"Hello, {name}! Welcome back."
```
Context: you're on main. Both branches started from "Add greet". main changed the return line one
way, feature changed the same line differently. Nothing is staged, no merge in progress.

## Task
1. Merge feature into main.
2. Resolve the conflict (in your editor) so greet.py is exactly this, with no conflict markers left:
   ```python
   def greet(name):
       return f"Hi there, {name}! Welcome back."
   ```
3. Finish the merge by committing it with no message (git uses its own merge message) or with `-m "..."`.

Hint: `git commit` with no `-m` OPENS AN EDITOR (often vim). In vim type `:wq` then Enter.
In nano press Ctrl+O, Enter, Ctrl+X. Or skip the editor: `git commit --no-edit`.

## Stop
Make no other commits, don't delete feature.

## What will be checked
- feature is merged into main
- greet.py at main has the expected content
- main has 4 commits (Add greet, Welcome returning users, Use friendlier greeting, the merge commit)
