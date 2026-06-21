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
