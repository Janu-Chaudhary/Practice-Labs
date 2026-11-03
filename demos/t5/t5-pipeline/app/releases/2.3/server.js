// TiffinGo v2.3: single orders only.
const start = require("../../common/base");
const { total } = require("../../common/pricing");

start("2.3", async (db, { customer }) => {
  const items = ["paneer thali", "lassi"];
  const { rows } = await db.query(
    "INSERT INTO orders (customer, items, total) VALUES ($1, $2, $3) RETURNING id",
    [customer, items.join(", "), total(items)]);
  return { id: rows[0].id, total: total(items), kind: "single" };
});
