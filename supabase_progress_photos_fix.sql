-- ============================================================================
-- PROGRESS PHOTOS TABLE FIX
-- Run this in Supabase SQL Editor to create/fix the progress_photos table
-- ============================================================================

-- Drop existing table if it exists (CAUTION: will lose data)
DROP TABLE IF EXISTS public.progress_photos CASCADE;

-- Create progress_photos table
CREATE TABLE public.progress_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  note TEXT,
  weight DECIMAL(5,1), -- User weight at time of photo
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create index on user_id for faster queries
CREATE INDEX idx_progress_photos_user_id ON public.progress_photos(user_id);
CREATE INDEX idx_progress_photos_created_at ON public.progress_photos(created_at DESC);

-- Enable RLS
ALTER TABLE public.progress_photos ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own progress photos"
  ON public.progress_photos
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress photos"
  ON public.progress_photos
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress photos"
  ON public.progress_photos
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own progress photos"
  ON public.progress_photos
  FOR DELETE
  USING (auth.uid() = user_id);

-- Update trigger
CREATE OR REPLACE FUNCTION public.handle_progress_photos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_progress_photos_updated_at
  BEFORE UPDATE ON public.progress_photos
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_progress_photos_updated_at();

-- Grant permissions
GRANT ALL ON public.progress_photos TO authenticated;
GRANT ALL ON public.progress_photos TO service_role;

-- Create storage bucket for progress photos if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('progress_photos', 'progress_photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "Users can upload own progress photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'progress_photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view own progress photos"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'progress_photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own progress photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'progress_photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
