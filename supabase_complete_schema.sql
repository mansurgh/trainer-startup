-- PulseFit Pro Database Schema for Supabase
-- Run this in Supabase SQL Editor

-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- ============================================
-- 1. USERS TABLE (extends auth.users)
-- ============================================
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text unique not null,
  name text,
  age integer,
  height integer, -- in cm
  weight numeric(5,2), -- in kg
  gender text check (gender in ('male', 'female', 'other')),
  goal text, -- 'lose_weight', 'gain_muscle', 'maintain', 'get_fit'
  avatar_url text,
  
  -- Subscription fields
  is_premium boolean default false,
  trial_end_date timestamptz,
  subscription_start_date timestamptz,
  subscription_end_date timestamptz,
  subscription_status text check (subscription_status in ('trial', 'active', 'expired', 'cancelled')),
  
  -- Settings
  language text default 'en',
  theme text default 'dark',
  units text default 'metric', -- 'metric' or 'imperial'
  notifications_enabled boolean default true,
  
  -- Metadata
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS
alter table public.profiles enable row level security;

-- Policies for profiles
create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- ============================================
-- 2. WORKOUT SESSIONS TABLE
-- ============================================
create table public.workout_sessions (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  
  -- Workout details
  workout_date date not null,
  day_of_week text, -- 'monday', 'tuesday', etc.
  duration_minutes integer,
  calories_burned integer,
  exercises_completed integer,
  total_exercises integer,
  
  -- Status
  status text check (status in ('completed', 'in_progress', 'skipped')) default 'in_progress',
  
  -- Metadata
  created_at timestamptz default now(),
  completed_at timestamptz
);

-- Enable RLS
alter table public.workout_sessions enable row level security;

-- Policies
create policy "Users can view own sessions"
  on public.workout_sessions for select
  using (auth.uid() = user_id);

create policy "Users can insert own sessions"
  on public.workout_sessions for insert
  with check (auth.uid() = user_id);

create policy "Users can update own sessions"
  on public.workout_sessions for update
  using (auth.uid() = user_id);

