// The unit tests the pipeline runs before building. They all pass, for every release.
const test = require("node:test");
const assert = require("node:assert");
const { total } = require("./pricing");

test("one thali", () => assert.strictEqual(total(["paneer thali"]), 180));
test("thali and lassi", () => assert.strictEqual(total(["paneer thali", "lassi"]), 240));
test("empty cart", () => assert.strictEqual(total([]), 0));
