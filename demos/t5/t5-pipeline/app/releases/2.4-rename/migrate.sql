-- The slide 6 version of v2.4: RENAME a column that v2.3 still uses.
ALTER TABLE orders ADD COLUMN IF NOT EXISTS group_id int;
ALTER TABLE orders RENAME COLUMN items TO order_items;
