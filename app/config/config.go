package config

import (
	"os"
)

type Config struct {
	Datacenter string
	DBHost     string
	DBUser     string
	DBPassword string
	DBName     string
	RedisHost  string
}

func Load() *Config {
	return &Config{
		Datacenter: getEnv("DATACENTER", "aws"),
		DBHost:     getEnv("DB_HOST", "localhost"),
		DBUser:     getEnv("POSTGRES_USER", "poc"),
		DBPassword: getEnv("POSTGRES_PASSWORD", ""), // Fail/Empty if not set, handled by DB connection logic
		DBName:     getEnv("POSTGRES_DB", "pocdb"),
		RedisHost:  getEnv("REDIS_HOST", "localhost"),
	}
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}
