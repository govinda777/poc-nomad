package config

import (
	"os"
)

type Config struct {
	Datacenter string
	DBHost     string
	DBUser     string
	DBPass     string
	DBName     string
	RedisHost  string
	ServerPort string
}

func LoadConfig() *Config {
	return &Config{
		Datacenter: getEnv("DATACENTER", "aws"),
		DBHost:     getEnv("DB_HOST", "localhost"),
		DBUser:     getEnv("POSTGRES_USER", "poc"),
		DBPass:     getEnv("POSTGRES_PASSWORD", "pocpass"),
		DBName:     getEnv("POSTGRES_DB", "pocdb"),
		RedisHost:  getEnv("REDIS_HOST", "localhost"),
		ServerPort: getEnv("PORT", "8080"),
	}
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}
