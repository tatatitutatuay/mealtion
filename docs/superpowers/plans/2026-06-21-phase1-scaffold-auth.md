# Phase 1: Project Scaffold + Auth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the monorepo with a working Go backend and Flutter app, with full email/password auth (sign up, email verification, login, token refresh, forgot password, delete account).

**Architecture:** Monorepo with `backend/` (Go + Chi + PostgreSQL) and `app/` (Flutter + Riverpod + GoRouter). JWT auth with access + refresh tokens.

**Tech Stack:** Go 1.22+, Chi, pgx, golang-migrate, Flutter 3.x, Riverpod, GoRouter, flutter_secure_storage

**Prerequisites:** Go 1.22+, Flutter 3.x, PostgreSQL running locally, Dart SDK.

---

## File Map

### Backend files (created)
- `backend/go.mod`
- `backend/go.sum`
- `backend/cmd/server/main.go`
- `backend/internal/config/config.go`
- `backend/internal/database/postgres.go`
- `backend/internal/model/user.go`
- `backend/internal/repository/user.go`
- `backend/internal/repository/session.go`
- `backend/internal/service/auth.go`
- `backend/internal/handler/auth.go`
- `backend/internal/handler/response.go`
- `backend/internal/middleware/auth.go`
- `backend/internal/middleware/logging.go`
- `backend/internal/email/sender.go`
- `backend/migrations/001_create_users.up.sql`
- `backend/migrations/001_create_users.down.sql`
- `backend/migrations/002_create_sessions.up.sql`
- `backend/migrations/002_create_sessions.down.sql`

### Flutter files (created)
- `app/pubspec.yaml`
- `app/analysis_options.yaml`
- `app/lib/main.dart`
- `app/lib/core/theme/app_theme.dart`
- `app/lib/core/theme/colors.dart`
- `app/lib/core/router/app_router.dart`
- `app/lib/core/router/auth_guard.dart`
- `app/lib/core/api/api_client.dart`
- `app/lib/core/api/auth_api.dart`
- `app/lib/core/api/models/api_response.dart`
- `app/lib/core/storage/secure_storage.dart`
- `app/lib/features/auth/models/auth_state.dart`
- `app/lib/features/auth/providers/auth_provider.dart`
- `app/lib/features/auth/screens/login_screen.dart`
- `app/lib/features/auth/screens/signup_screen.dart`
- `app/lib/features/auth/screens/verify_email_screen.dart`
- `app/lib/features/auth/screens/forgot_password_screen.dart`
- `app/lib/features/home/screens/home_screen.dart`

---

### Task 1: Initialize Go module and install dependencies

**Files:**
- Create: `backend/go.mod`

- [ ] **Step 1: Create go.mod**

Run:
```powershell
Set-Location -LiteralPath "backend"; go mod init github.com/yourusername/mealtion/backend
```

- [ ] **Step 2: Install dependencies**

Run:
```powershell
Set-Location -LiteralPath "backend"; go get github.com/go-chi/chi/v5 github.com/go-chi/cors github.com/jackc/pgx/v5 github.com/golang-jwt/jwt/v5 golang.org/x/crypto github.com/golang-migrate/migrate/v4 github.com/joho/godotenv github.com/google/uuid
```

- [ ] **Step 3: Tidy modules**

Run:
```powershell
Set-Location -LiteralPath "backend"; go mod tidy
```

- [ ] **Step 4: Create backend `.env` file**

Create `backend/.env`:
```
DATABASE_URL=postgres://postgres:postgres@localhost:5432/mealtion?sslmode=disable
JWT_SECRET=change-me-in-production
JWT_ACCESS_EXPIRY=3600
JWT_REFRESH_EXPIRY=2592000
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SERVER_PORT=8080
```

- [ ] **Step 5: Commit**

```powershell
git init; git add backend/go.mod backend/go.sum backend/.env.example; git commit -m "chore: initialize Go module with dependencies"
```

---

### Task 2: Create Go config and database connection

**Files:**
- Create: `backend/internal/config/config.go`
- Create: `backend/internal/database/postgres.go`
- Create: `backend/migrations/001_create_users.up.sql`
- Create: `backend/migrations/001_create_users.down.sql`
- Create: `backend/migrations/002_create_sessions.up.sql`
- Create: `backend/migrations/002_create_sessions.down.sql`

- [ ] **Step 1: Write config loader**

`backend/internal/config/config.go`:
```go
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
```

- [ ] **Step 2: Write database connection**

`backend/internal/database/postgres.go`:
```go
package database

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

func Connect(ctx context.Context, databaseURL string) (*pgxpool.Pool, error) {
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		return nil, fmt.Errorf("unable to connect to database: %w", err)
	}
	if err := pool.Ping(ctx); err != nil {
		return nil, fmt.Errorf("unable to ping database: %w", err)
	}
	return pool, nil
}
```

- [ ] **Step 3: Write user migration (up)**

