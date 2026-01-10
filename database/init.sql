CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    item VARCHAR(255) NOT NULL,
    qty INT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    datacenter VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Basic Last-Write-Wins trigger could be added here or handled by app logic.
-- For simple active-active with conflict resolution on ID, we might need UUIDs instead of SERIAL.
-- But for this POC, we accept ID collisions as part of the problem to demonstrate!
