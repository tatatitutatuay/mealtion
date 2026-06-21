package config

import (
	"os"
	"strconv"
)

type Config struct {
	DatabaseURL       string
	JWTSecret         string
	JWTAccessExpiry   int
	JWTRefreshExpiry  int
	SMTPHost          string
	SMTPPort          int
	SMTPUser          string
	SMTPPass          string
	ServerPort        string
	Environment       string
}

func Load() *Config {
	port, _ := strconv.Atoi(getEnv("SMTP_PORT", "587"))
	return &Config{
		DatabaseURL:      getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/mealtion?sslmode=disable"),
		JWTSecret:        getEnv("JWT_SECRET", "dev-secret"),
		JWTAccessExpiry:  getEnvInt("JWT_ACCESS_EXPIRY", 3600),
		JWTRefreshExpiry: getEnvInt("JWT_REFRESH_EXPIRY", 2592000),
		SMTPHost:         getEnv("SMTP_HOST", ""),
		SMTPPort:         port,
		SMTPUser:         getEnv("SMTP_USER", ""),
		SMTPPass:         getEnv("SMTP_PASS", ""),
		ServerPort:       getEnv("SERVER_PORT", "8080"),
		Environment:      getEnv("ENVIRONMENT", "development"),
	}
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if val := os.Getenv(key); val != "" {
		if i, err := strconv.Atoi(val); err == nil {
			return i
		}
	}
	return fallback
}
