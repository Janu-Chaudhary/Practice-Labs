# Solution - 01 sqlite3 basics

```bash
cd work
sqlite3 shop.db                 # open the interactive prompt on this file
sqlite> .tables                 # list tables:  orders  users
sqlite> .schema orders          # the CREATE TABLE statement that defines orders
sqlite> .headers on             # print column names
sqlite> .mode column            # line columns up
sqlite> SELECT * FROM orders;   # all rows; SQL needs the ;
sqlite> .quit                   # leave (Ctrl+D also works)

sqlite3 shop.db "INSERT INTO orders (id, user_id, total) VALUES (4, 2, 750);"   # one-shot: run and exit
sqlite3 shop.db "SELECT count(*) FROM orders WHERE total > 300;" > answer.txt  # stdout -> file
cat answer.txt                  # 3
```

Why one-shot? It is scriptable: you can redirect the output, pipe it, or put it in a check.
`-header -column` are the flag versions of `.headers on` / `.mode column`:
`sqlite3 -header -column shop.db "SELECT * FROM orders;"`.

**Common wrong attempts**
- `sqlite3 shop.db SELECT * FROM orders;` without quotes: the shell expands `*` into file names and `;` ends the shell command. Always quote the SQL.
- `sqlite3 shop.db` then `.tables;` - dot-commands take no `;` (it is read as part of the argument).
- Typing a SQL line without `;` - sqlite shows `...>` and waits. Type `;` + Enter.
- `sqlite3 shopdb` (typo) - sqlite **creates a new empty file**; `.tables` shows nothing. Check the file name.
- `echo 3 > answer.txt` passes only by luck; the point is that the database computes it.
