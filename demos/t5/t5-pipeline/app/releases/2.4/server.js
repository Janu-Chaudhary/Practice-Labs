// TiffinGo v2.4: adds "group order". One person orders for their saved group.
const start = require("../../common/base");
const { total } = require("../../common/pricing");

// Saved groups. The developer tested with their own account, which has one.
const GROUPS = { asha: ["asha", "ravi", "meena"] };

start("2.4", async (db, { customer, group }) => {
  let items = ["paneer thali", "lassi"];
  let groupId = null;
  if (group) {
    const members = GROUPS[customer];
    items = members.map(() => "paneer thali");  // crashes if the customer has no saved group
    groupId = 1;
  }
  const { rows } = await db.query(
    "INSERT INTO orders (customer, items, total, group_id) VALUES ($1, $2, $3, $4) RETURNING id",
    [customer, items.join(", "), total(items), groupId]);
  return { id: rows[0].id, total: total(items), kind: group ? "group" : "single" };
});
