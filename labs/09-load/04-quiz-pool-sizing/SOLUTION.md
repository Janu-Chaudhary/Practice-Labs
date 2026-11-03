# Solution - 04-quiz-pool-sizing

The math (worst case = every server the autoscaler may start):
```
servers_max x pool + worker  <=  max_connections - spare
     8      x  p   +   5     <=        100       -  10   = 90
              8p              <=  85   ->  p <= 10.6  ->  p = 10    (8 x 10 + 5 = 85 <= 90)
```
In the Files panel open `test_pools.py` and make it read:
```python
from budget import load


def test_fits_in_budget():
    cfg = load()
    app = cfg["app"]["servers_max"] * cfg["app"]["pool_size"]
    worker = cfg["reporting_worker"]["instances"] * cfg["reporting_worker"]["pool_size"]
    limit = cfg["database"]["max_connections"] - cfg["database"]["spare"]
    assert app + worker <= limit


def test_every_pool_has_wait_timeout():
    cfg = load()
    for name in ("app", "reporting_worker"):
        assert cfg[name].get("wait_timeout_ms", 0) > 0, name
```
Save, then `pytest` -> 2 failed (130 > 90; app timeout is 0).

Open `pools.toml` and change the three sections to:
```toml
[app]                   # API servers behind the load balancer, each with its own pool
servers_now = 6
servers_max = 8         # the autoscaler may go up to 8 servers during Tatkal
pool_size = 10
wait_timeout_ms = 2000

[reporting_worker]      # the hourly sales report job
instances = 1
pool_size = 5
wait_timeout_ms = 2000
```
(leave the comments at the top and the `[database]` section as they are). Save. Then:
```bash
python3 budget.py     # today: 6 x 10 = 60 + 5 = 65 OK ; autoscaled: 8 x 10 = 80 + 5 = 85 OK
pytest                # 2 passed
git add pools.toml test_pools.py
git commit -m "Size DB pools for 8 servers and add a 2s pool wait timeout"
cd .. && ./check.sh
```

Why:
- Every app server brings its **own** pool, so the total is servers x pool size. Size for the most
  servers that can ever run (`servers_max`), or the autoscaler pushes you over the limit right at the
  Tatkal peak. Count every client: the worker's pool too.
- The spare (10) keeps room for you to log in with psql and fix things during an incident.
- `wait_timeout_ms`: with 0, a request fails the moment the pool is empty. With 2000 it queues for
  up to 2 s, so a short spike slows down instead of erroring; bounded, so nothing hangs forever.
- `.get("wait_timeout_ms", 0)`: a missing key counts as 0 and fails the assert. `cfg[name]["wait_timeout_ms"]`
  would also fail (KeyError), but with a less clear message.

Common wrong attempts:
- `pool_size = 14` (6 x 14 + 5 = 89 fits today) -> 8 x 14 + 5 = 117 when autoscaled: refused connections.
- `pool_size = 11` (8 x 11 + 5 = 93): forgot the spare (fits 100, not 90).
- `pool_size = 9`: fits, but the task asked for the largest that fits.
- Lowering `servers_max` or `spare` to make the numbers work: not allowed; that hides the problem.
- Timeout only on the app: the worker's pool can run dry too; the test must cover every pool.
- If it still doesn't fit (e.g. 200 serverless functions x 5), the answer is a pooler (PgBouncer /
  Supavisor) in front of Postgres, not a bigger max_connections.
