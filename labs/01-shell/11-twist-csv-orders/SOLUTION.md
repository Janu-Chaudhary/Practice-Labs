# Solution - 11 orders CSV report

```bash
mkdir reports
tail -n +2 data/orders.csv | cut -d, -f2 | sort -u > reports/customers.txt
#   tail -n +2: drop the header line. cut -d, -f2: customer column. sort -u: A-Z, each name once
grep ',refunded,' data/orders.csv | cut -d, -f1 > reports/refunded-ids.txt
#   the commas make sure we match the status FIELD. cut -f1 keeps only the id -> 1003, 1008
awk -F, '$3 == "paid" { sum += $4 } END { print sum }' data/orders.csv > reports/paid-total.txt
#   -F, split on commas. $3 == "paid" is an exact field match (unpaid is NOT equal). sum the 4th field -> 615
tail -n +2 data/orders.csv | cut -d, -f2 | sort | uniq -c | sort -rn | head -n 2 > reports/top2.txt
#   one name per order -> sort (uniq needs neighbours) -> uniq -c counts -> sort -rn biggest first -> top 2
cat reports/*.txt
```

Build each pipe one stage at a time (up-arrow, add `| next`, Enter) and look at the output each time.

Other ways that also pass:
- Step 3 without awk: `grep ',paid,' data/orders.csv | cut -d, -f4 | paste -sd+ | bc`
  (`paste -sd+` joins the numbers as `250+40+300+15+10`, `bc` calculates it).
- Step 3 with grep + awk: `grep ',paid,' data/orders.csv | awk -F, '{ s += $4 } END { print s }'`.
- Step 4 without tail: `cut -d, -f2 data/orders.csv | sort | uniq -c | sort -rn | head -n 2` also works here,
  because `customer` appears only once and so never makes the top 2. Skipping the header is still the habit to have.
- Step 1: `cut -d, -f2 data/orders.csv | grep -v '^customer$' | sort -u` is fine too.

Expected `reports/top2.txt`:
```
      4 asha
      3 ben
```

## Common wrong attempts
- `cut -d, -f2 data/orders.csv | sort -u` -> `customer` (the header) is in the list.
- `cut -f2 data/orders.csv` -> no `-d,`: cut looks for TABs, finds none, prints whole lines.
- `grep paid data/orders.csv | ...` -> also matches `unpaid`, total becomes 894 instead of 615.
- `grep refunded data/orders.csv > reports/refunded-ids.txt` -> whole lines, not just the ids.
- `... | uniq -c | sort -rn` **without** the first `sort` -> uniq only merges neighbours; `asha` would show up in several pieces.
- `sort -r` instead of `sort -rn` -> text order: `10` sorts before `9`. Use `-n` for numbers.
