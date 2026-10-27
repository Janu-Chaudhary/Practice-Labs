# 05-testing / 10 - Two bugs, two test+fix pairs  (Twist)

## Situation
`shop.py` has two rules and both are wrong at the edge:
- `shipping_cost(total)`: orders of **50 or more** ship free. But `shipping_cost(50)` returns 5.
- `is_valid_postcode(code)`: exactly **4 digits**. But `is_valid_postcode("3000")` returns False.

The team rule: every bug fix is a failing-test commit followed by a fix commit. One pair per bug.

## Task
Make exactly **four** commits on `main`, in this order:
1. failing test for the shipping bug (message contains `failing test`) - test file only
2. fix the shipping bug - shop.py only (leave the postcode bug alone for now!)
3. failing test for the postcode bug (message contains `failing test`) - test file only
4. fix the postcode bug - shop.py only

Run `pytest` before each commit: red, green, red, green.

## Stop
- Do the bugs one at a time. Fixing both first and splitting later is possible (`git add -p`) but harder.
- No extra commits. Don't push.

## What will be checked
- 5 commits; each of the 4 commits changes only the right file
- pytest at each commit: fail, pass, fail, pass
- after commit 2 only shipping is fixed; after commit 4 both are