`backend/migrations/001_create_users.up.sql`:
```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    display_name VARCHAR(30),
    username VARCHAR(20),
    bio VARCHAR(150) DEFAULT '',
    photo_url TEXT DEFAULT '',
    primary_currency VARCHAR(3) DEFAULT 'USD',
    price_threshold_low NUMERIC(12,2) DEFAULT 10.00,
    price_threshold_high NUMERIC(12,2) DEFAULT 50.00,
    price_display_privacy VARCHAR(10) DEFAULT 'actual',
    email_verified BOOLEAN DEFAULT FALSE,
    verification_token TEXT DEFAULT '',
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

- [ ] **Step 4: Write user migration (down)**

`backend/migrations/001_create_users.down.sql`:
```sql
DROP TABLE IF EXISTS users;
```

- [ ] **Step 5: Write sessions migration (up)**

`backend/migrations/002_create_sessions.up.sql`:
```sql
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
```

- [ ] **Step 6: Write sessions migration (down)**

`backend/migrations/002_create_sessions.down.sql`:
```sql
DROP TABLE IF EXISTS sessions;
```

- [ ] **Step 7: Run migrations**

Run:
```powershell
Set-Location -LiteralPath "backend"; createdb mealtion; migrate -path migrations -database "$env:DATABASE_URL" up
```

- [ ] **Step 8: Commit**

```powershell
git add backend/internal/config/ backend/internal/database/ backend/migrations/; git commit -m "feat: add config, database connection, and auth migrations"
```

---

### Task 3: Domain models (User)

**Files:**
- Create: `backend/internal/model/user.go`

- [ ] **Step 1: Write user model**

`backend/internal/model/user.go`:
```go
package model

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID                   uuid.UUID `json:"id"`
	Email                string    `json:"email"`
	PasswordHash         string    `json:"-"`
	DisplayName          string    `json:"display_name"`
	Username             string    `json:"username"`
	Bio                  string    `json:"bio"`
	PhotoURL             string    `json:"photo_url"`
	PrimaryCurrency      string    `json:"primary_currency"`
	PriceThresholdLow    float64   `json:"price_threshold_low"`
	PriceThresholdHigh   float64   `json:"price_threshold_high"`
	PriceDisplayPrivacy  string    `json:"price_display_privacy"`
	EmailVerified        bool      `json:"email_verified"`
	VerificationToken    string    `json:"-"`
	OnboardingCompleted  bool      `json:"onboarding_completed"`
	CreatedAt            time.Time `json:"created_at"`
	UpdatedAt            time.Time `json:"updated_at"`
}

type Session struct {
	ID               uuid.UUID `json:"id"`
	UserID           uuid.UUID `json:"user_id"`
	RefreshTokenHash string    `json:"-"`
	ExpiresAt        time.Time `json:"expires_at"`
	CreatedAt        time.Time `json:"created_at"`
}

type SignUpRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type AuthResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	User         User   `json:"user"`
}

type TokenRefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}
```

- [ ] **Step 2: Commit**

```powershell
git add backend/internal/model/; git commit -m "feat: add user and auth models"
```

---

### Task 4: User repository

**Files:**
- Create: `backend/internal/repository/user.go`
- Create: `backend/internal/repository/session.go`

- [ ] **Step 1: Write user repository test**

`backend/internal/repository/user_test.go`:
```go
package repository

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/yourusername/mealtion/backend/internal/model"
)

func setupTestDB(t *testing.T) *pgxpool.Pool {
	t.Helper()
	// uses DATABASE_URL from env
	// In CI, this would use a test DB
	pool, err := pgxpool.New(context.Background(), "postgres://postgres:postgres@localhost:5432/mealtion_test?sslmode=disable")
	if err != nil {
		t.Skipf("no test database: %v", err)
	}
	t.Cleanup(func() { pool.Close() })
	return pool
}

func TestCreateAndFindByEmail(t *testing.T) {
	pool := setupTestDB(t)
	repo := NewUserRepository(pool)
	ctx := context.Background()

	email := "test_" + uuid.New().String() + "@example.com"
	user, err := repo.Create(ctx, model.User{
		Email:        email,
		PasswordHash: "hashed_password",
	})
	if err != nil {
		t.Fatalf("Create failed: %v", err)
	}
	if user.Email != email {
		t.Errorf("expected email %s, got %s", email, user.Email)
	}

	found, err := repo.FindByEmail(ctx, email)
	if err != nil {
		t.Fatalf("FindByEmail failed: %v", err)
	}
	if found.ID != user.ID {
		t.Errorf("expected id %v, got %v", user.ID, found.ID)
	}
}
```

- [ ] **Step 2: Run test to verify it fails**

```powershell
Set-Location -LiteralPath "backend"; go test ./internal/repository/ -run TestCreateAndFindByEmail -v
```
Expected: FAIL with `undefined: NewUserRepository`

- [ ] **Step 3: Write user repository**

`backend/internal/repository/user.go`:
```go
package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/yourusername/mealtion/backend/internal/model"
)

type UserRepository struct {
	pool *pgxpool.Pool
}

