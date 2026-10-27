# 03 - Redirects and pipes (Drill)

## Situation
The current folder holds `visitors.txt`: one visitor name per line, in the order they arrived.
Some people visited more than once.

## Task
1. Create `hello.txt` in the **editor**: in the Files panel click **+ New file**, type `hello.txt`,
   then type exactly these two lines and save with Ctrl+S:
   ```
   first line
   second line
   ```
   (Text you type yourself goes in the editor. Steps 2-4 are made by **commands**, so they happen in the terminal.)
2. Create `top3.txt` with the **first 3 lines** of `visitors.txt`.
3. Create `line-count.txt` holding only the **number** of lines in `visitors.txt` (just the number, no file name).
4. Create `unique.txt`: every visitor name once, sorted A to Z.

## Stop
- Don't change `visitors.txt`.

## Hints
- `cmd > file` saves a command's output in a file (creates it, or wipes it first). `cmd >> file` adds to the end.
- `|` sends one command's output into the next command's input.
- `uniq` only removes duplicates that are **next to each other** - think about what must happen first.
- `wc -l visitors.txt` prints the number *and* the file name. How can you give `wc` the data without giving it the name?

## What will be checked
- `hello.txt`, `top3.txt`, `unique.txt` have exactly the expected lines
- `line-count.txt` holds the number `8` (spaces around it are OK)
- `visitors.txt` is unchanged
