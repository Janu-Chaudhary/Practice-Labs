-- v2.5: a table for feature flags. group_order starts switched OFF.
ALTER TABLE orders ADD COLUMN IF NOT EXISTS group_id int;
CREATE TABLE IF NOT EXISTS flags (name text PRIMARY KEY, enabled boolean NOT NULL);
INSERT INTO flags VALUES ('group_order', false) ON CONFLICT DO NOTHING;