func NewUserRepository(pool *pgxpool.Pool) *UserRepository {
	return &UserRepository{pool: pool}
}

func (r *UserRepository) Create(ctx context.Context, user model.User) (model.User, error) {
	row := r.pool.QueryRow(ctx,
		`INSERT INTO users (email, password_hash, verification_token)
		 VALUES ($1, $2, $3)
		 RETURNING id, email, password_hash, display_name, username, bio, photo_url,
		           primary_currency, price_threshold_low, price_threshold_high,
		           price_display_privacy, email_verified, verification_token,
		           onboarding_completed, created_at, updated_at`,
		user.Email, user.PasswordHash, user.VerificationToken,
	)
	return scanUser(row)
}

func (r *UserRepository) FindByEmail(ctx context.Context, email string) (model.User, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, email, password_hash, display_name, username, bio, photo_url,
		        primary_currency, price_threshold_low, price_threshold_high,
		        price_display_privacy, email_verified, verification_token,
		        onboarding_completed, created_at, updated_at
		 FROM users WHERE email = $1`, email,
	)
	return scanUser(row)
}

func (r *UserRepository) FindByID(ctx context.Context, id string) (model.User, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, email, password_hash, display_name, username, bio, photo_url,
		        primary_currency, price_threshold_low, price_threshold_high,
		        price_display_privacy, email_verified, verification_token,
		        onboarding_completed, created_at, updated_at
		 FROM users WHERE id = $1`, id,
	)
	return scanUser(row)
}

func (r *UserRepository) FindByVerificationToken(ctx context.Context, token string) (model.User, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, email, password_hash, display_name, username, bio, photo_url,
		        primary_currency, price_threshold_low, price_threshold_high,
		        price_display_privacy, email_verified, verification_token,
		        onboarding_completed, created_at, updated_at
		 FROM users WHERE verification_token = $1`, token,
	)
	return scanUser(row)
}

func (r *UserRepository) VerifyEmail(ctx context.Context, userID string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE users SET email_verified = TRUE, verification_token = '', updated_at = NOW()
		 WHERE id = $1`, userID,
	)
	return err
}

func (r *UserRepository) UpdatePassword(ctx context.Context, userID string, hash string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2`,
		hash, userID,
	)
	return err
}

func (r *UserRepository) Delete(ctx context.Context, userID string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM users WHERE id = $1`, userID)
	return err
}

func scanUser(row pgx.Row) (model.User, error) {
	var u model.User
	err := row.Scan(
		&u.ID, &u.Email, &u.PasswordHash, &u.DisplayName, &u.Username,
		&u.Bio, &u.PhotoURL, &u.PrimaryCurrency, &u.PriceThresholdLow,
		&u.PriceThresholdHigh, &u.PriceDisplayPrivacy, &u.EmailVerified,
		&u.VerificationToken, &u.OnboardingCompleted, &u.CreatedAt, &u.UpdatedAt,
	)
	return u, err
}

func (r *UserRepository) UpdateOnboarding(ctx context.Context, userID string, displayName string, username string, bio string, photoURL string, currency string, thresholdLow float64, thresholdHigh float64) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE users SET display_name = $1, username = $2, bio = $3, photo_url = $4,
		 primary_currency = $5, price_threshold_low = $6, price_threshold_high = $7,
		 onboarding_completed = TRUE, updated_at = NOW()
		 WHERE id = $8`,
		displayName, username, bio, photoURL, currency, thresholdLow, thresholdHigh, userID,
	)
	return err
}

func (r *UserRepository) FindByUsername(ctx context.Context, username string) (model.User, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, email, password_hash, display_name, username, bio, photo_url,
		        primary_currency, price_threshold_low, price_threshold_high,
		        price_display_privacy, email_verified, verification_token,
		        onboarding_completed, created_at, updated_at
		 FROM users WHERE username = $1`, username,
	)
	return scanUser(row)
}
```

- [ ] **Step 4: Run test to verify it passes**

```powershell
Set-Location -LiteralPath "backend"; go test ./internal/repository/ -run TestCreateAndFindByEmail -v
```

- [ ] **Step 5: Write session repository**

`backend/internal/repository/session.go`:
```go
package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/yourusername/mealtion/backend/internal/model"
)

type SessionRepository struct {
	pool *pgxpool.Pool
}

func NewSessionRepository(pool *pgxpool.Pool) *SessionRepository {
	return &SessionRepository{pool: pool}
}

func (r *SessionRepository) Create(ctx context.Context, userID string, hash string, expiresAt time.Time) (model.Session, error) {
	row := r.pool.QueryRow(ctx,
		`INSERT INTO sessions (user_id, refresh_token_hash, expires_at)
		 VALUES ($1, $2, $3)
		 RETURNING id, user_id, refresh_token_hash, expires_at, created_at`,
		userID, hash, expiresAt,
	)
	var s model.Session
	err := row.Scan(&s.ID, &s.UserID, &s.RefreshTokenHash, &s.ExpiresAt, &s.CreatedAt)
	return s, err
}

