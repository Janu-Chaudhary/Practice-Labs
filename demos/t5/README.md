# T5 demos: Safe Delivery

The folder contains 2 demos - `t5-pipeline` and `t5-rollout`.


## Once, after unzipping

1. Install Docker if not installed
2. Run:

```
cd <path_to_t5-demos>
chmod +x *.sh */*.sh
./preflight.sh smoke
```

If you're using Mac:
```
cd <path_to_t5-demos>
xattr -dr com.apple.quarantine . 2>/dev/null
chmod +x *.sh */*.sh
./preflight.sh smoke
```

## Demo 1 · t5-pipeline (slides 14, 15, 18)

Terminal 1:

```
cd <path_to_t5-demos>/t5-pipeline
./demo.sh
```

Terminal 2:

```
cd <path_to_t5-demos>/t5-pipeline
./traffic.sh
```


## Demo 2 · t5-rollout (slide 19)

```
cd <path_to_t5-demos>/t5-rollout
./demo.sh
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `Docker is not running` | Open Docker Desktop and wait |
| Port 8080 in use | `./reset-all.sh`. Otherwise `lsof -nP -iTCP:8080 -sTCP:LISTEN` shows the program |
| A deploy stops at the build step | No internet and no cache. Run `./preflight.sh` on Wi-Fi first |
| The script stopped halfway | `./demo.sh N` resumes at step N |
| Anything else | `./reset-all.sh`, then start the demo again (about a minute) |
