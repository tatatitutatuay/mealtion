-- Notification triggers: auto-insert into notifications when likes, comments, or friend requests happen

-- ============================================================
-- 1. LIKE trigger
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_like_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Don't notify if you like your own meal
  IF NEW.user_id = (SELECT user_id FROM public.meals WHERE id = NEW.meal_id) THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (user_id, type, actor_id, meal_id)
  SELECT m.user_id, 'like', NEW.user_id, NEW.meal_id
  FROM public.meals m
  WHERE m.id = NEW.meal_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_like_notification ON public.likes;
CREATE TRIGGER trg_like_notification
  AFTER INSERT ON public.likes
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_like_notification();

-- ============================================================
-- 2. COMMENT trigger
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_comment_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Don't notify if you comment on your own meal
  IF NEW.user_id = (SELECT user_id FROM public.meals WHERE id = NEW.meal_id) THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (user_id, type, actor_id, meal_id)
  SELECT m.user_id, 'comment', NEW.user_id, NEW.meal_id
  FROM public.meals m
  WHERE m.id = NEW.meal_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_comment_notification ON public.comments;
CREATE TRIGGER trg_comment_notification
  AFTER INSERT ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_comment_notification();

-- ============================================================
-- 3. FRIEND REQUEST trigger (status = pending)
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_friend_request_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Only notify on new pending requests
  IF NEW.status != 'pending' THEN
    RETURN NEW;
  END IF;

  -- Don't notify yourself
  IF NEW.action_user_id = NEW.friend_user_id THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (user_id, type, actor_id)
  VALUES (NEW.friend_user_id, 'friend_request', NEW.action_user_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_friend_request_notification ON public.friends;
CREATE TRIGGER trg_friend_request_notification
  AFTER INSERT ON public.friends
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_friend_request_notification();

-- ============================================================
-- 4. FRIEND ACCEPTED trigger (status changes to active)
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_friend_accepted_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Only when status changes to active
  IF NEW.status != 'active' OR OLD.status = 'active' THEN
    RETURN NEW;
  END IF;

  -- Don't notify yourself
  IF NEW.user_id = NEW.friend_user_id THEN
    RETURN NEW;
  END IF;

  -- Notify the person who originally sent the request (user_id)
  -- Actor is the person who accepted (friend_user_id)
  INSERT INTO public.notifications (user_id, type, actor_id)
  VALUES (NEW.user_id, 'friend_accepted', NEW.friend_user_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_friend_accepted_notification ON public.friends;
CREATE TRIGGER trg_friend_accepted_notification
  AFTER UPDATE ON public.friends
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_friend_accepted_notification();

-- ============================================================
-- 5. RLS policy for inserting notifications (triggers run as SECURITY DEFINER,
--    but app-side inserts need a policy too)
-- ============================================================
DROP POLICY IF EXISTS "notifications_insert_own" ON public.notifications;
CREATE POLICY "notifications_insert_own"
  ON public.notifications
  FOR INSERT
  WITH CHECK (auth.uid() = actor_id OR auth.uid() = user_id);

-- ============================================================
-- 6. Enable realtime for notifications table (for live badge updates)
-- ============================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime DROP TABLE public.notifications;
  END IF;
END $$;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