func (r *SessionRepository) FindByRefreshHash(ctx context.Context, hash string) (model.Session, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, user_id, refresh_token_hash, expires_at, created_at
		 FROM sessions WHERE refresh_token_hash = $1 AND expires_at > NOW()`, hash,
	)
	var s model.Session
	err := row.Scan(&s.ID, &s.UserID, &s.RefreshTokenHash, &s.ExpiresAt, &s.CreatedAt)
	return s, err
}

func (r *SessionRepository) DeleteByUserID(ctx context.Context, userID string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM sessions WHERE user_id = $1`, userID)
	return err
}

func (r *SessionRepository) DeleteExpired(ctx context.Context) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM sessions WHERE expires_at < NOW()`)
	return err
}
```

- [ ] **Step 6: Run all tests**

```powershell
Set-Location -LiteralPath "backend"; go test ./internal/repository/ -v
```

- [ ] **Step 7: Commit**

```powershell
git add backend/internal/repository/; git commit -m "feat: add user and session repositories"
```

---

### Task 5: Auth service (business logic)

**Files:**
- Create: `backend/internal/service/auth.go`
- Create: `backend/internal/email/sender.go`

- [ ] **Step 1: Write email sender (mock for MVP)**

`backend/internal/email/sender.go`:
```go
package email

import (
	"log"
)

type Sender interface {
	SendVerificationEmail(to string, token string) error
	SendPasswordResetEmail(to string, token string) error
}

type ConsoleSender struct{}

func NewConsoleSender() *ConsoleSender {
	return &ConsoleSender{}
}

func (s *ConsoleSender) SendVerificationEmail(to string, token string) error {
	log.Printf("[EMAIL] To: %s | Verify: http://localhost:8080/api/v1/auth/verify-email?token=%s", to, token)
	return nil
}

func (s *ConsoleSender) SendPasswordResetEmail(to string, token string) error {
	log.Printf("[EMAIL] To: %s | Reset: http://localhost:8080/api/v1/auth/reset-password?token=%s", to, token)
	return nil
}
```

- [ ] **Step 2: Write auth service**

`backend/internal/service/auth.go`:
```go
package service

import (
	"context"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"

	"github.com/yourusername/mealtion/backend/internal/config"
	"github.com/yourusername/mealtion/backend/internal/email"
	"github.com/yourusername/mealtion/backend/internal/model"
	"github.com/yourusername/mealtion/backend/internal/repository"
)

var (
	ErrEmailAlreadyExists = errors.New("email already registered")
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrEmailNotVerified   = errors.New("email not verified")
	ErrUserNotFound       = errors.New("user not found")
	ErrInvalidToken       = errors.New("invalid or expired token")
)

type AuthService struct {
	userRepo    *repository.UserRepository
	sessionRepo *repository.SessionRepository
	emailSender email.Sender
	config      *config.Config
}

func NewAuthService(
	userRepo *repository.UserRepository,
	sessionRepo *repository.SessionRepository,
	emailSender email.Sender,
	cfg *config.Config,
) *AuthService {
	return &AuthService{
		userRepo:    userRepo,
		sessionRepo: sessionRepo,
		emailSender: emailSender,
		config:      cfg,
	}
}

func (s *AuthService) SignUp(ctx context.Context, req model.SignUpRequest) error {
	existing, err := s.userRepo.FindByEmail(ctx, req.Email)
	if err == nil && existing.ID != uuid.Nil {
		return ErrEmailAlreadyExists
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	verificationToken := uuid.New().String()

	_, err = s.userRepo.Create(ctx, model.User{
		Email:             req.Email,
		PasswordHash:      string(hash),
		VerificationToken: verificationToken,
	})
	if err != nil {
		return err
	}

	return s.emailSender.SendVerificationEmail(req.Email, verificationToken)
}

func (s *AuthService) VerifyEmail(ctx context.Context, token string) error {
	user, err := s.userRepo.FindByVerificationToken(ctx, token)
	if err != nil {
		return ErrInvalidToken
	}
	return s.userRepo.VerifyEmail(ctx, user.ID.String())
}

func (s *AuthService) Login(ctx context.Context, req model.LoginRequest) (*model.AuthResponse, error) {
	user, err := s.userRepo.FindByEmail(ctx, req.Email)
	if err != nil {
		return nil, ErrInvalidCredentials
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, ErrInvalidCredentials
	}

	if !user.EmailVerified {
		return nil, ErrEmailNotVerified
	}

	accessToken, err := s.generateAccessToken(user.ID.String())
	if err != nil {
		return nil, err
	}

	refreshToken, refreshHash, err := s.generateRefreshToken()
	if err != nil {
		return nil, err
	}

	expiresAt := time.Now().Add(time.Duration(s.config.JWTRefreshExpiry) * time.Second)
	if _, err := s.sessionRepo.Create(ctx, user.ID.String(), refreshHash, expiresAt); err != nil {
		return nil, err
	}

	return &model.AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User:         user,
	}, nil
}

func (s *AuthService) RefreshToken(ctx context.Context, refreshToken string) (*model.AuthResponse, error) {
	hash := hashToken(refreshToken)
	session, err := s.sessionRepo.FindByRefreshHash(ctx, hash)
	if err != nil {
		return nil, ErrInvalidToken
	}

	user, err := s.userRepo.FindByID(ctx, session.UserID.String())
	if err != nil {
		return nil, ErrUserNotFound
	}

	accessToken, err := s.generateAccessToken(user.ID.String())
	if err != nil {
		return nil, err
	}

	newRefreshToken, newHash, err := s.generateRefreshToken()
	if err != nil {
		return nil, err
	}

	expiresAt := time.Now().Add(time.Duration(s.config.JWTRefreshExpiry) * time.Second)
	if _, err := s.sessionRepo.Create(ctx, user.ID.String(), newHash, expiresAt); err != nil {
		return nil, err
	}

	return &model.AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
		User:         user,
	}, nil
}

func (s *AuthService) DeleteAccount(ctx context.Context, userID string, password string) error {
	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return ErrUserNotFound
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
		return ErrInvalidCredentials
	}

	if err := s.sessionRepo.DeleteByUserID(ctx, userID); err != nil {
		return err
	}

	return s.userRepo.Delete(ctx, userID)
}

func (s *AuthService) ForgotPassword(ctx context.Context, email string) error {
	user, err := s.userRepo.FindByEmail(ctx, email)
	if err != nil {
		return nil
	}

	token := uuid.New().String()
	if err := s.userRepo.UpdatePassword(ctx, user.ID.String(), token); err != nil {
		return err
	}

	return s.emailSender.SendPasswordResetEmail(email, token)
}

func (s *AuthService) generateAccessToken(userID string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Duration(s.config.JWTAccessExpiry) * time.Second).Unix(),
		"iat":     time.Now().Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.config.JWTSecret))
}

func (s *AuthService) generateRefreshToken() (string, string, error) {
	token := uuid.New().String() + uuid.New().String()
	hash := hashToken(token)
	return token, hash, nil
}

func hashToken(token string) string {
	hash, _ := bcrypt.GenerateFromPassword([]byte(token), bcrypt.DefaultCost)
	return string(hash)
}
```

