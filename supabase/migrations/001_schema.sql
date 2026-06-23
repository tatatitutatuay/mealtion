-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Profiles table (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name VARCHAR(30) NOT NULL DEFAULT '',
    username VARCHAR(20) UNIQUE,
    bio VARCHAR(150) DEFAULT '',
    photo_url TEXT DEFAULT '',
    primary_currency VARCHAR(3) DEFAULT 'USD',
    price_threshold_low NUMERIC(12,2) DEFAULT 10.00,
    price_threshold_high NUMERIC(12,2) DEFAULT 50.00,
    price_display_privacy VARCHAR(10) DEFAULT 'actual',
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Restaurants
CREATE TABLE public.restaurants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, name)
);

-- Branches
CREATE TABLE public.branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(restaurant_id, user_id, name)
);

-- Meals
CREATE TABLE public.meals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    time TIME NOT NULL,
    source VARCHAR(20) NOT NULL CHECK (source IN ('restaurant', 'delivery', 'home')),
    restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE SET NULL,
    branch_id UUID REFERENCES public.branches(id) ON DELETE SET NULL,
    is_private BOOLEAN DEFAULT FALSE,
    is_draft BOOLEAN DEFAULT FALSE,
    price_amount NUMERIC(12,2),
    price_currency VARCHAR(3),
    heaviness VARCHAR(20) CHECK (heaviness IN ('light', 'satisfying', 'heavy')),
    feeling VARCHAR(20) CHECK (feeling IN ('like', 'neutral', 'dislike')),
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Meal Foods
CREATE TABLE public.meal_foods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_id UUID NOT NULL REFERENCES public.meals(id) ON DELETE CASCADE,
    food_name TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    UNIQUE(meal_id, food_name)
);

-- Meal Photos
CREATE TABLE public.meal_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_id UUID NOT NULL REFERENCES public.meals(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

-- Meal Tags
CREATE TABLE public.meal_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_id UUID NOT NULL REFERENCES public.meals(id) ON DELETE CASCADE,
    tag_name TEXT NOT NULL,
    UNIQUE(meal_id, tag_name)
);

-- Friends
CREATE TYPE friend_status AS ENUM ('pending', 'active');

CREATE TABLE public.friends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    friend_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status friend_status NOT NULL DEFAULT 'pending',
    action_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, friend_user_id)
);

-- Likes
CREATE TABLE public.likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    meal_id UUID NOT NULL REFERENCES public.meals(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, meal_id)
);

-- Comments
CREATE TABLE public.comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    meal_id UUID NOT NULL REFERENCES public.meals(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bookmark Collections
CREATE TABLE public.bookmark_collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    cover_type VARCHAR(10) DEFAULT 'default',
    cover_key TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bookmark Items
CREATE TABLE public.bookmark_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID NOT NULL REFERENCES public.bookmark_collections(id) ON DELETE CASCADE,
    meal_id UUID NOT NULL REFERENCES public.meals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(collection_id, meal_id)
);

-- Notifications
CREATE TYPE notification_type AS ENUM ('friend_request', 'friend_accepted', 'like', 'comment');

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    meal_id UUID REFERENCES public.meals(id) ON DELETE SET NULL,
    group_count INT DEFAULT 1,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_meals_user_id ON public.meals(user_id);
CREATE INDEX idx_meals_date ON public.meals(date);
CREATE INDEX idx_meal_photos_meal_id ON public.meal_photos(meal_id);
CREATE INDEX idx_friends_user_id ON public.friends(user_id);
CREATE INDEX idx_friends_status ON public.friends(status);
CREATE INDEX idx_likes_meal_id ON public.likes(meal_id);
CREATE INDEX idx_comments_meal_id ON public.comments(meal_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);

-- Storage bucket for meal photos (public, RLS controls upload/delete)
INSERT INTO storage.buckets (id, name, public) VALUES ('meal-photos', 'meal-photos', true);
