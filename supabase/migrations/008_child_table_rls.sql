-- Add UPDATE and DELETE policies for restaurants, branches, meal_foods, meal_photos, meal_tags
-- Also re-add meal_tags SELECT policy (was missing from DB despite being in 002_rls.sql)
-- These are needed for meal editing (insert + update + delete on child tables)

-- Meal tags: re-add SELECT policy (was missing, causing tags to not display)
DROP POLICY IF EXISTS "meal_tags_select" ON public.meal_tags;
CREATE POLICY "meal_tags_select" ON public.meal_tags
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND (user_id = auth.uid() OR (is_private = FALSE AND public.are_friends(auth.uid(), user_id))))
  );

-- Restaurants: update by owner
CREATE POLICY "restaurants_update_own" ON public.restaurants
  FOR UPDATE USING (auth.uid() = user_id);

-- Branches: update by owner
CREATE POLICY "branches_update_own" ON public.branches
  FOR UPDATE USING (auth.uid() = user_id);

-- Meal foods: update + delete by meal owner
CREATE POLICY "meal_foods_update" ON public.meal_foods
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND user_id = auth.uid())
  );

CREATE POLICY "meal_foods_delete" ON public.meal_foods
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND user_id = auth.uid())
  );

-- Meal photos: update + delete by meal owner
CREATE POLICY "meal_photos_update" ON public.meal_photos
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND user_id = auth.uid())
  );

CREATE POLICY "meal_photos_delete" ON public.meal_photos
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND user_id = auth.uid())
  );

-- Meal tags: update + delete by meal owner
CREATE POLICY "meal_tags_update" ON public.meal_tags
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND user_id = auth.uid())
  );

CREATE POLICY "meal_tags_delete" ON public.meal_tags
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.meals WHERE id = meal_id AND user_id = auth.uid())
  );