- [ ] **Step 3: Commit**

```powershell
git add backend/internal/service/ backend/internal/email/; git commit -m "feat: add auth service and email sender"
```

---

### Task 6: Auth HTTP handlers + middleware

**Files:**
- Create: `backend/internal/handler/response.go`
- Create: `backend/internal/handler/auth.go`
- Create: `backend/internal/middleware/auth.go`
- Create: `backend/internal/middleware/logging.go`

- [ ] **Step 1: Write response helpers**

`backend/internal/handler/response.go`:
```go
package handler

import (
	"encoding/json"
	"net/http"
)

type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

func respondJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(APIResponse{Success: true, Data: data})
}

func respondError(w http.ResponseWriter, status int, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(APIResponse{Success: false, Error: message})
}
```

- [ ] **Step 2: Write auth middleware**

`backend/internal/middleware/auth.go`:
```go
package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
	"github.com/yourusername/mealtion/backend/internal/config"
)

type contextKey string

const UserIDKey contextKey = "user_id"

func Auth(cfg *config.Config) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			if header == "" {
				http.Error(w, `{"success":false,"error":"missing authorization header"}`, http.StatusUnauthorized)
				return
			}

			parts := strings.Split(header, " ")
			if len(parts) != 2 || parts[0] != "Bearer" {
				http.Error(w, `{"success":false,"error":"invalid authorization format"}`, http.StatusUnauthorized)
				return
			}

			token, err := jwt.Parse(parts[1], func(t *jwt.Token) (interface{}, error) {
				return []byte(cfg.JWTSecret), nil
			})
			if err != nil || !token.Valid {
				http.Error(w, `{"success":false,"error":"invalid or expired token"}`, http.StatusUnauthorized)
				return
			}

			claims, ok := token.Claims.(jwt.MapClaims)
			if !ok {
				http.Error(w, `{"success":false,"error":"invalid token claims"}`, http.StatusUnauthorized)
				return
			}

			userID, ok := claims["user_id"].(string)
			if !ok {
				http.Error(w, `{"success":false,"error":"invalid user_id in token"}`, http.StatusUnauthorized)
				return
			}

			ctx := context.WithValue(r.Context(), UserIDKey, userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func GetUserID(ctx context.Context) string {
	if id, ok := ctx.Value(UserIDKey).(string); ok {
		return id
	}
	return ""
}
```

- [ ] **Step 3: Write logging middleware**

`backend/internal/middleware/logging.go`:
```go
package middleware

import (
	"log"
	"net/http"
	"time"
)

type responseWriter struct {
	http.ResponseWriter
	status int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.status = code
	rw.ResponseWriter.WriteHeader(code)
}

func Logging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rw := &responseWriter{ResponseWriter: w, status: http.StatusOK}
		next.ServeHTTP(rw, r)
		log.Printf("%s %s %d %s", r.Method, r.URL.Path, rw.status, time.Since(start))
	})
}
```

