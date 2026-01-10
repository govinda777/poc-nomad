package db

import (
	_ "github.com/lib/pq"
)

// Postgres implementation of DB operations

func (c *DBClient) CreateOrder(order *Order) error {
	// LWW Conflict Resolution logic is often in the DB Trigger or Upsert query.
	// For this POC, we will use ON CONFLICT UPDATE if timestamp is newer.

	query := `
		INSERT INTO orders (id, item, qty, status, version, timestamp, origin_dc)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (id) DO UPDATE
		SET item = EXCLUDED.item,
		    qty = EXCLUDED.qty,
		    status = EXCLUDED.status,
		    version = EXCLUDED.version,
		    timestamp = EXCLUDED.timestamp,
		    origin_dc = EXCLUDED.origin_dc
		WHERE EXCLUDED.timestamp > orders.timestamp;
	`
	_, err := c.Conn.Exec(query, order.ID, order.Item, order.Qty, order.Status, order.Version, order.Timestamp, order.Datacenter)
	return err
}

func (c *DBClient) GetOrder(id int) (*Order, error) {
	row := c.Conn.QueryRow("SELECT id, item, qty, status, version, timestamp, origin_dc FROM orders WHERE id = $1", id)
	var o Order
	err := row.Scan(&o.ID, &o.Item, &o.Qty, &o.Status, &o.Version, &o.Timestamp, &o.Datacenter)
	if err != nil {
		return nil, err
	}
	return &o, nil
}
