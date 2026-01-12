package api

import (
	"net/http"
	"poc-nomad/config"
	"poc-nomad/db"
	"poc-nomad/queue"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine, cfg *config.Config) {
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "dc": cfg.Datacenter})
	})

	r.POST("/orders", func(c *gin.Context) {
		var order db.Order
		if err := c.ShouldBindJSON(&order); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		order.Datacenter = cfg.Datacenter

		// 1. Write to DB
		// Uses "ON CONFLICT" or simply insert.
		// For Active-Active, we rely on LWW at DB level triggers usually, but here is simple insert.
		var id int
		err := db.DB.QueryRow(
			"INSERT INTO orders (item, qty, datacenter, status) VALUES ($1, $2, $3, 'pending') RETURNING id",
			order.Item, order.Qty, order.Datacenter,
		).Scan(&id)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "DB write failed", "details": err.Error()})
			return
		}

		order.ID = id

		// 2. Publish to Redis (Queue)
		if err := queue.Publish(cfg.RedisHost, order); err != nil {
			// In a real system we might rollback or handle this, but for POC we log
			// Or we might just say "Accepted"
			c.JSON(http.StatusAccepted, gin.H{"warning": "Queuing failed", "order": order})
			return
		}

		c.JSON(http.StatusCreated, order)
	})

	r.GET("/orders/:id", func(c *gin.Context) {
		id := c.Param("id")
		var order db.Order
		err := db.DB.QueryRow("SELECT id, item, qty, datacenter, status, created_at FROM orders WHERE id = $1", id).
			Scan(&order.ID, &order.Item, &order.Qty, &order.Datacenter, &order.Status, &order.CreatedAt)

		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Order not found"})
			return
		}
		c.JSON(http.StatusOK, order)
	})

	r.GET("/orders", func(c *gin.Context) {
		rows, err := db.DB.Query("SELECT id, item, qty, datacenter, status, created_at FROM orders")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		defer rows.Close()

		var orders []db.Order
		for rows.Next() {
			var o db.Order
			if err := rows.Scan(&o.ID, &o.Item, &o.Qty, &o.Datacenter, &o.Status, &o.CreatedAt); err != nil {
				continue
			}
			orders = append(orders, o)
		}
		c.JSON(http.StatusOK, orders)
	})
}
