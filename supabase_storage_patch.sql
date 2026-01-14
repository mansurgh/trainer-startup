-- ============================================
-- PulseFit Pro - Storage & Profile Patch
-- Run this in Supabase SQL Editor to fix:
-- - Avatar/Photo upload issues
-- - Missing profile columns
-- - Progress photos table (if missing)
-- ============================================

-- ============================================
-- 1. CREATE STORAGE BUCKETS (Fixes Avatar/Photo Upload)
-- ============================================
insert into storage.buckets (id, name, public)
values 
  ('avatars', 'avatars', true), 
  ('progress_photos', 'progress_photos', true)
on conflict (id) do nothing;

-- ============================================
-- 2. STORAGE POLICIES - Allow Public Access to Images
-- ============================================

-- Drop existing policies if they exist (to avoid conflicts)
drop policy if exists "Public Access Avatars" on storage.objects;
drop policy if exists "User Upload Avatars" on storage.objects;
drop policy if exists "User Update Avatars" on storage.objects;
drop policy if exists "User Delete Avatars" on storage.objects;
drop policy if exists "Public Access Photos" on storage.objects;
drop policy if exists "User Upload Photos" on storage.objects;
drop policy if exists "User Update Photos" on storage.objects;
drop policy if exists "User Delete Photos" on storage.objects;

-- Avatars bucket policies
create policy "Public Access Avatars" 
  on storage.objects for select 
  using (bucket_id = 'avatars');

create policy "User Upload Avatars" 
  on storage.objects for insert 
  with check (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

create policy "User Update Avatars" 
  on storage.objects for update 
  using (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

create policy "User Delete Avatars" 
  on storage.objects for delete 
  using (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Progress photos bucket policies
create policy "Public Access Photos" 
  on storage.objects for select 
  using (bucket_id = 'progress_photos');

create policy "User Upload Photos" 
  on storage.objects for insert 
  with check (bucket_id = 'progress_photos' AND auth.uid()::text = (storage.foldername(name))[1]);

create policy "User Update Photos" 
  on storage.objects for update 
  using (bucket_id = 'progress_photos' AND auth.uid()::text = (storage.foldername(name))[1]);

create policy "User Delete Photos" 
  on storage.objects for delete 
  using (bucket_id = 'progress_photos' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ============================================
-- 3. FIX MISSING PROFILE COLUMNS (Fixes Profile Save Error)
-- ============================================
alter table public.profiles 
  add column if not exists target_weight float,
  add column if not exists target_calories int,
  add column if not exists activity_level text,
  add column if not exists experience_level text;

-- Add constraint for activity_level if column was just created
do $$
begin
  if not exists (
    select 1 from information_schema.check_constraints 
    where constraint_name = 'profiles_activity_level_check'
  ) then
    alter table public.profiles 
      add constraint profiles_activity_level_check 
      check (activity_level in ('sedentary', 'light', 'moderate', 'active', 'very_active'));
  end if;
exception when others then
  null; -- Ignore if constraint already exists
end $$;

-- Add constraint for experience_level if column was just created
do $$
begin
  if not exists (
    select 1 from information_schema.check_constraints 
    where constraint_name = 'profiles_experience_level_check'
  ) then
    alter table public.profiles 
      add constraint profiles_experience_level_check 
      check (experience_level in ('beginner', 'intermediate', 'advanced'));
  end if;
exception when others then
  null; -- Ignore if constraint already exists
end $$;

-- ============================================
-- 4. CREATE PROGRESS PHOTOS TABLE (if not exists)
-- ============================================
create table if not exists public.progress_photos (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  photo_path text not null,
  photo_url text, -- Full public URL for convenience
  date date default current_date,
  weight float,
  body_fat_percentage float,
  notes text,
  created_at timestamptz default now()
);

-- ============================================
-- 5. ENABLE RLS FOR PHOTOS
-- ============================================
alter table public.progress_photos enable row level security;

-- Drop existing policies if they exist
drop policy if exists "Users can see own photos" on public.progress_photos;
drop policy if exists "Users can upload photos" on public.progress_photos;
drop policy if exists "Users can update photos" on public.progress_photos;
drop policy if exists "Users can delete photos" on public.progress_photos;

-- Create policies
create policy "Users can see own photos" 
  on public.progress_photos for select 
  using (auth.uid() = user_id);

create policy "Users can upload photos" 
  on public.progress_photos for insert 
  with check (auth.uid() = user_id);

create policy "Users can update photos" 
  on public.progress_photos for update 
  using (auth.uid() = user_id);

create policy "Users can delete photos" 
  on public.progress_photos for delete 
  using (auth.uid() = user_id);

-- Index for performance
create index if not exists progress_photos_user_date_idx 
  on public.progress_photos(user_id, date desc);

-- ============================================
-- 6. VERIFY SETUP (Run this to check)
-- ============================================
-- select * from storage.buckets where id in ('avatars', 'progress_photos');
-- select column_name from information_schema.columns where table_name = 'profiles';
-- select * from public.progress_photos limit 1;
