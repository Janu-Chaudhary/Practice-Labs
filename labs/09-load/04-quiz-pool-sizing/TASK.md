# 09-load / 04 - Size the pools before Tatkal  (Quiz-style)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add connection pool config
$ python3 budget.py
today:      app 6 x 15 = 90  + worker 10 = 100   budget 100 - 10 = 90   OVER
autoscaled: app 8 x 15 = 120  + worker 10 = 130   budget 100 - 10 = 90   OVER
app               wait_timeout_ms = 0
reporting_worker  wait_timeout_ms = (missing)
```

## Situation
Last Tatkal, requests failed with `FATAL: sorry, too many clients already`. Each app server has its
own pool, so connections **multiply** when the autoscaler adds servers. Postgres allows 100, and the
team keeps 10 spare. `pools.toml` holds the settings; `budget.py` prints the math.
`test_pools.py` has one test, written before autoscaling existed: it counts only `servers_now`.

## Task
All in ONE new commit (message contains `pool`):
1. `test_pools.py`:
   - fix `test_fits_in_budget` so it counts the **worst case**: `servers_max`, not `servers_now`.
   - add a test `test_every_pool_has_wait_timeout` that fails unless **both** `app` and
     `reporting_worker` have a `wait_timeout_ms` greater than 0 (a missing key must fail too).
   Run `pytest`: both tests fail.
2. `pools.toml` (in the Files panel):
   - the reporting job only needs **5** connections: set its `pool_size = 5`.
   - set the app `pool_size` to the **largest** value that still fits the budget at `servers_max`.
   - give both pools `wait_timeout_ms = 2000` (wait up to 2 s for a free connection, then fail).
   Run `python3 budget.py` (both lines OK) and `pytest` (2 passed).
3. Commit `pools.toml` and `test_pools.py`.

## Stop
- Don't change `max_connections`, `spare`, `servers_now`, `servers_max`, `instances`, or `budget.py`.
- Exactly one new commit.

## What will be checked
- 2 commits; the new one changes exactly `pools.toml` + `test_pools.py`; message contains `pool`
- app pool_size is the largest that fits the worst case; worker 5; both timeouts 2000; other values unchanged
- pytest passes at HEAD with at least 2 tests
- your tests FAIL on bad configs: a pool size that only fits `servers_now`, a missing worker timeout,
  an app timeout of 0
