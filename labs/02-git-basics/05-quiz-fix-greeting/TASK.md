# 05 - Quiz-style: fix-greeting (recreates Quiz 1 Q16, 4 marks)

```
$ git log --graph --oneline --all --decorate
* xxxxxxx (HEAD -> main) Add greet

$ git status
On branch main
nothing to commit, working tree clean
```
greet.py
```python
def greet(name):
    return "Hello " + name
```

Context: you're on main, which has one commit ("Add greet") containing greet.py. Nothing is staged,
modified or untracked. There are no other branches, and nothing has been pushed.

## Task
1. Create a branch called `fix-greeting` from main and switch to it.
2. Change greet.py (in your editor: `code greet.py` or `nano greet.py`) so that it is exactly (type it, no copy):
   ```python
   def greet(name):
       return f"Hello, {name}!"
   ```
3. Commit the change with message `Use f-string in greeting`.

## Stop
After the commit stay on fix-greeting. Do not push or merge it into main.

## What will be checked
- branch fix-greeting exists
- on branch fix-greeting
- greet.py at fix-greeting has the expected content
- fix-greeting is the commit "Use f-string in greeting"
