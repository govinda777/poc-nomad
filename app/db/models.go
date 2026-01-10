package db

import (
	"database/sql"
	"time"
)

var ErrNotFound = sql.ErrNoRows

type Order struct {
	ID        int       `json:"id"`
	Item      string    `json:"item"`
	Qty       int       `json:"qty"`
	Status    string    `json:"status"`
	Version   int       `json:"version"`
	Timestamp time.Time `json:"timestamp"`
	Datacenter string   `json:"datacenter"`
}

type DBClient struct {
	Conn *sql.DB
}

func NewDBClient(dsn string) (*DBClient, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, err
	}
	// Basic check
	if err := db.Ping(); err != nil {
		return nil, err
	}
	return &DBClient{Conn: db}, nil
}
