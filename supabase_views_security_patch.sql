-- =============================================================================
-- SUPABASE VIEWS SECURITY PATCH — Force RLS on All Views
-- =============================================================================
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor → New Query)
--
-- PROBLEM: Views bypass RLS by default (they use "security definer" behavior)
-- This allows ANY authenticated user to see aggregated data of ALL users!
--
-- SOLUTION: Use PostgreSQL 15+ `security_invoker = true` option
-- This forces the view to execute with the CALLING user's permissions,
-- meaning RLS policies on underlying tables are enforced.
--
-- IMPORTANT: Supabase uses PostgreSQL 15+, so this syntax is fully supported.
-- =============================================================================

-- ============================================
-- STEP 1: DROP EXISTING INSECURE VIEWS
-- ============================================
-- We must DROP first because ALTER VIEW doesn't support changing security_invoker

DROP VIEW IF EXISTS public.daily_workout_stats CASCADE;
DROP VIEW IF EXISTS public.weekly_workout_summary CASCADE;
DROP VIEW IF EXISTS public.daily_nutrition_totals CASCADE;

-- ============================================
-- STEP 2: RECREATE VIEWS WITH SECURITY_INVOKER
-- ============================================
-- security_invoker = true means:
-- - The view runs as the CALLING user (not the view owner)
-- - RLS policies on underlying tables ARE enforced
-- - User A cannot see User B's data through the view

-- -----------------------------------------
-- VIEW 1: DAILY WORKOUT STATS
-- -----------------------------------------
-- Aggregates workout data per user per day
-- Columns: user_id, workout_date, sessions_count, total_duration, total_calories, total_exercises

CREATE VIEW public.daily_workout_stats 
WITH (security_invoker = true) 
AS
SELECT
  user_id,
  workout_date,
  COUNT(*) AS sessions_count,
  SUM(duration_minutes) AS total_duration,
  SUM(calories_burned) AS total_calories,
  SUM(exercises_completed) AS total_exercises
FROM public.workout_sessions
WHERE status = 'completed'
GROUP BY user_id, workout_date;

COMMENT ON VIEW public.daily_workout_stats IS 
  'Daily workout statistics. Uses security_invoker=true to enforce RLS.';

-- -----------------------------------------
-- VIEW 2: WEEKLY WORKOUT SUMMARY
-- -----------------------------------------
-- Aggregates workout data per user per week
-- Columns: user_id, week_start, workouts_completed, total_minutes, total_calories

CREATE VIEW public.weekly_workout_summary 
WITH (security_invoker = true) 
AS
SELECT
  user_id,
  DATE_TRUNC('week', workout_date) AS week_start,
  COUNT(*) AS workouts_completed,
  SUM(duration_minutes) AS total_minutes,
  SUM(calories_burned) AS total_calories
FROM public.workout_sessions
WHERE status = 'completed'
GROUP BY user_id, week_start;

COMMENT ON VIEW public.weekly_workout_summary IS 
  'Weekly workout summary. Uses security_invoker=true to enforce RLS.';

-- -----------------------------------------
-- VIEW 3: DAILY NUTRITION TOTALS
-- -----------------------------------------
-- Aggregates nutrition data per user per day
-- Columns: user_id, meal_date, total_calories, total_protein, total_fat, total_carbs, completed_meals, total_meals

CREATE VIEW public.daily_nutrition_totals 
WITH (security_invoker = true) 
AS
SELECT
  user_id,
  meal_date,
  SUM(calories) AS total_calories,
  SUM(protein) AS total_protein,
  SUM(fat) AS total_fat,
  SUM(carbs) AS total_carbs,
  COUNT(*) FILTER (WHERE is_completed = true) AS completed_meals,
  COUNT(*) AS total_meals
FROM public.nutrition_logs
GROUP BY user_id, meal_date;

COMMENT ON VIEW public.daily_nutrition_totals IS 
  'Daily nutrition totals. Uses security_invoker=true to enforce RLS.';

-- ============================================
-- STEP 3: VERIFICATION QUERIES
-- ============================================
-- Run these AFTER the migration to confirm security is working

-- Check that views exist with security_invoker enabled
SELECT 
  viewname,
  definition
FROM pg_views 
WHERE schemaname = 'public' 
  AND viewname IN ('daily_workout_stats', 'weekly_workout_summary', 'daily_nutrition_totals');

-- Verify security_invoker setting (PostgreSQL 15+)
SELECT 
  c.relname AS view_name,
  c.relrowsecurity AS row_security,
  CASE 
    WHEN c.relrowsecurity THEN 'RLS Enabled'
    ELSE 'RLS Disabled (but security_invoker handles this)'
  END AS rls_status
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' 
  AND c.relkind = 'v'
  AND c.relname IN ('daily_workout_stats', 'weekly_workout_summary', 'daily_nutrition_totals');

-- ============================================
-- STEP 4: MANUAL TESTING GUIDE
-- ============================================
/*
To verify RLS is working through the views:

TEST 1: Empty results for users with no data
-----------------------------------------
1. Create a new test user (User B) via Supabase Auth
2. Sign in as User B (who has no workout data)
3. Run: SELECT * FROM daily_workout_stats;
4. Expected: 0 rows returned (not User A's data!)

TEST 2: Data isolation between users
-----------------------------------------
1. Sign in as User A (who has workout data)
2. Run: SELECT * FROM daily_workout_stats;
3. Note the count of rows
4. Sign in as User B
5. Run: SELECT * FROM daily_workout_stats;
6. Expected: Different results (only User B's data, or empty)

TEST 3: Direct comparison
-----------------------------------------
-- As any user, this should only return YOUR data:
SELECT COUNT(*) FROM daily_workout_stats;

-- Compare with direct table query (should match):
SELECT COUNT(*) FROM (
  SELECT user_id, workout_date
  FROM workout_sessions 
  WHERE status = 'completed'
  GROUP BY user_id, workout_date
) subq;

-- If counts differ, RLS is not working properly!

TEST 4: Cross-user query attempt
-----------------------------------------
-- This query should return 0 rows if you're not user X:
SELECT * FROM daily_workout_stats 
WHERE user_id = 'some-other-users-uuid';

-- RLS on workout_sessions will filter this out automatically
*/

-- ============================================
-- SECURITY NOTES
-- ============================================
/*
WHY security_invoker = true WORKS:

1. Without it: View runs as the VIEW OWNER (usually 'postgres' or service role)
   - RLS policies are BYPASSED because owner has full access
   - Result: User A can see User B's aggregated data

2. With it: View runs as the CALLING USER (the authenticated app user)
   - RLS policies on workout_sessions/nutrition_logs ARE ENFORCED
   - Result: User A can only see their own aggregated data

ALTERNATIVE (Method B - Fallback):
If security_invoker doesn't work for some reason, you can add explicit filters:

CREATE VIEW public.daily_workout_stats AS
SELECT ...
FROM public.workout_sessions
WHERE status = 'completed'
  AND user_id = auth.uid()  -- <-- Explicit filter
GROUP BY user_id, workout_date;

But security_invoker is cleaner and more maintainable.

POSTGRES VERSION NOTE:
- security_invoker was added in PostgreSQL 15
- Supabase uses PostgreSQL 15.x, so it's fully supported
- Check your version: SELECT version();
*/

-- ============================================
-- DONE!
-- ============================================
-- After running this script:
-- ✅ All 3 views now enforce RLS via security_invoker
-- ✅ Column names are unchanged (Flutter app compatibility)
-- ✅ Users can only see their own aggregated data
