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
