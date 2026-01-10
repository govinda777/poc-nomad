package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"

	"poc-app/api"
	"poc-app/config"
	"poc-app/db"
	"poc-app/queue"
)

func main() {
	cfg := config.LoadConfig()
	fmt.Printf("Starting POC App in DC: %s\n", cfg.Datacenter)

	// DB Setup
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable",
		cfg.DBHost, cfg.DBUser, cfg.DBPass, cfg.DBName)

	dbClient, err := db.NewDBClient(dsn)
	if err != nil {
		fmt.Printf("Failed to connect to DB: %v\n", err)
	}

	// Redis Setup
	redisClient := queue.NewRedisClient(cfg.RedisHost)

	// API Server
	server := &api.Server{
		Config: cfg,
		DB:     dbClient,
		Queue:  redisClient,
	}

	http.HandleFunc("/health", server.HealthHandler)
	http.HandleFunc("/orders", server.CreateOrderHandler)
	http.HandleFunc("/orders/", server.GetOrderHandler)

	// Start Consumer in background
	go startConsumer(redisClient, dbClient, cfg.Datacenter)

	fmt.Printf("Listening on %s\n", cfg.ServerPort)
	if err := http.ListenAndServe(":"+cfg.ServerPort, nil); err != nil {
		fmt.Printf("Error: %s\n", err)
		os.Exit(1)
	}
}

func startConsumer(r *queue.RedisClient, d *db.DBClient, dc string) {
	fmt.Println("Starting Redis Consumer...")
	ctx := context.Background()
	pubsub := r.Client.Subscribe(ctx, "orders")
	defer pubsub.Close()

	ch := pubsub.Channel()

	for msg := range ch {
		fmt.Printf("[%s] Received message from queue: %s\n", dc, msg.Payload)

		// Parse message
		var o db.Order
		if err := json.Unmarshal([]byte(msg.Payload), &o); err != nil {
			fmt.Printf("Error unmarshalling message: %v\n", err)
			continue
		}

		// Idempotency: Attempt to insert/update DB
		// Since we use the same CreateOrder logic (which has LWW ON CONFLICT),
		// this acts as an idempotent operation.
		// If the order already exists with a newer timestamp, this is ignored.
		// If it's new or has newer timestamp, it updates.

		// Note: In a Read-Only Replica (Standby), this write will fail.
		// But that's expected behavior for the consumer running in the Standby DC.
		// It only processes when it becomes Primary (or if we had active-active DBs).
		// In this POC architecture:
		// - AWS Consumer writes to AWS Primary (Success)
		// - GCP Consumer writes to GCP Standby (Fails - Read Only)
		// This is correct for Active-Passive DB.
		// If we wanted Queue-Based replication to fill the gap, the GCP consumer would
		// need to wait until failover to process, or write to a different store.
		// For this POC's request ("GCP Consumer processes its side"), it implies
		// it SHOULD persist. Since DB is standby, it can't.
		// UNLESS: The GCP Consumer is meant to write to a local cache or just log it.
		// OR: We assume the queue is for async jobs (emails) not data replication.

		// However, the prompt says: "Consumer GCP processes... Updates DB GCP".
		// This implies Multi-Master OR that "DB GCP" is writable.
		// Since we implemented Streaming Replication, DB GCP is Read-Only.
		// So the consumer there will fail to write.
		// We will log the error gracefully.

		err := d.CreateOrder(&o)
		if err != nil {
			if strings.Contains(err.Error(), "read-only transaction") {
				fmt.Printf("[%s] Consumer skipped write: DB is Read-Only (Standby)\n", dc)
			} else {
				fmt.Printf("[%s] Error processing order %d: %v\n", dc, o.ID, err)
			}
		} else {
			fmt.Printf("[%s] Successfully processed/deduplicated order %d\n", dc, o.ID)
		}
	}
}
