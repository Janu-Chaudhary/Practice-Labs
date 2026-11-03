// Percentage rollout with a feature flag, step by step.
// The flag lives in flags.json, outside the code. Change the file, behaviour changes.
//   node rollout.js explain asha ravi ...   how each user gets their bucket
//   node rollout.js spread                  10,000 users across the 100 buckets
//   node rollout.js random asha             why we hash instead of using random()
//   node rollout.js rollout                 who is ON now, compared with last time
//   node rollout.js overlap                 two flags at 10%: same users or different?
const crypto = require("crypto");
const fs = require("fs");

const tty = process.stdout.isTTY || process.env.FORCE_COLOR === "1";
const c = (code) => (s) => (tty ? `\x1b[${code}m${s}\x1b[0m` : String(s));
const green = c("32"), red = c("31"), yellow = c("1;33"), dim = c("2"), bold = c("1");

const userId = (i) => "user_" + i;                  // user_1, user_2, ...
const USERS = Array.from({ length: 10000 }, (_, i) => userId(i + 1));

function readFlag(name) {
  return JSON.parse(fs.readFileSync("flags.json", "utf8"))[name];
}

// BEGIN bucket
// Turn (flag name, user id) into a number from 0 to 99. Same input, same number, every time.
function bucket(flagName, userId) {
  const digest = crypto.createHash("sha256").update(flagName + ":" + userId).digest();
  const n = digest.readUInt32BE(0);   // first 4 bytes as a number: 0 to 4,294,967,295
  return n % 100;                     // remainder after dividing by 100: 0 to 99
}

function isOn(flagName, userId) {
  return bucket(flagName, userId) < readFlag(flagName).rollout_percent;
}
// END bucket

const cmd = process.argv[2];
const args = process.argv.slice(3);
const FLAG = "group_order";

if (cmd === "explain") {
  const p = readFlag(FLAG).rollout_percent;
  console.log(dim(`flags.json says ${FLAG}.rollout_percent = ${p}, so ON means bucket < ${p}\n`));
  console.log(dim("user      sha256(\"group_order:\" + user)   first 4 bytes as a number   % 100   ON?"));
  for (const u of args) {
    const d = crypto.createHash("sha256").update(FLAG + ":" + u).digest();
    const n = d.readUInt32BE(0);
    const b = n % 100;
    const on = b < p;
    console.log(`${u.padEnd(9)} ${d.toString("hex").slice(0, 8)}...${" ".repeat(20)}` +
      `${n.toLocaleString("en-US").padStart(15)}${" ".repeat(12)}${yellow(String(b).padStart(3))}   ` +
      (on ? green("ON  (" + b + " < " + p + ")") : red("off (" + b + " >= " + p + ")")));
  }
}

else if (cmd === "spread") {
  const p = readFlag(FLAG).rollout_percent;
  const total = Number(args[0] || 10000);
  const counts = new Array(100).fill(0);
  for (let i = 1; i <= total; i++) counts[bucket(FLAG, userId(i))]++;
  const avg = total / 100;
  console.log(dim(`${total.toLocaleString("en-US")} users, 100 buckets. Each number = how many users landed in that bucket.`));
  console.log(dim(`Green = buckets below ${p}: the users who get the feature.\n`));
  for (let row = 0; row < 10; row++) {
    const cells = [];
    for (let col = 0; col < 10; col++) {
      const b = row * 10 + col;
      const s = String(counts[b]).padStart(total >= 100000 ? 7 : 4);
      cells.push(b < p ? green(s) : s);
    }
    console.log(dim(`buckets ${String(row * 10).padStart(2, "0")}-${String(row * 10 + 9).padStart(2, "0")}:`) + cells.join(""));
  }
  const on = counts.slice(0, p).reduce((a, b) => a + b, 0);
  const pct = (x) => ((x / avg - 1) * 100).toFixed(0);
  console.log(`\nSmallest bucket: ${Math.min(...counts).toLocaleString("en-US")} users (${pct(Math.min(...counts))}% from average). ` +
    `Largest: ${Math.max(...counts).toLocaleString("en-US")} (+${pct(Math.max(...counts))}%). Average: ${avg.toLocaleString("en-US")}.`);
  console.log(bold(`Buckets 0 to ${p - 1}: ${on.toLocaleString("en-US")} users = ${(on / total * 100).toFixed(2)}% of ${total.toLocaleString("en-US")}.`));
}

else if (cmd === "random") {
  const u = args[0] || "asha";
  const line = (label, f) => {
    const r = Array.from({ length: 10 }, () => (f() ? green("ON ") : red("off")));
    console.log(`${label.padEnd(36)}${r.join(" ")}`);
  };
  console.log(dim(`${u} opens the app 10 times. Feature at 10%.\n`));
  line("Math.random() < 0.10:", () => Math.random() < 0.1);
  line(`bucket("${FLAG}", "${u}") < 10:`, () => bucket(FLAG, u) < 10);
  console.log(dim(`\nrandom(): the button appears and disappears. The hash: same answer every time.`));
}

else if (cmd === "rollout") {
  const p = readFlag(FLAG).rollout_percent;
  const on = USERS.filter((u) => isOn(FLAG, u));
  console.log(bold(`rollout_percent = ${p}: ${on.length.toLocaleString("en-US")} of 10,000 users ON (${(on.length / 100).toFixed(1)}%)`));
  let prev = null;
  try { prev = JSON.parse(fs.readFileSync(".state.json", "utf8")); } catch {}
  if (prev) {
    const now = new Set(on);
    const before = new Set(prev.on);
    const stayed = prev.on.filter((u) => now.has(u)).length;
    const dropped = prev.on.length - stayed;
    const added = on.filter((u) => !before.has(u)).length;
    console.log(`Compared with ${prev.percent}%:`);
    console.log(green(`  stayed ON:   ${stayed.toLocaleString("en-US")}`));
    console.log(green(`  newly ON:    ${added.toLocaleString("en-US")}`));
    console.log((dropped ? red : dim)(`  turned off:  ${dropped.toLocaleString("en-US")}`));
  }
  fs.writeFileSync(".state.json", JSON.stringify({ percent: p, on }));
}

else if (cmd === "overlap") {
  const at10 = (name) => new Set(USERS.filter((u) => bucket(name, u) < 10));
  const plain = (u) => crypto.createHash("sha256").update(u).digest().readUInt32BE(0) % 100;
  const both = (a, b) => [...a].filter((u) => b.has(u)).length;

  const g = at10("group_order"), m = at10("new_menu");
  console.log(dim("Two flags, both at 10%. How many users are in BOTH test groups?\n"));
  console.log(`hash(flag name + user id):  group_order ${g.size}, new_menu ${m.size}, in both: ` +
    green(both(g, m)));
  const same = new Set(USERS.filter((u) => plain(u) < 10));
  console.log(`hash(user id) only:         group_order ${same.size}, new_menu ${same.size}, in both: ` +
    red(same.size));
  console.log(dim("\nWithout the flag name, the same 1,000 people test every new feature."));
}

else {
  console.log("usage: node rollout.js explain|spread|random|rollout|overlap");
}
