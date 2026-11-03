#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore

cat > pools.toml <<'EOF'
# RailBook database connections. Each pool keeps up to pool_size connections open.
# Every connection is a separate Postgres process; connection max_connections + 1 is refused:
#   FATAL: sorry, too many clients already

[database]
max_connections = 100   # Postgres default
spare = 10              # always keep free: admin psql, migrations, emergencies

[app]                   # API servers behind the load balancer, each with its own pool
servers_now = 6
servers_max = 8         # the autoscaler may go up to 8 servers during Tatkal
pool_size = 15
wait_timeout_ms = 0     # 0 = never wait: fail at once when the pool is empty

[reporting_worker]      # the hourly sales report job
instances = 1
pool_size = 10
EOF

cat > budget.py <<'EOF'
"""Load pools.toml and print the connection math.  Run: python3 budget.py"""
import tomllib


def load(path="pools.toml"):
    with open(path, "rb") as f:
        return tomllib.load(f)


if __name__ == "__main__":
    cfg = load()
    app, worker, db = cfg["app"], cfg["reporting_worker"], cfg["database"]
    limit = db["max_connections"] - db["spare"]
    w = worker["instances"] * worker["pool_size"]
    for label, servers in (("today", app["servers_now"]), ("autoscaled", app["servers_max"])):
        a = servers * app["pool_size"]
        total = a + w
        print("%-11s app %d x %d = %d  + worker %d = %d   budget %d - %d = %d   %s" % (
            label + ":", servers, app["pool_size"], a, w, total,
            db["max_connections"], db["spare"], limit, "OK" if total <= limit else "OVER"))
    for name in ("app", "reporting_worker"):
        print("%-17s wait_timeout_ms = %s" % (name, cfg[name].get("wait_timeout_ms", "(missing)")))
EOF

cat > test_pools.py <<'EOF'
from budget import load


def test_fits_in_budget():
    cfg = load()
    app = cfg["app"]["servers_now"] * cfg["app"]["pool_size"]
    worker = cfg["reporting_worker"]["instances"] * cfg["reporting_worker"]["pool_size"]
    limit = cfg["database"]["max_connections"] - cfg["database"]["spare"]
    assert app + worker <= limit
EOF
git add . && git commit -q -m "Add connection pool config"
git rev-parse HEAD > .git/lab-base
banner "09-load/04-quiz-pool-sizing"
