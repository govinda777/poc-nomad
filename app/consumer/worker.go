package consumer

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"poc-nomad/app/config"
	"poc-nomad/app/db"
	"poc-nomad/app/db/models"

	"github.com/redis/go-redis/v9"
)

var ctx = context.Background()

func Start(cfg *config.Config) {
	rdb := redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:6379", cfg.RedisHost),
	})

	sub := rdb.Subscribe(ctx, "orders")
	ch := sub.Channel()

	log.Printf("Consumer started in %s, listening on Redis %s...", cfg.Datacenter, cfg.RedisHost)

	for msg := range ch {
		var order models.Order
		if err := json.Unmarshal([]byte(msg.Payload), &order); err != nil {
			log.Printf("Error decoding message: %v", err)
			continue
		}

		log.Printf("[%s] Received Order ID %d from %s", cfg.Datacenter, order.ID, order.Datacenter)

		// Idempotency / Processing logic
		// Update status to 'processed_by_consumer'
		_, err := db.DB.Exec("UPDATE orders SET status = $1 WHERE id = $2",
			"processed_by_"+cfg.Datacenter, order.ID)

		if err != nil {
			log.Printf("Error processing order %d: %v", order.ID, err)
		}
	}
}
