# Solution - 10 search a whole repository

```bash
mkdir reports
#   > never creates folders
grep -rn 'issue_refund' shop | sort > reports/refund-calls.txt
#   -r: every file in shop and below (hidden files too). -n: add the line number -> shop/app.py:8:...
#   sort: grep -r's file order isn't guaranteed, so sort makes the result predictable
grep -r 'def issue_refund' shop | wc -l > reports/refund-defined.txt
#   grep prints nothing (it is never defined), wc -l counts 0 lines -> 0
grep -rlE 'API_KEY=.+' shop | sort > reports/secret-files.txt
#   -l: file names only. -E 'API_KEY=.+': "API_KEY=" then one or more characters
#   -> shop/.env and shop/payments/client.py ; .env.example (nothing after =) and settings.py (space before =) don't match
grep -r --include='*.py' 'TODO' shop | wc -l > reports/todo-count.txt
#   --include='*.py': only look inside .py files (quote the *). 4 lines across 4 files
cat reports/*.txt
#   look at everything before you finish
```

Expected `reports/refund-calls.txt`:
```
shop/app.py:2:from payments.client import charge, issue_refund
shop/app.py:8:    return issue_refund(order_id)
shop/payments/refunds.py:4:    # was called issue_refund in the old design doc
shop/README.md:3:TODO: document issue_refund
shop/tests/test_refund.py:2:def test_refund_calls_issue_refund():
```
(The exact order is whatever `sort` gives on your machine: with an English locale it ignores upper/lower case,
so `README.md` lands between `payments` and `tests`. The checker sorts the same way, so just use `sort`.)

Other ways that also pass:
- Step 2: `grep -rc 'def issue_refund' shop` shows the per-file counts so you can *see* they are all 0, but don't save that.
- Step 3: `grep -rl 'API_KEY=.' shop | sort` (basic grep: `.` = one character is enough).
- Step 4: `cat $(find shop -name '*.py') | grep -c TODO > reports/todo-count.txt`
  (`$( )` puts find's list of files onto cat's command line; grep -c on ONE stream = one number).

## Common wrong attempts
- `grep -rn issue_refund . > reports/refund-calls.txt` -> paths start with `./shop/...`, and if `reports/` already
  exists grep may even search the report it is writing. Search `shop`, by name.
- `grep -n issue_refund shop` (no `-r`) -> `grep: shop: Is a directory`.
- `grep -rc 'def issue_refund' shop > reports/refund-defined.txt` -> 8 lines like `shop/app.py:0`, not one number.
- `grep -rl API_KEY shop` -> also lists `.env.example` (empty template) and `config/settings.py` (reads the env var): 4 files instead of 2.
- `grep -rlE API_KEY=.+ shop` without quotes usually works, but quote patterns anyway: `*`, `|`, `?` and spaces get eaten by the shell.
- `grep -r TODO shop | wc -l` -> 6: README.md's two TODO lines got counted.
- `grep -r --include=*.py ...` unquoted works only while no `.py` file sits in the current folder (the shell would expand it first).
