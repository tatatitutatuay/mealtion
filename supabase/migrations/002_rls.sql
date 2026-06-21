-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmark_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmark_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Helper: check if two users are friends
CREATE OR REPLACE FUNCTION public.are_friends(user_a UUID, user_b UUID)
RETURNS BOOLEAN LANGUAGE SQL SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.friends
    WHERE status = 'active'
    AND ((user_id = user_a AND friend_user_id = user_b)
      OR (user_id = user_b AND friend_user_id = user_a))
  );
$$;

-- Profiles: read own, update own, insert via trigger
CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Restaurants: owner only
CREATE POLICY "restaurants_select_own" ON public.restaurants
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "restaurants_insert_own" ON public.restaurants
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Meals: owner sees all, friends see non-private
CREATE POLICY "meals_select_own" ON public.meals
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "meals_select_friends" ON public.meals
  FOR SELECT USING (
    is_private = FALSE
    AND public.are_friends(auth.uid(), user_id)
  );

CREATE POLICY "meals_insert_own" ON public.meals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "meals_update_own" ON public.meals
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "meals_delete_own" ON public.meals
  FOR DELETE USING (auth.uid() = user_id);

-- Meal foods/photos/tags cascade from meals
CREATE POLICY "meal_foods_select" ON public.meal_foods
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND (user_id = auth.uid() OR (is_private = FALSE AND public.are_friends(auth.uid(), user_id))))
  );

CREATE POLICY "meal_photos_select" ON public.meal_photos
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND (user_id = auth.uid() OR (is_private = FALSE AND public.are_friends(auth.uid(), user_id))))
  );

-- Friends: involved users only
CREATE POLICY "friends_select" ON public.friends
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() = friend_user_id);

CREATE POLICY "friends_insert" ON public.friends
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.uid() = action_user_id);

CREATE POLICY "friends_update" ON public.friends
  FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = friend_user_id);

-- Likes: select if meal accessible, insert own
CREATE POLICY "likes_select" ON public.likes
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND (user_id = auth.uid() OR (is_private = FALSE AND public.are_friends(auth.uid(), user_id))))
  );

CREATE POLICY "likes_insert" ON public.likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "likes_delete" ON public.likes
  FOR DELETE USING (auth.uid() = user_id);

-- Comments: read accessible, insert own, delete own or meal owner
CREATE POLICY "comments_select" ON public.comments
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND (user_id = auth.uid() OR (is_private = FALSE AND public.are_friends(auth.uid(), user_id))))
  );

CREATE POLICY "comments_insert" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "comments_delete_own" ON public.comments
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "comments_delete_meal_owner" ON public.comments
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND user_id = auth.uid())
  );

-- Bookmarks: own only
CREATE POLICY "bookmark_collections_select" ON public.bookmark_collections
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "bookmark_collections_insert" ON public.bookmark_collections
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "bookmark_collections_update" ON public.bookmark_collections
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "bookmark_collections_delete" ON public.bookmark_collections
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "bookmark_items_select" ON public.bookmark_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "bookmark_items_insert" ON public.bookmark_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "bookmark_items_delete" ON public.bookmark_items
  FOR DELETE USING (auth.uid() = user_id);

-- Notifications: own only
CREATE POLICY "notifications_select" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "notifications_update" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Storage bucket RLS (executed in Supabase dashboard or via SQL)
-- INSERT: only meal owner can upload
-- SELECT: meal owner or friend can view
