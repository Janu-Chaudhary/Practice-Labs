// TiffinGo shop: one server for every release. RELEASE is baked into the image (docker build --build-arg).
//   2.3  single orders only
//   2.4  adds group orders (bug: crashes for a customer with no saved group)
//   2.5  the same group-order code, behind the flag "group_order" in /flags/flags.json
const http = require("node:http");
const fs = require("node:fs");
const crypto = require("node:crypto");

const RELEASE = process.env.RELEASE || "dev";
const STORE = process.env.STORE || "main";
const MENU = { "paneer thali": 180, "lassi": 60 };
const GROUPS = { asha: ["asha", "ravi", "meena"] };   // only the developer's own account has a saved group
let nextId = 1;

// Flags live OUTSIDE the image, in /flags/flags.json. Read on EVERY request: no restart needed.
function readFlags() { return JSON.parse(fs.readFileSync("/flags/flags.json", "utf8")); }
function bucket(flag, user) {
  return crypto.createHash("sha256").update(flag + ":" + user).digest().readUInt32BE(0) % 100;
}
function flagOn(flag, user) {
  const f = readFlags()[flag];
  return !!f && bucket(flag, user) < f.rollout_percent;
}

function groupFeature(user) {
  if (RELEASE === "2.3") return false;
  if (RELEASE === "2.4") return true;
  return flagOn("group_order", user);
}

function checkout(customer, group) {
  let items = ["paneer thali", "lassi"];
  const isGroup = group && groupFeature(customer);
  if (isGroup) {
    const members = GROUPS[customer];
    items = members.map(() => "paneer thali");   // TypeError if the customer has no saved group
  }
  const total = items.reduce((s, i) => s + (MENU[i] || 0), 0);
  return `ok     order #${nextId++}  Rs ${total}  ${isGroup ? "group" : "single"}  (v${RELEASE})`;
}

http.createServer((req, res) => {
  const url = new URL(req.url, "http://x");
  const send = (code, text) => { res.statusCode = code; res.end(text + "\n"); };
  try {
    if (url.pathname === "/healthz")
      return send(200, JSON.stringify({ status: "ok", version: RELEASE, store: STORE }));
    if (url.pathname === "/checkout") {
      const customer = url.searchParams.get("customer") || "asha";
      const out = checkout(customer, url.searchParams.get("group") === "1");
      console.log(`${customer}: ${out}`);
      return send(200, out);
    }
    if (url.pathname === "/flag") {            // e.g. /flag?name=new_menu&user=meena
      const name = url.searchParams.get("name"), user = url.searchParams.get("user");
      const f = readFlags()[name];
      const p = f ? f.rollout_percent : 0, b = bucket(name, user);
      return send(200, `${name} for ${user}: bucket ${b}, rollout_percent ${p} -> ${b < p ? "ON" : "off"}`);
    }
    send(404, "not found");
  } catch (e) {
    console.error(`ERROR  ${e.message}  (v${RELEASE})  request: ${req.url}`);
    send(500, `ERROR  ${e.message}  (v${RELEASE})`);
  }
}).listen(3000, () => console.log(`TiffinGo v${RELEASE} (store ${STORE}) listening on 3000`));
