-- Add cover_url column to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS cover_url TEXT DEFAULT '';

-- Covers bucket (public, owner-only upload/delete)
INSERT INTO storage.buckets (id, name, public)
VALUES ('covers', 'covers', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "covers_upload_own" ON storage.objects;
CREATE POLICY "covers_upload_own" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'covers' AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "covers_read" ON storage.objects;
CREATE POLICY "covers_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'covers');

DROP POLICY IF EXISTS "covers_delete_own" ON storage.objects;
CREATE POLICY "covers_delete_own" ON storage.objects
  FOR DELETE TO authenticated USING (
    bucket_id = 'covers' AND (storage.foldername(name))[1] = auth.uid()::text
  );
