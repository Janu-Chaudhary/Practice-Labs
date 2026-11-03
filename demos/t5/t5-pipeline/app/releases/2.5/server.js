// TiffinGo v2.5: the same group-order code as v2.4, now behind a flag.
const start = require("../../common/base");
const { total } = require("../../common/pricing");

// Saved groups. The developer tested with their own account, which has one.
const GROUPS = { asha: ["asha", "ravi", "meena"] };

// The flag's value lives in the database, not in the code. Read on every request.
async function flagOn(db, name) {
  const { rows } = await db.query("SELECT enabled FROM flags WHERE name = $1", [name]);
  return rows.length > 0 && rows[0].enabled;
}

start("2.5", async (db, { customer, group }) => {
  let items = ["paneer thali", "lassi"];
  let groupId = null;
  const groupOrder = group && await flagOn(db, "group_order");
  if (groupOrder) {
    const members = GROUPS[customer];
    items = members.map(() => "paneer thali");  // crashes if the customer has no saved group
    groupId = 1;
  }
  const { rows } = await db.query(
    "INSERT INTO orders (customer, items, total, group_id) VALUES ($1, $2, $3, $4) RETURNING id",
    [customer, items.join(", "), total(items), groupId]);
  return { id: rows[0].id, total: total(items), kind: groupOrder ? "group" : "single" };
});
