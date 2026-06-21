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
