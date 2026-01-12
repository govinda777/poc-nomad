package queue

import (
	"context"
	"encoding/json"
	"fmt"
	"poc-nomad/db"

	"github.com/redis/go-redis/v9"
)

var ctx = context.Background()

func Publish(host string, order db.Order) error {
	rdb := redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:6379", host),
	})

	data, _ := json.Marshal(order)
	return rdb.Publish(ctx, "orders", data).Err()
}
