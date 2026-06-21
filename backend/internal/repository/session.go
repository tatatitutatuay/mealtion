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
