package db

import (
	"database/sql"
	"fmt"
	"log"
	"time"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func Init(host, user, password, dbname string) error {
	connStr := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable", host, user, password, dbname)
	var err error

	// Retry logic for DB connection (wait for container)
	for i := 0; i < 30; i++ {
		DB, err = sql.Open("postgres", connStr)
		if err == nil {
			err = DB.Ping()
			if err == nil {
				log.Println("Connected to Database")
				return nil
			}
		}
		log.Printf("Waiting for DB (%s)... %v", host, err)
		time.Sleep(1 * time.Second)
	}
	return fmt.Errorf("could not connect to db: %v", err)
}