- [ ] **Step 4: Write auth handlers**

`backend/internal/handler/auth.go`:
```go
package handler

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/yourusername/mealtion/backend/internal/middleware"
	"github.com/yourusername/mealtion/backend/internal/model"
	"github.com/yourusername/mealtion/backend/internal/service"
)

type AuthHandler struct {
	authService *service.AuthService
}

func NewAuthHandler(authService *service.AuthService) *AuthHandler {
	return &AuthHandler{authService: authService}
}

func (h *AuthHandler) SignUp(w http.ResponseWriter, r *http.Request) {
	var req model.SignUpRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if req.Email == "" || req.Password == "" {
		respondError(w, http.StatusBadRequest, "email and password are required")
		return
	}
	if len(req.Password) < 6 {
		respondError(w, http.StatusBadRequest, "password must be at least 6 characters")
		return
	}
	if err := h.authService.SignUp(r.Context(), req); err != nil {
		if errors.Is(err, service.ErrEmailAlreadyExists) {
			respondError(w, http.StatusConflict, "email already registered")
			return
		}
		respondError(w, http.StatusInternalServerError, "failed to create account")
		return
	}
	respondJSON(w, http.StatusCreated, map[string]string{"message": "verification email sent"})
}

func (h *AuthHandler) VerifyEmail(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		respondError(w, http.StatusBadRequest, "verification token is required")
		return
	}
	if err := h.authService.VerifyEmail(r.Context(), token); err != nil {
		respondError(w, http.StatusBadRequest, "invalid or expired token")
		return
	}
	respondJSON(w, http.StatusOK, map[string]string{"message": "email verified successfully"})
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req model.LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	resp, err := h.authService.Login(r.Context(), req)
	if err != nil {
		if errors.Is(err, service.ErrInvalidCredentials) {
			respondError(w, http.StatusUnauthorized, "invalid email or password")
			return
		}
		if errors.Is(err, service.ErrEmailNotVerified) {
			respondError(w, http.StatusForbidden, "email not verified")
			return
		}
		respondError(w, http.StatusInternalServerError, "login failed")
		return
	}
	respondJSON(w, http.StatusOK, resp)
}

func (h *AuthHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	var req model.TokenRefreshRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	resp, err := h.authService.RefreshToken(r.Context(), req.RefreshToken)
	if err != nil {
		respondError(w, http.StatusUnauthorized, "invalid or expired refresh token")
		return
	}
	respondJSON(w, http.StatusOK, resp)
}

func (h *AuthHandler) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email string `json:"email"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := h.authService.ForgotPassword(r.Context(), req.Email); err != nil {
		respondError(w, http.StatusInternalServerError, "failed to send reset email")
		return
	}
	respondJSON(w, http.StatusOK, map[string]string{"message": "if the email exists, a reset link has been sent"})
}

func (h *AuthHandler) DeleteAccount(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	var req struct {
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if err := h.authService.DeleteAccount(r.Context(), userID, req.Password); err != nil {
		respondError(w, http.StatusUnauthorized, "incorrect password")
		return
	}
	respondJSON(w, http.StatusOK, map[string]string{"message": "account deleted"})
}

func (h *AuthHandler) GetMe(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	user, err := h.authService.GetUser(r.Context(), userID)
	if err != nil {
		respondError(w, http.StatusNotFound, "user not found")
		return
	}
	respondJSON(w, http.StatusOK, user)
}
```

- [ ] **Step 5: Add GetUser method to AuthService**

Add to `backend/internal/service/auth.go`:
```go
func (s *AuthService) GetUser(ctx context.Context, userID string) (*model.User, error) {
	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return nil, ErrUserNotFound
	}
	return &user, nil
}
```

- [ ] **Step 6: Write server main entry**

`backend/cmd/server/main.go`:
```go
package main

