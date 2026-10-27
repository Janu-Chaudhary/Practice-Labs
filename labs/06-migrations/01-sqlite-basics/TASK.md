# 01 - sqlite3 basics (Drill)

**Situation.** `shop.db` is an SQLite database: one ordinary file that holds tables.
You talk to it with the `sqlite3` command-line tool. Every migration lab uses it to look inside the database.

**Task** (inside `work/`):
1. Open the database and look around: list the tables, then show how `orders` is defined, then show all orders. Leave with `.quit`.
2. Without opening the interactive prompt, add an order with **id 4, user_id 2, total 750**.
3. Save the **number of orders whose total is greater than 300** into `answer.txt` (just the number).
   Use a one-shot `sqlite3` command and a redirect (`>`), do not type the number yourself.

**Stop:** don't change the `users` table, don't delete `shop.db`.

**Hints**
- `sqlite3 shop.db` opens a prompt `sqlite>`. Dot-commands (`.tables`, `.schema orders`, `.headers on`, `.mode column`, `.quit`) have **no** semicolon. SQL statements **end with `;`** (forget it and you get a `...>` continuation prompt: type `;` and Enter).
- One-shot form: `sqlite3 shop.db "SQL HERE"` runs one statement and exits.

**What will be checked**
- orders has 4 rows; order 4 is user 2 with total 750
- users still has 3 rows
- `answer.txt` contains the correct count (whitespace ignored)
