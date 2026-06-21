package main

import (
	"context"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"github.com/joho/godotenv"

	"github.com/yourusername/mealtion/backend/internal/config"
	"github.com/yourusername/mealtion/backend/internal/database"
	"github.com/yourusername/mealtion/backend/internal/email"
	"github.com/yourusername/mealtion/backend/internal/handler"
	"github.com/yourusername/mealtion/backend/internal/middleware"
	"github.com/yourusername/mealtion/backend/internal/repository"
	"github.com/yourusername/mealtion/backend/internal/service"
)

func main() {
	godotenv.Load()
	cfg := config.Load()
	ctx := context.Background()

	pool, err := database.Connect(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer pool.Close()

	userRepo := repository.NewUserRepository(pool)
	sessionRepo := repository.NewSessionRepository(pool)
	emailSender := email.NewConsoleSender()
	authService := service.NewAuthService(userRepo, sessionRepo, emailSender, cfg)
	authHandler := handler.NewAuthHandler(authService)

	r := chi.NewRouter()
	r.Use(chimw.Logger)
	r.Use(chimw.Recoverer)
	r.Use(middleware.Logging)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: true,
	}))

	r.Route("/api/v1/auth", func(r chi.Router) {
		r.Post("/signup", authHandler.SignUp)
		r.Post("/verify-email", authHandler.VerifyEmail)
		r.Post("/login", authHandler.Login)
		r.Post("/refresh", authHandler.RefreshToken)
		r.Post("/forgot-password", authHandler.ForgotPassword)

		r.Group(func(r chi.Router) {
			r.Use(middleware.Auth(cfg))
			r.Delete("/account", authHandler.DeleteAccount)
			r.Get("/me", authHandler.GetMe)
		})
	})

	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`{"status":"ok"}`))
	})

	port := cfg.ServerPort
	log.Printf("server starting on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}
