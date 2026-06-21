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