import (
	"context"
	"log"
	"net/http"
	"os"

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
```

- [ ] **Step 7: Build and verify compilation**

```powershell
Set-Location -LiteralPath "backend"; go build ./cmd/server/
```
Expected: binary created with no errors

- [ ] **Step 8: Run server and smoke-test health endpoint**

```powershell
$env:DATABASE_URL="postgres://postgres:postgres@localhost:5432/mealtion?sslmode=disable"; Set-Location -LiteralPath "backend"; Start-Process -NoNewWindow -FilePath ".\server.exe"; sleep 2; curl http://localhost:8080/health
```
Expected: `{"status":"ok"}`

- [ ] **Step 9: Commit**

```powershell
git add backend/cmd/ backend/internal/handler/ backend/internal/middleware/; git commit -m "feat: add auth handlers, middleware, and server entry point"
```

---

### Task 7: Create Flutter project

**Files:**
- Create: `app/pubspec.yaml`
- Create: `app/analysis_options.yaml`

- [ ] **Step 1: Create Flutter project**

```powershell
Set-Location -LiteralPath "..\app"; flutter create --org com.mealtion --project-name mealtion --platforms ios,android .
```

- [ ] **Step 2: Add dependencies to pubspec.yaml**

Edit `app/pubspec.yaml` dependencies section:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^14.0.0
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  cached_network_image: ^3.3.0
  intl: ^0.19.0
  json_annotation: ^4.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.4.0
  mocktail: ^1.0.0
```

- [ ] **Step 3: Update analysis_options.yaml**

`app/analysis_options.yaml`:
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: false

analyzer:
  errors:
    invalid_annotation_target: ignore
```

- [ ] **Step 4: Run pub get**

```powershell
Set-Location -LiteralPath "..\app"; flutter pub get
```

- [ ] **Step 5: Commit**

```powershell
git add app/pubspec.yaml app/analysis_options.yaml app/lib/ app/test/; git commit -m "chore: scaffold Flutter project with dependencies"
```

---

### Task 8: Flutter core infrastructure (theme, router, API client)

**Files:**
- Create: `app/lib/core/theme/app_theme.dart`
- Create: `app/lib/core/theme/colors.dart`
- Create: `app/lib/core/router/app_router.dart`
- Create: `app/lib/core/router/auth_guard.dart`
- Create: `app/lib/core/api/api_client.dart`
- Create: `app/lib/core/api/auth_api.dart`
- Create: `app/lib/core/api/models/api_response.dart`
- Create: `app/lib/core/storage/secure_storage.dart`

- [ ] **Step 1: Write theme colors**

`app/lib/core/theme/colors.dart`:
```dart
class AppColors {
  static const primary = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF388E3C);
  static const accent = Color(0xFFFFC107);
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const error = Color(0xFFE53935);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const priceAffordable = Color(0xFF4CAF50);
  static const priceModerate = Color(0xFFFFC107);
  static const priceExpensive = Color(0xFFE53935);
  static const heavinessLight = Color(0xFF4CAF50);
  static const heavinessSatisfying = Color(0xFFFFC107);
  static const heavinessHeavy = Color(0xFFE53935);
  static const feelingLike = Color(0xFF4CAF50);
  static const feelingNeutral = Color(0xFFFFC107);
  static const feelingDislike = Color(0xFFE53935);
}
```

- [ ] **Step 2: Write app theme**

`app/lib/core/theme/app_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
    ),
  );
}
```

- [ ] **Step 3: Write secure storage wrapper**

`app/lib/core/storage/secure_storage.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: 'access_token', value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: 'refresh_token', value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: 'access_token');

  Future<String?> getRefreshToken() =>
      _storage.read(key: 'refresh_token');

  Future<void> clearAll() => _storage.deleteAll();
}
```

- [ ] **Step 4: Write API response model**

`app/lib/core/api/models/api_response.dart`:
```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : null,
      error: json['error'] as String?,
    );
  }
}
```

- [ ] **Step 5: Write API client**

`app/lib/core/api/api_client.dart`:
```dart
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage;

  ApiClient({required SecureStorage storage}) : _storage = storage {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            final retryResponse = await _retry(error.requestOptions);
            handler.resolve(retryResponse);
            return;
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;
      final response = await Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
      )).post('/auth/refresh', data: {'refresh_token': refreshToken});
      final data = response.data['data'];
      await _storage.saveAccessToken(data['access_token']);
      await _storage.saveRefreshToken(data['refresh_token']);
      return true;
    } catch (_) {
      await _storage.clearAll();
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await _storage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) =>
      _dio.delete(path);
}
```

- [ ] **Step 6: Write auth API**

`app/lib/core/api/auth_api.dart`:
```dart
import 'api_client.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await _client.post('/auth/signup', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await _client.post('/auth/verify-email?token=$token');
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _client.post('/auth/forgot-password', data: {
      'email': email,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> deleteAccount(String password) async {
    final response = await _client.delete('/auth/account');
    return response.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.get('/auth/me');
    return response.data;
  }
}
```

- [ ] **Step 7: Write auth guard**

`app/lib/core/router/auth_guard.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

class AuthGuard {
  static Future<String?> redirect(Ref ref, GoRouterState state) async {
    final authState = ref.read(authProvider);
    final isLoggedIn = authState != null;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isLoggedIn && !isAuthRoute) {
      return '/auth/login';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/';
    }
    return null;
  }
}
```

- [ ] **Step 8: Write router**

`app/lib/core/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import 'auth_guard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth/login',
    redirect: (context, state) => AuthGuard.redirect(ref, state),
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/verify-email',
        builder: (_, state) => VerifyEmailScreen(
          email: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
      ),
    ],
  );
});
```

- [ ] **Step 9: Commit**

```powershell
git add app/lib/core/; git commit -m "feat: add Flutter core infrastructure (theme, router, API client)"
```

---

### Task 9: Flutter auth feature (models, providers, screens)

**Files:**
- Create: `app/lib/features/auth/models/auth_state.dart`
- Create: `app/lib/features/auth/providers/auth_provider.dart`
- Create: `app/lib/features/auth/screens/login_screen.dart`
- Create: `app/lib/features/auth/screens/signup_screen.dart`
- Create: `app/lib/features/auth/screens/verify_email_screen.dart`
- Create: `app/lib/features/auth/screens/forgot_password_screen.dart`
- Create: `app/lib/features/home/screens/home_screen.dart`

- [ ] **Step 1: Write auth state model**

`app/lib/features/auth/models/auth_state.dart`:
```dart
class AuthState {
  final String id;
  final String email;
  final String displayName;
  final String? username;
  final String? photoUrl;
  final bool onboardingCompleted;

