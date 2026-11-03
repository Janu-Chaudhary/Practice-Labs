# Solution - Demos 05

```bash
alias node='docker run --rm -v "$PWD":/demo -w /demo node:22-alpine node'
node rollout.js explain asha ravi meena kabir zoya   # buckets 67 14 5 36 30 -> only meena ON
node rollout.js spread                               # Buckets 0 to 9: 1,005 users = 10.05%
node rollout.js random asha
node rollout.js rollout                              # rollout_percent = 10: 1,005 of 10,000 ON
# Files panel: flags.json -> "rollout_percent": 50, Save
node rollout.js rollout                              # stayed 1,005  newly 3,952  turned off 0
node rollout.js overlap                              # in both: 99
# Files panel: flags.json -> "rollout_percent": 25, Save
node rollout.js explain asha ravi meena kabir zoya   # ravi (14) and meena (5) ON
```
`flags.json` at the end:
```
{
  "group_order": { "rollout_percent": 25 }
}
```
`answers.txt`:
```
on_at_10=meena
count_at_10=1005
turned_off=0
overlap=99
on_at_25=meena,ravi
```

## Common wrong attempts
- `node rollout.js ...` without Docker or the alias -> `node: command not found`.
- Editing flags.json with a missing comma/brace -> rollout.js crashes with a JSON error; the
  check also needs valid JSON.
- Running `rollout` at 50 without running it at 10 first -> no "Compared with" lines
  (`.state.json` stores the previous run).
- Answering 10% ON = 1000: it is about 10%, here exactly 1,005.
