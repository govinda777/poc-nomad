package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"poc-app/config"
	"poc-app/db"
	"poc-app/queue"
)

type Server struct {
	Config *config.Config
	DB     *db.DBClient
	Queue  *queue.RedisClient
}

func (s *Server) HealthHandler(w http.ResponseWriter, r *http.Request) {
	// Deep health check: check DB connectivity
	err := s.DB.Conn.Ping()
	if err != nil {
		w.WriteHeader(http.StatusServiceUnavailable)
		w.Write([]byte(fmt.Sprintf("DB Down: %v", err)))
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

func (s *Server) CreateOrderHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var o db.Order
	if err := json.NewDecoder(r.Body).Decode(&o); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Enrich
	o.Timestamp = time.Now().UTC()
	o.Datacenter = s.Config.Datacenter
	o.Status = "pending"

	// 1. Write to DB (Local)
	// If this is a Read-Only Replica (Standby), this will fail with "cannot execute INSERT in a read-only transaction"
	err := s.DB.CreateOrder(&o)
	if err != nil {
		if strings.Contains(err.Error(), "read-only transaction") {
			// Failover logic simulation: In a real app we might proxy to the Primary.
			// Here we return 503 so the Load Balancer / Client knows to retry elsewhere.
			http.Error(w, "DC is Read-Only (Standby)", http.StatusServiceUnavailable)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// 2. Publish to Redis (Local)
	// If Redis is a Replica, PUBLISH commands are actually allowed (but ignored/not propagated depending on config,
    // or just local). In standard Redis replication, replicas are read-only by default.
	// For this POC, we assume Redis Primary logic follows DB Primary logic usually.
	err = s.Queue.PublishOrder(r.Context(), &o)
	if err != nil {
		// Log error but maybe don't fail the request if DB write succeeded?
		// For strong consistency, maybe we should.
		fmt.Printf("Error publishing to redis: %v\n", err)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(o)
}

func (s *Server) GetOrderHandler(w http.ResponseWriter, r *http.Request) {
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 3 {
		http.Error(w, "Invalid ID", http.StatusBadRequest)
		return
	}
	idStr := pathParts[2]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid ID", http.StatusBadRequest)
		return
	}

	o, err := s.DB.GetOrder(id)
	if err != nil {
		if err == db.ErrNotFound { // Need to define this or check sql.ErrNoRows
			http.Error(w, "Order not found", http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(o)
}