  AuthState({
    required this.id,
    required this.email,
    required this.displayName,
    this.username,
    this.photoUrl,
    this.onboardingCompleted = false,
  });

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
      username: json['username'] as String?,
      photoUrl: json['photo_url'] as String?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );
  }
}
```

- [ ] **Step 2: Write auth provider (test first)**

`app/lib/features/auth/providers/auth_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_state.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(storage: ref.read(secureStorageProvider));
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(apiClientProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState?>((ref) {
  return AuthNotifier(
    authApi: ref.read(authApiProvider),
    storage: ref.read(secureStorageProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState?> {
  final AuthApi _authApi;
  final SecureStorage _storage;

  AuthNotifier({required AuthApi authApi, required SecureStorage storage})
      : _authApi = authApi,
        _storage = storage,
        super(null);

  Future<void> signup(String email, String password) async {
    await _authApi.signup(email, password);
  }

  Future<void> verifyEmail(String token) async {
    await _authApi.verifyEmail(token);
  }

  Future<bool> login(String email, String password) async {
    final response = await _authApi.login(email, password);
    final data = response['data'] as Map<String, dynamic>;
    await _storage.saveAccessToken(data['access_token'] as String);
    await _storage.saveRefreshToken(data['refresh_token'] as String);
    state = AuthState.fromJson(data['user'] as Map<String, dynamic>);
    return true;
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = null;
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.getAccessToken();
    if (token == null) return false;
    try {
      final response = await _authApi.getMe();
      final data = response['data'] as Map<String, dynamic>;
      state = AuthState.fromJson(data);
      return true;
    } catch (_) {
      await _storage.clearAll();
      return false;
    }
  }
}
```

- [ ] **Step 3: Write auth provider test**

`app/test/features/auth/providers/auth_provider_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// Tests will use mocktail to mock AuthApi and SecureStorage
void main() {
  test('AuthState fromJson parses correctly', () {
    final json = {
      'id': '123',
      'email': 'test@test.com',
      'display_name': 'Test User',
      'username': 'testuser',
      'photo_url': null,
      'onboarding_completed': false,
    };
    final state = AuthState.fromJson(json);
    expect(state.id, '123');
    expect(state.email, 'test@test.com');
    expect(state.displayName, 'Test User');
    expect(state.username, 'testuser');
    expect(state.onboardingCompleted, false);
  });
}
```

- [ ] **Step 4: Write login screen**

`app/lib/features/auth/screens/login_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mealtion',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Food Memory Journal',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.contains('@') == true ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/auth/forgot-password'),
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Log In'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/auth/signup'),
                    child: const Text("Don't have an account? Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Write signup screen**

`app/lib/features/auth/screens/signup_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signup(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        context.push('/auth/verify-email', extra: _emailController.text.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.contains('@') == true ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) => v == _passwordController.text ? null : 'Passwords do not match',
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _signup,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Sign Up'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/auth/login'),
                    child: const Text('Already have an account? Log In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Write verify email screen**

`app/lib/features/auth/screens/verify_email_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).verifyEmail(_tokenController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified! You can now log in.')),
        );
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Check your email',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a verification link to ${widget.email}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Verification Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isLoading ? null : _verify,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Verify Email'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: Write forgot password screen**

`app/lib/features/auth/screens/forgot_password_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      // Forgot Password API call
      final api = ref.read(authApiProvider);
      await api.forgotPassword(_emailController.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_sent) ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading ? null : _sendReset,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send Reset Link'),
              ),
            ] else ...[
              const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text('If that email is registered, a reset link has been sent.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: Write home screen (placeholder)**

`app/lib/features/home/screens/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mealtion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${auth?.displayName ?? "User"}!'),
      ),
    );
  }
}
```

- [ ] **Step 9: Write main.dart**

`app/lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MealtionApp()));
}

class MealtionApp extends ConsumerWidget {
  const MealtionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Mealtion',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 10: Verify Flutter compiles**

```powershell
Set-Location -LiteralPath "..\app"; flutter analyze
```
Expected: No errors or warnings

- [ ] **Step 11: Commit**

```powershell
git add app/lib/main.dart app/lib/features/; git commit -m "feat: add auth screens, provider, and home screen"
```

---

## Phase 1 Acceptance

A user can:
1. Open the app → see login screen
2. Tap "Sign Up" → create account with email + password
3. See verification screen → enter token from server logs
4. Return to login → log in with verified credentials
5. Land on home screen showing "Welcome, {name}!"
6. Tap logout → return to login screen
7. Tap "Forgot Password" → enter email → see confirmation
