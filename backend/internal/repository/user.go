package repository

import (
	"context"

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
