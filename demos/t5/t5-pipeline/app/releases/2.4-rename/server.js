// TiffinGo v2.4, the other version from the poll: same code, but the column is now order_items.
const start = require("../../common/base");
const { total } = require("../../common/pricing");

// Saved groups. The developer tested with their own account, which has one.
const GROUPS = { asha: ["asha", "ravi", "meena"] };

start("2.4-rename", async (db, { customer, group }) => {
  let items = ["paneer thali", "lassi"];
  let groupId = null;
  if (group) {
    const members = GROUPS[customer];
    items = members.map(() => "paneer thali");  // crashes if the customer has no saved group
    groupId = 1;
  }
  const { rows } = await db.query(
    "INSERT INTO orders (customer, order_items, total, group_id) VALUES ($1, $2, $3, $4) RETURNING id",
    [customer, items.join(", "), total(items), groupId]);
  return { id: rows[0].id, total: total(items), kind: group ? "group" : "single" };
});
