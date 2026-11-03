// Shared by every TiffinGo release: the HTTP server, /healthz, and error handling.
// Each release only supplies its own checkout() function.
const http = require("http");
const { Pool } = require("pg");

const pool = new Pool({ connectionString: process.env.DATABASE_URL, max: 5 });

module.exports = function start(version, checkout) {
  http.createServer(async (req, res) => {
    const url = new URL(req.url, "http://x");
    const send = (code, text) => { res.statusCode = code; res.end(text + "\n"); };
    try {
      if (url.pathname === "/healthz") {
        await pool.query("SELECT 1");                     // can we reach the database?
        return send(200, JSON.stringify({ status: "ok", version }));
      }
      if (url.pathname === "/checkout") {
        const order = await checkout(pool, {
          customer: url.searchParams.get("customer") || "asha",
          group: url.searchParams.get("group") === "1",
        });
        return send(200, `ok     order #${order.id}  Rs ${order.total}  ${order.kind}  (v${version})`);
      }
      send(404, "not found");
    } catch (e) {
      console.error(e);
      send(500, `ERROR  ${e.message}  (v${version})`);
    }
  }).listen(Number(process.env.PORT || 3000), () => console.log(`TiffinGo v${version} listening`));
};
