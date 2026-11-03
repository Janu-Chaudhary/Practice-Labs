-- v2.4: ADD a column. v2.3 ignores it, so going back to v2.3 still works.
ALTER TABLE orders ADD COLUMN IF NOT EXISTS group_id int;
