-- v2.3: the orders table.
CREATE TABLE IF NOT EXISTS orders (
  id         serial PRIMARY KEY,
  customer   text NOT NULL,
  items      text NOT NULL,
  total      int  NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
