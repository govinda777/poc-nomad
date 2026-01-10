package models

import "time"

type Order struct {
	ID        int       `json:"id"`
	Item      string    `json:"item"`
	Qty       int       `json:"qty"`
	Status    string    `json:"status"`
	Datacenter string   `json:"datacenter"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
