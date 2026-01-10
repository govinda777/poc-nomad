package queue

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/redis/go-redis/v9"
	"poc-app/db"
)

type RedisClient struct {
	Client *redis.Client
}

func NewRedisClient(host string) *RedisClient {
	rdb := redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:6379", host),
	})
	return &RedisClient{Client: rdb}
}

func (r *RedisClient) PublishOrder(ctx context.Context, order *db.Order) error {
	data, err := json.Marshal(order)
	if err != nil {
		return err
	}
	return r.Client.Publish(ctx, "orders", data).Err()
}
