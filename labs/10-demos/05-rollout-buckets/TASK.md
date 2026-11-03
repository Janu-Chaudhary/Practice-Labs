# Demos 05 - Percentage rollout with sticky buckets (slide 19, t5-rollout)

**Start state (Reset lab did this):** `work/` has the professor's `rollout.js`, `flags.json`
(`rollout_percent: 10`) and `answers.txt` for you to fill. No server, no database.

**What the professor shows:** how "10% of users" works. Each user gets a fixed bucket:
`sha256("group_order:" + user)`, first 4 bytes as a number, `% 100` -> 0..99. The user is ON if
`bucket < rollout_percent` (read from `flags.json` on every call).

**Slide ideas:**
- Use `hash(user) % 100 < 10`, not `random() < 0.1`: deterministic means **sticky** (the button
  doesn't appear and disappear).
- Raising the percent only **adds** users (turned off = 0). Setting 0 is the kill switch.
- The flag name is inside the hash so each flag gets an **independent** 10% (overlap ~1%).
- It is *about* 10%, never exactly; more users, less wobble.

## Run node inside Docker (no Node on the host)
```
docker run --rm -v "$PWD":/demo -w /demo node:22-alpine node rollout.js explain asha
```
`-v "$PWD":/demo` mounts this folder, `-w /demo` starts there, `--rm` deletes the container after.
To type less, make an alias once in this terminal:
```
alias node='docker run --rm -v "$PWD":/demo -w /demo node:22-alpine node'
```

## Do this, in order (fill `answers.txt` in the Files panel as you go)
1. Open `flags.json` and `rollout.js` (find `BEGIN bucket` ... `END bucket`).
2. `node rollout.js explain asha ravi meena kabir zoya` -> answer 1.
3. `node rollout.js spread` and `node rollout.js spread 1000000` - single buckets wobble.
4. `node rollout.js random asha` - random() flips, the hash does not.
5. `node rollout.js rollout` -> answer 2 (it also saves who is ON into `.state.json`).
6. In the Files panel change `flags.json` to `"rollout_percent": 50`, Save, then
   `node rollout.js rollout` again -> answer 3 ("turned off").
7. `node rollout.js overlap` -> answer 4.
8. Set `flags.json` to `"rollout_percent": 25`, Save, run `explain` for the five users -> answer 5.
   Leave `flags.json` at 25 and save `answers.txt`.

## What will be checked
- the five answers in `answers.txt` (user lists in any order; `1,005` or `1005` both fine)
- `flags.json` is valid JSON with `group_order.rollout_percent` = 25
