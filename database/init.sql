CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY,
    item TEXT NOT NULL,
    qty INT NOT NULL,
    status TEXT NOT NULL,
    version INT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE,
    origin_dc TEXT
);

-- Index for LWW resolution if we were querying by time, though PK lookups are fast
CREATE INDEX IF NOT EXISTS idx_orders_timestamp ON orders(timestamp);
