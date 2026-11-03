# Solution - Demos 01

```bash
# (once, only if Reset lab said images are missing)  ../../../../demos/t5/preflight.sh
./setup.sh                          # network tiffingo + t5-db + t5-proxy on :8080
./deploy.sh 2.3                     # Test, Build (2 tags), Migrate, Deploy, Health, Switch (~10-20 s)
./traffic.sh > traffic.log 2>&1 &   # fake customers in the background, output into a file
curl -s http://localhost:8080/healthz            # {"status":"ok","version":"2.3"}
docker images tiffingo              # tiffingo:2.3 and tiffingo:cdf64da: same IMAGE ID
docker ps                           # t5-db, t5-proxy, tiffingo-2-3-<time>
cd .. && ./check.sh
```

## Common wrong attempts
- `./deploy.sh 2.3` before `./setup.sh` -> fails at Migrate: there is no `t5-db` yet.
- `./setup.sh` twice -> "Already set up. Run ./reset.sh first". Use Reset lab for a clean start.
- `./traffic.sh` without `&` -> it never ends and you lose the prompt. Ctrl-C, then rerun with
  `> traffic.log 2>&1 &`.
- Forgetting `> traffic.log` -> the lines print over your terminal and nothing goes into the file.
