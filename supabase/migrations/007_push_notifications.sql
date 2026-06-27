-- ============================================================
-- 1. Device tokens table for push notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS public.device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    platform VARCHAR(10) NOT NULL DEFAULT 'android',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, token)
);

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "device_tokens_select_own" ON public.device_tokens;
CREATE POLICY "device_tokens_select_own"
  ON public.device_tokens FOR SELECT TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "device_tokens_insert_own" ON public.device_tokens;
CREATE POLICY "device_tokens_insert_own"
  ON public.device_tokens FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "device_tokens_delete_own" ON public.device_tokens;
CREATE POLICY "device_tokens_delete_own"
  ON public.device_tokens FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- ============================================================
-- 2. Update trigger functions to respect notification prefs
-- ============================================================

-- LIKE trigger: check notif_likes
CREATE OR REPLACE FUNCTION public.handle_like_notification()
RETURNS TRIGGER AS $$
DECLARE
  meal_owner UUID;
  owner_notif_pref BOOLEAN;
BEGIN
  SELECT user_id INTO meal_owner FROM public.meals WHERE id = NEW.meal_id;

  -- Don't notify if you like your own meal
  IF NEW.user_id = meal_owner THEN
    RETURN NEW;
  END IF;

  -- Check notification preference
  SELECT notif_likes INTO owner_notif_pref FROM public.profiles WHERE id = meal_owner;
  IF owner_notif_pref = false THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (user_id, type, actor_id, meal_id)
  VALUES (meal_owner, 'like', NEW.user_id, NEW.meal_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- COMMENT trigger: check notif_comments
CREATE OR REPLACE FUNCTION public.handle_comment_notification()
RETURNS TRIGGER AS $$
DECLARE
  meal_owner UUID;
  owner_notif_pref BOOLEAN;
BEGIN
  SELECT user_id INTO meal_owner FROM public.meals WHERE id = NEW.meal_id;

  -- Don't notify if you comment on your own meal
  IF NEW.user_id = meal_owner THEN
    RETURN NEW;
  END IF;

  -- Check notification preference
  SELECT notif_comments INTO owner_notif_pref FROM public.profiles WHERE id = meal_owner;
  IF owner_notif_pref = false THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (user_id, type, actor_id, meal_id)
  VALUES (meal_owner, 'comment', NEW.user_id, NEW.meal_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FRIEND REQUEST trigger: check notif_friend_requests
CREATE OR REPLACE FUNCTION public.handle_friend_request_notification()
RETURNS TRIGGER AS $$
DECLARE
  recipient_notif_pref BOOLEAN;
BEGIN
  -- Only notify on new pending requests
  IF NEW.status != 'pending' THEN
    RETURN NEW;
  END IF;

  -- Don't notify yourself
  IF NEW.action_user_id = NEW.friend_user_id THEN
    RETURN NEW;
  END IF;

  -- Check notification preference
  SELECT notif_friend_requests INTO recipient_notif_pref FROM public.profiles WHERE id = NEW.friend_user_id;
  IF recipient_notif_pref = false THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (user_id, type, actor_id)
  VALUES (NEW.friend_user_id, 'friend_request', NEW.action_user_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FRIEND ACCEPTED trigger: check notif_friend_requests
CREATE OR REPLACE FUNCTION public.handle_friend_accepted_notification()
RETURNS TRIGGER AS $$
DECLARE
  recipient_notif_pref BOOLEAN;
BEGIN
  -- Only when status changes to active
  IF NEW.status != 'active' OR OLD.status = 'active' THEN
    RETURN NEW;
  END IF;

  -- Don't notify yourself
  IF NEW.user_id = NEW.friend_user_id THEN
    RETURN NEW;
  END IF;

  -- Check notification preference
  SELECT notif_friend_requests INTO recipient_notif_pref FROM public.profiles WHERE id = NEW.user_id;
  IF recipient_notif_pref = false THEN
    RETURN NEW;
  END IF;

  -- Notify the person who originally sent the request (user_id)
  -- Actor is the person who accepted (friend_user_id)
  INSERT INTO public.notifications (user_id, type, actor_id)
  VALUES (NEW.user_id, 'friend_accepted', NEW.friend_user_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 3. Trigger to call push notification edge function on insert
-- ============================================================
-- After a notification is inserted, call the edge function to send push
-- This uses pg_net extension (available in Supabase by default)
CREATE OR REPLACE FUNCTION public.handle_push_notification()
RETURNS TRIGGER AS $$
DECLARE
  actor_name TEXT;
  notif_label TEXT;
  payload JSONB;
  push_url TEXT;
  push_secret TEXT;
BEGIN
  -- Get actor display name
  SELECT display_name INTO actor_name FROM public.profiles WHERE id = NEW.actor_id;

  -- Build notification label
  notif_label := CASE NEW.type
    WHEN 'friend_request' THEN 'sent you a friend request'
    WHEN 'friend_accepted' THEN 'accepted your friend request'
    WHEN 'like' THEN 'liked your meal'
    WHEN 'comment' THEN 'commented on your meal'
    ELSE 'interacted with you'
  END;

  payload := jsonb_build_object(
    'user_id', NEW.user_id,
    'title', COALESCE(actor_name, 'Someone'),
    'body', notif_label,
    'meal_id', NEW.meal_id,
    'type', NEW.type
  );

  -- Read push config from app_settings table
  SELECT value INTO push_url FROM public.app_settings WHERE key = 'fcm_push_url';
  SELECT value INTO push_secret FROM public.app_settings WHERE key = 'fcm_push_secret';

  IF push_url IS NULL OR push_secret IS NULL THEN
    RETURN NEW;
  END IF;

  -- Call edge function asynchronously (fire-and-forget)
  PERFORM net.http_post(
    url := push_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || push_secret
    ),
    body := payload
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_push_notification ON public.notifications;
CREATE TRIGGER trg_push_notification
  AFTER INSERT ON public.notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_push_notification();

-- ============================================================
-- 4. App settings table for push notification config
--    (Supabase doesn't allow custom GUCs, so we use a regular table)
--    Run these manually in SQL Editor with your actual values:
-- ============================================================
CREATE TABLE IF NOT EXISTS public.app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- Insert push config (replace values with your actual ones):
-- INSERT INTO public.app_settings (key, value) VALUES
--   ('fcm_push_url', 'https://ssiaxokyvoqxroaavurx.functions.supabase.co/push-notification'),
--   ('fcm_push_secret', '<same-random-string-as-FCM_PUSH_SECRET>')
-- ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
