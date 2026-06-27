-- Add notification preference columns to profiles
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS notif_likes BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS notif_comments BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS notif_friend_requests BOOLEAN DEFAULT TRUE;
