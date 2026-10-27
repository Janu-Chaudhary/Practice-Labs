# 11 - Orders CSV report (Twist)

## Situation
Not a log this time: `data/orders.csv` is a spreadsheet export. Fields are separated by **commas**, and
**line 1 is a header**, not an order:
```
order_id,customer,status,amount
1001,asha,paid,250
1002,ben,unpaid,120
^ f1     ^ f2  ^ f3   ^ f4
```
`status` is one of `paid`, `unpaid`, `refunded`. Look at the whole file first (`cat data/orders.csv`).
There is no `reports` folder yet.

## Task
1. `reports/customers.txt`: every customer name **once**, sorted A-Z. Names only (no header, no other fields).
2. `reports/refunded-ids.txt`: only the **order_id** of each `refunded` order, one per line, in file order.
3. `reports/paid-total.txt`: just the **sum** of `amount` over the orders whose status is exactly `paid`.
4. `reports/top2.txt`: the **2** customers with the **most orders** (any status), most first, each line
   `COUNT NAME`, e.g. `      7 zara` (leading spaces from `uniq -c` are fine).

## Stop
- Don't change `data/orders.csv`.
- Create the reports with commands and `>` (no editor, and don't type the numbers in yourself).

## Hints
- `cut -d, -f2` = split each line on `,` and keep field 2. Without `-d,` cut splits on TAB.
- `tail -n +2 FILE` prints from line 2 to the end, i.e. everything except the header.
- `sort -u` = sort and drop duplicates.
- Careful: the text `paid` is also inside `unpaid`. Include the commas in your pattern (`,paid,`), or compare the whole field.
- Adding up a column: `awk -F, '{ sum += $4 } END { print sum }' FILE` (`-F,` = fields split on commas,
  `$4` = field 4, `END` runs once after the last line). awk can also filter: `$3 == "paid" { ... }`.
- Counting: `sort | uniq -c` counts, `sort -rn` puts the biggest number first, `head -n 2` keeps two lines.

## What will be checked
- `reports/customers.txt` is exactly `asha ben chen dev`, one per line
- `reports/refunded-ids.txt` is exactly `1003` then `1008`
- `reports/paid-total.txt` holds just the right total (spaces/newline around it are fine)
- `reports/top2.txt` (ignoring extra spaces) is exactly the top 2 lines
- `data/orders.csv` is unchanged
