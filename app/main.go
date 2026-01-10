package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"poc-nomad/app/api"
	"poc-nomad/app/consumer"
	"poc-nomad/app/config"
	"poc-nomad/app/db"
)

func main() {
	cfg := config.Load()

	// Initialize DB
	if err := db.Init(cfg.DBHost, cfg.DBUser, cfg.DBPassword, cfg.DBName); err != nil {
		log.Fatalf("Failed to connect to DB: %v", err)
	}

	// Initialize Redis (optional for now in main, used in queue/consumer)
	// ...

	// Decide mode based on args or env, for simplicity we run API by default
	// or separate binaries. Ideally, the prompt implies "api-aws" runs the API.
	// We can also run the consumer in the same binary or separate.
	// The prompt structure suggests "api-aws" and "consumer" might be different or same app.
	// "api-aws" command: ./api -datacenter=aws ...

	// Let's check arguments to see if we are running as a consumer
	if len(os.Args) > 1 && os.Args[1] == "consumer" {
		log.Println("Starting Consumer...")
		consumer.Start(cfg)
		return
	}

	log.Println("Starting API Server...")
	r := gin.Default()

	api.RegisterRoutes(r, cfg)

	// API serves on 8080
	if err := r.Run(":8080"); err != nil {
		log.Fatal(err)
	}
}
