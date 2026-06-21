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

func (s *AuthService) GetUser(ctx context.Context, userID string) (*model.User, error) {
	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return nil, ErrUserNotFound
	}
	return &user, nil
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