-- ============================================
-- 3. EXERCISE LOGS TABLE
-- ============================================
create table public.exercise_logs (
  id uuid default uuid_generate_v4() primary key,
  session_id uuid references public.workout_sessions(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  
  -- Exercise details
  exercise_name text not null,
  muscle_group text,
  sets integer,
  reps integer,
  weight numeric(6,2), -- in kg or lbs
  duration_seconds integer,
  
  -- Metadata
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.exercise_logs enable row level security;

-- Policies
create policy "Users can view own exercise logs"
  on public.exercise_logs for select
  using (auth.uid() = user_id);

create policy "Users can insert own exercise logs"
  on public.exercise_logs for insert
  with check (auth.uid() = user_id);

-- ============================================
-- 4. NUTRITION LOGS TABLE
-- ============================================
create table public.nutrition_logs (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  
  -- Meal details
  meal_date date not null,
  meal_type text check (meal_type in ('breakfast', 'lunch', 'dinner', 'snack')),
  dish_name text not null,
  
  -- Nutrition data
  calories integer,
  protein numeric(6,2),
  fat numeric(6,2),
  carbs numeric(6,2),
  
  -- Status
  is_completed boolean default false,
  
  -- Metadata
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.nutrition_logs enable row level security;

-- Policies
create policy "Users can view own nutrition logs"
  on public.nutrition_logs for select
  using (auth.uid() = user_id);

create policy "Users can insert own nutrition logs"
  on public.nutrition_logs for insert
  with check (auth.uid() = user_id);

create policy "Users can update own nutrition logs"
  on public.nutrition_logs for update
  using (auth.uid() = user_id);

create policy "Users can delete own nutrition logs"
  on public.nutrition_logs for delete
  using (auth.uid() = user_id);

-- ============================================
-- 5. BODY MEASUREMENTS TABLE
-- ============================================
create table public.body_measurements (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  
  -- Measurement data
  measurement_date date not null,
  weight numeric(5,2),
  body_fat_percentage numeric(4,2),
  muscle_mass numeric(5,2),
  
  -- Body parts (all in cm)
  chest numeric(5,2),
  waist numeric(5,2),
  hips numeric(5,2),
  bicep_left numeric(4,2),
  bicep_right numeric(4,2),
  thigh_left numeric(5,2),
  thigh_right numeric(5,2),
  
  -- Metadata
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.body_measurements enable row level security;

-- Policies
create policy "Users can view own measurements"
  on public.body_measurements for select
  using (auth.uid() = user_id);

create policy "Users can insert own measurements"
  on public.body_measurements for insert
  with check (auth.uid() = user_id);

-- ============================================
-- 6. CHAT MESSAGES TABLE (AI Chat History)
-- ============================================
create table public.chat_messages (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  
  -- Message data
  role text check (role in ('user', 'assistant')) not null,
  content text not null,
  image_path text, -- for user-uploaded images
  
  -- Metadata
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.chat_messages enable row level security;

-- Policies
create policy "Users can view own chat history"
  on public.chat_messages for select
  using (auth.uid() = user_id);

create policy "Users can insert own messages"
  on public.chat_messages for insert
  with check (auth.uid() = user_id);

-- ============================================
-- 7. TRIGGERS FOR UPDATED_AT
-- ============================================
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger handle_profiles_updated_at
  before update on public.profiles
  for each row
  execute function public.handle_updated_at();

-- ============================================
-- 8. FUNCTION TO CREATE PROFILE ON SIGNUP
-- ============================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, subscription_status, trial_end_date)
  values (
    new.id,
    new.email,
    'trial',
    now() + interval '7 days' -- Default 7-day trial
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to create profile automatically
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================
-- 9. INDEXES FOR PERFORMANCE
-- ============================================
create index workout_sessions_user_date_idx on public.workout_sessions(user_id, workout_date desc);
create index exercise_logs_session_idx on public.exercise_logs(session_id);
create index nutrition_logs_user_date_idx on public.nutrition_logs(user_id, meal_date desc);
create index body_measurements_user_date_idx on public.body_measurements(user_id, measurement_date desc);
create index chat_messages_user_created_idx on public.chat_messages(user_id, created_at desc);

-- ============================================
-- 10. PROGRESS PHOTOS TABLE
-- ============================================
create table public.progress_photos (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  
  -- Photo data
  photo_url text not null,
  note text,
  weight numeric(5,2), -- optional weight at time of photo
  
  -- Metadata
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.progress_photos enable row level security;

-- Policies
create policy "Users can view own progress photos"
  on public.progress_photos for select
  using (auth.uid() = user_id);

create policy "Users can insert own progress photos"
  on public.progress_photos for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own progress photos"
  on public.progress_photos for delete
  using (auth.uid() = user_id);

-- Index for performance
create index progress_photos_user_date_idx on public.progress_photos(user_id, created_at desc);

-- ============================================
-- 11. VIEWS FOR COMMON QUERIES (SECURITY HARDENED)
-- ============================================
-- IMPORTANT: All views use security_invoker = true to enforce RLS
-- This ensures users can only see their own aggregated data

-- Daily workout stats
create or replace view public.daily_workout_stats 
with (security_invoker = true) 
as
select
  user_id,
  workout_date,
  count(*) as sessions_count,
  sum(duration_minutes) as total_duration,
  sum(calories_burned) as total_calories,
  sum(exercises_completed) as total_exercises
from public.workout_sessions
where status = 'completed'
group by user_id, workout_date;

-- Weekly workout summary
create or replace view public.weekly_workout_summary 
with (security_invoker = true) 
as
select
  user_id,
  date_trunc('week', workout_date) as week_start,
  count(*) as workouts_completed,
  sum(duration_minutes) as total_minutes,
  sum(calories_burned) as total_calories
from public.workout_sessions
where status = 'completed'
group by user_id, week_start;

-- Daily nutrition totals
create or replace view public.daily_nutrition_totals 
with (security_invoker = true) 
as
select
  user_id,
  meal_date,
  sum(calories) as total_calories,
  sum(protein) as total_protein,
  sum(fat) as total_fat,
  sum(carbs) as total_carbs,
  count(*) filter (where is_completed = true) as completed_meals,
  count(*) as total_meals
from public.nutrition_logs
group by user_id, meal_date;
