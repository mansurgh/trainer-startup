-- Trainer App - Supabase Database Schema
-- Production-ready structure with RLS, indexes, and triggers

-- ===== EXTENSIONS =====
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ===== USERS & PROFILES =====

-- Расширяем auth.users через profiles
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    
    -- Physical data
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    date_of_birth DATE,
    height_cm INTEGER CHECK (height_cm > 0 AND height_cm < 300),
    activity_level TEXT CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')),
    
    -- Goals
    fitness_goal TEXT CHECK (fitness_goal IN ('weight_loss', 'muscle_gain', 'maintenance', 'endurance', 'strength')),
    target_weight_kg DECIMAL(5,2),
    
    -- Preferences
    preferred_units TEXT DEFAULT 'metric' CHECK (preferred_units IN ('metric', 'imperial')),
    timezone TEXT DEFAULT 'UTC',
    language TEXT DEFAULT 'ru',
    
    -- Privacy
    is_public BOOLEAN DEFAULT false,
    show_weight BOOLEAN DEFAULT false,
    show_progress_photos BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== BODY METRICS =====

CREATE TABLE public.body_metrics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    -- Measurements
    weight_kg DECIMAL(5,2),
    body_fat_percentage DECIMAL(4,2) CHECK (body_fat_percentage >= 0 AND body_fat_percentage <= 100),
    muscle_mass_kg DECIMAL(5,2),
    bone_density DECIMAL(4,2),
    water_percentage DECIMAL(4,2),
    metabolic_age INTEGER,
    
    -- Body parts (cm)
    waist_cm DECIMAL(5,2),
    chest_cm DECIMAL(5,2),
    arm_cm DECIMAL(5,2),
    thigh_cm DECIMAL(5,2),
    neck_cm DECIMAL(5,2),
    
    -- Progress photos
    front_photo_url TEXT,
    side_photo_url TEXT,
    back_photo_url TEXT,
    
    -- Metadata
    measurement_date DATE DEFAULT CURRENT_DATE,
    notes TEXT,
    is_milestone BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== EXERCISES =====

CREATE TABLE public.exercises (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    
    -- Category
    category TEXT NOT NULL CHECK (category IN ('strength', 'cardio', 'flexibility', 'sports', 'stretching')),
    equipment TEXT[] DEFAULT '{}',
    difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    
    -- Muscle groups
    primary_muscles TEXT[] NOT NULL,
    secondary_muscles TEXT[] DEFAULT '{}',
    
    -- Instructions
    description TEXT,
    instructions TEXT[],
    tips TEXT[],
    
    -- Media
    image_url TEXT,
    gif_url TEXT,
    video_url TEXT,
    
    -- Metadata
    calories_per_minute DECIMAL(4,2),
    met_value DECIMAL(4,2), -- Metabolic Equivalent
    is_bodyweight BOOLEAN DEFAULT true,
    is_popular BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== WORKOUTS & WORKOUT PLANS =====

CREATE TABLE public.workout_plans (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    name TEXT NOT NULL,
    description TEXT,
    
    -- Plan details
    plan_type TEXT CHECK (plan_type IN ('strength', 'cardio', 'hiit', 'yoga', 'custom')),
    difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    duration_weeks INTEGER CHECK (duration_weeks > 0),
    sessions_per_week INTEGER CHECK (sessions_per_week > 0 AND sessions_per_week <= 7),
    
    -- Goals
    target_goals TEXT[] DEFAULT '{}',
    estimated_calories_per_session INTEGER,
    equipment_needed TEXT[] DEFAULT '{}',
    
    -- Status
    is_active BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false,
    is_ai_generated BOOLEAN DEFAULT false,
    
    -- Metadata
    total_sessions INTEGER DEFAULT 0,
    completed_sessions INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.workouts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    workout_plan_id UUID REFERENCES public.workout_plans(id) ON DELETE SET NULL,
    
    name TEXT NOT NULL,
    notes TEXT,
    
    -- Workout details
    workout_type TEXT CHECK (workout_type IN ('strength', 'cardio', 'hiit', 'yoga', 'stretching', 'custom')),
    target_muscle_groups TEXT[] DEFAULT '{}',
    
    -- Timing
    planned_duration_minutes INTEGER,
    actual_duration_minutes INTEGER,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Progress
    status TEXT DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed', 'skipped')),
    difficulty_rating INTEGER CHECK (difficulty_rating >= 1 AND difficulty_rating <= 5),
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 5),
    
    -- Performance
    total_volume_kg DECIMAL(8,2) DEFAULT 0,
    total_reps INTEGER DEFAULT 0,
    calories_burned INTEGER,
    average_heart_rate INTEGER,
    max_heart_rate INTEGER,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== WORKOUT EXERCISES & SETS =====

CREATE TABLE public.workout_exercises (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    workout_id UUID REFERENCES public.workouts(id) ON DELETE CASCADE NOT NULL,
    exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE NOT NULL,
    
    -- Order and grouping
    exercise_order INTEGER NOT NULL,
    superset_group INTEGER, -- для суперсетов
    
    -- Plan vs actual
    planned_sets INTEGER,
    planned_reps INTEGER,
    planned_weight_kg DECIMAL(6,2),
    planned_duration_seconds INTEGER,
    planned_rest_seconds INTEGER DEFAULT 60,
    
    -- Instructions
    notes TEXT,
    rpe_target INTEGER CHECK (rpe_target >= 1 AND rpe_target <= 10), -- Rate of Perceived Exertion
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.exercise_sets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    workout_exercise_id UUID REFERENCES public.workout_exercises(id) ON DELETE CASCADE NOT NULL,
    
    -- Set details
    set_number INTEGER NOT NULL,
    set_type TEXT DEFAULT 'working' CHECK (set_type IN ('warmup', 'working', 'drop', 'failure', 'rest_pause')),
    
    -- Performance
    reps INTEGER,
    weight_kg DECIMAL(6,2),
    duration_seconds INTEGER,
    distance_meters DECIMAL(8,2),
    calories_burned INTEGER,
    
    -- Subjective measures
    rpe INTEGER CHECK (rpe >= 1 AND rpe <= 10),
    effort_level INTEGER CHECK (effort_level >= 1 AND effort_level <= 5),
    
    -- Status
    is_completed BOOLEAN DEFAULT false,
    is_personal_record BOOLEAN DEFAULT false,
    
    -- Metadata
    rest_duration_seconds INTEGER,
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== NUTRITION =====

CREATE TABLE public.foods (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    brand TEXT,
    barcode TEXT UNIQUE,
    
    -- Nutrition per 100g
    calories_per_100g DECIMAL(6,2) NOT NULL,
    protein_per_100g DECIMAL(5,2) DEFAULT 0,
    carbs_per_100g DECIMAL(5,2) DEFAULT 0,
    fat_per_100g DECIMAL(5,2) DEFAULT 0,
    fiber_per_100g DECIMAL(5,2) DEFAULT 0,
    sugar_per_100g DECIMAL(5,2) DEFAULT 0,
    sodium_per_100g DECIMAL(6,2) DEFAULT 0, -- mg
    
    -- Vitamins & minerals (per 100g)
    vitamin_c_mg DECIMAL(6,2) DEFAULT 0,
    calcium_mg DECIMAL(6,2) DEFAULT 0,
    iron_mg DECIMAL(6,2) DEFAULT 0,
    
    -- Categories
    category TEXT,
    subcategory TEXT,
    tags TEXT[] DEFAULT '{}',
    
    -- Metadata
    is_verified BOOLEAN DEFAULT false,
    serving_size_g DECIMAL(6,2) DEFAULT 100,
    serving_description TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.meals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    name TEXT NOT NULL,
    meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'pre_workout', 'post_workout')),
    
    -- Timing
    consumed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    meal_date DATE DEFAULT CURRENT_DATE,
    
    -- Totals (calculated)
    total_calories DECIMAL(7,2) DEFAULT 0,
    total_protein DECIMAL(6,2) DEFAULT 0,
    total_carbs DECIMAL(6,2) DEFAULT 0,
    total_fat DECIMAL(6,2) DEFAULT 0,
    total_fiber DECIMAL(6,2) DEFAULT 0,
    
    -- Metadata
    notes TEXT,
    photo_url TEXT,
    is_logged_by_ai BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.meal_foods (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    meal_id UUID REFERENCES public.meals(id) ON DELETE CASCADE NOT NULL,
    food_id UUID REFERENCES public.foods(id) ON DELETE CASCADE NOT NULL,
    
    -- Quantity
    quantity_grams DECIMAL(7,2) NOT NULL,
    serving_multiplier DECIMAL(5,2) DEFAULT 1,
    
    -- Calculated nutrition (denormalized for performance)
    calories DECIMAL(6,2),
    protein DECIMAL(5,2),
    carbs DECIMAL(5,2),
    fat DECIMAL(5,2),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== STREAKS & ACHIEVEMENTS =====

CREATE TABLE public.streaks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    streak_type TEXT NOT NULL CHECK (streak_type IN ('workout', 'nutrition', 'water', 'steps', 'sleep')),
    
    -- Current streak
    current_count INTEGER DEFAULT 0,
    current_start_date DATE,
    
    -- Best streak
    best_count INTEGER DEFAULT 0,
    best_start_date DATE,
    best_end_date DATE,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    last_activity_date DATE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, streak_type)
);

CREATE TABLE public.achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    
    -- Achievement details
    icon_name TEXT,
    badge_color TEXT,
    points INTEGER DEFAULT 0,
    
    -- Criteria
    criteria JSONB NOT NULL, -- Flexible criteria definition
    tier TEXT CHECK (tier IN ('bronze', 'silver', 'gold', 'platinum')),
    
    -- Metadata
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.user_achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    achievement_id UUID REFERENCES public.achievements(id) ON DELETE CASCADE NOT NULL,
    
    -- Progress
    progress DECIMAL(5,2) DEFAULT 0, -- 0-100
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    current_value DECIMAL(10,2), -- Current progress value
    target_value DECIMAL(10,2), -- Target value to achieve
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, achievement_id)
);

-- ===== AI & ANALYTICS =====

CREATE TABLE public.ai_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    -- Session details
    session_type TEXT CHECK (session_type IN ('workout_plan', 'nutrition_advice', 'form_check', 'general_chat')),
    prompt TEXT NOT NULL,
    response TEXT NOT NULL,
    
    -- Context
    context_data JSONB, -- Flexible context (user stats, current workout, etc.)
    model_used TEXT,
    tokens_used INTEGER,
    
    -- Quality
    user_rating INTEGER CHECK (user_rating >= 1 AND user_rating <= 5),
    user_feedback TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.activity_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    -- Activity
    activity_type TEXT NOT NULL,
    activity_data JSONB,
    
    -- Timing
    activity_date DATE DEFAULT CURRENT_DATE,
    activity_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Metadata
    device_info JSONB,
    app_version TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== INDEXES =====

-- Profiles
CREATE INDEX idx_profiles_username ON public.profiles(username);
CREATE INDEX idx_profiles_created_at ON public.profiles(created_at);

-- Body metrics
CREATE INDEX idx_body_metrics_user_date ON public.body_metrics(user_id, measurement_date DESC);
CREATE INDEX idx_body_metrics_milestones ON public.body_metrics(user_id) WHERE is_milestone = true;

-- Exercises
CREATE INDEX idx_exercises_category ON public.exercises(category);
CREATE INDEX idx_exercises_muscles ON public.exercises USING GIN(primary_muscles);
CREATE INDEX idx_exercises_equipment ON public.exercises USING GIN(equipment);
CREATE INDEX idx_exercises_difficulty ON public.exercises(difficulty_level);
CREATE INDEX idx_exercises_popular ON public.exercises(is_popular) WHERE is_popular = true;

-- Workouts
CREATE INDEX idx_workouts_user_date ON public.workouts(user_id, created_at DESC);
CREATE INDEX idx_workouts_status ON public.workouts(user_id, status);
CREATE INDEX idx_workouts_plan ON public.workouts(workout_plan_id);

-- Workout exercises
CREATE INDEX idx_workout_exercises_workout ON public.workout_exercises(workout_id, exercise_order);
CREATE INDEX idx_workout_exercises_exercise ON public.workout_exercises(exercise_id);

-- Sets
CREATE INDEX idx_exercise_sets_workout_exercise ON public.exercise_sets(workout_exercise_id, set_number);
CREATE INDEX idx_exercise_sets_pr ON public.exercise_sets(workout_exercise_id) WHERE is_personal_record = true;

-- Nutrition
CREATE INDEX idx_foods_name ON public.foods(name);
CREATE INDEX idx_foods_barcode ON public.foods(barcode);
CREATE INDEX idx_foods_category ON public.foods(category, subcategory);

CREATE INDEX idx_meals_user_date ON public.meals(user_id, meal_date DESC);
CREATE INDEX idx_meals_type ON public.meals(user_id, meal_type, meal_date DESC);

CREATE INDEX idx_meal_foods_meal ON public.meal_foods(meal_id);
CREATE INDEX idx_meal_foods_food ON public.meal_foods(food_id);

-- Streaks & achievements
CREATE INDEX idx_streaks_user_type ON public.streaks(user_id, streak_type);
CREATE INDEX idx_user_achievements_user ON public.user_achievements(user_id, is_completed);

-- AI & analytics
CREATE INDEX idx_ai_sessions_user ON public.ai_sessions(user_id, created_at DESC);
CREATE INDEX idx_activity_logs_user_date ON public.activity_logs(user_id, activity_date DESC);
CREATE INDEX idx_activity_logs_type ON public.activity_logs(activity_type, activity_date DESC);

-- ===== RLS POLICIES =====

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.body_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can view public profiles" ON public.profiles FOR SELECT USING (is_public = true);

-- Body metrics policies
CREATE POLICY "Users can manage own body metrics" ON public.body_metrics FOR ALL USING (auth.uid() = user_id);

-- Workout policies
CREATE POLICY "Users can manage own workout plans" ON public.workout_plans FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view public workout plans" ON public.workout_plans FOR SELECT USING (is_public = true);

CREATE POLICY "Users can manage own workouts" ON public.workouts FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own workout exercises" ON public.workout_exercises FOR ALL USING (
    auth.uid() = (SELECT user_id FROM public.workouts WHERE id = workout_id)
);
CREATE POLICY "Users can manage own exercise sets" ON public.exercise_sets FOR ALL USING (
    auth.uid() = (
        SELECT w.user_id 
        FROM public.workouts w 
        JOIN public.workout_exercises we ON w.id = we.workout_id 
        WHERE we.id = workout_exercise_id
    )
);

-- Nutrition policies
CREATE POLICY "Users can manage own meals" ON public.meals FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own meal foods" ON public.meal_foods FOR ALL USING (
    auth.uid() = (SELECT user_id FROM public.meals WHERE id = meal_id)
);

-- Streaks & achievements policies
CREATE POLICY "Users can view own streaks" ON public.streaks FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own achievements" ON public.user_achievements FOR ALL USING (auth.uid() = user_id);

-- AI & analytics policies
CREATE POLICY "Users can manage own AI sessions" ON public.ai_sessions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own activity logs" ON public.activity_logs FOR ALL USING (auth.uid() = user_id);

-- Public read access for reference data
CREATE POLICY "Anyone can view exercises" ON public.exercises FOR SELECT USING (true);
CREATE POLICY "Anyone can view foods" ON public.foods FOR SELECT USING (true);
CREATE POLICY "Anyone can view achievements" ON public.achievements FOR SELECT USING (true);

-- ===== TRIGGERS =====

-- Updated at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exercises_updated_at BEFORE UPDATE ON public.exercises FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workout_plans_updated_at BEFORE UPDATE ON public.workout_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workouts_updated_at BEFORE UPDATE ON public.workouts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_foods_updated_at BEFORE UPDATE ON public.foods FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_meals_updated_at BEFORE UPDATE ON public.meals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url)
    VALUES (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
    
    -- Initialize streaks
    INSERT INTO public.streaks (user_id, streak_type) VALUES
    (new.id, 'workout'),
    (new.id, 'nutrition'),
    (new.id, 'water');
    
    RETURN new;
END;
$$ language plpgsql security definer;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Calculate meal totals
CREATE OR REPLACE FUNCTION calculate_meal_totals()
RETURNS TRIGGER AS $$
DECLARE
    meal_record RECORD;
BEGIN
    -- Get meal totals
    SELECT 
        COALESCE(SUM(mf.calories), 0) as total_calories,
        COALESCE(SUM(mf.protein), 0) as total_protein,
        COALESCE(SUM(mf.carbs), 0) as total_carbs,
        COALESCE(SUM(mf.fat), 0) as total_fat
    INTO meal_record
    FROM public.meal_foods mf
    WHERE mf.meal_id = COALESCE(NEW.meal_id, OLD.meal_id);
    
    -- Update meal
    UPDATE public.meals 
    SET 
        total_calories = meal_record.total_calories,
        total_protein = meal_record.total_protein,
        total_carbs = meal_record.total_carbs,
        total_fat = meal_record.total_fat,
        updated_at = NOW()
    WHERE id = COALESCE(NEW.meal_id, OLD.meal_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language plpgsql;

CREATE TRIGGER update_meal_totals
    AFTER INSERT OR UPDATE OR DELETE ON public.meal_foods
    FOR EACH ROW EXECUTE FUNCTION calculate_meal_totals();

-- ===== SEED DATA =====

-- Sample exercises
INSERT INTO public.exercises (name, slug, category, primary_muscles, secondary_muscles, difficulty_level, description, instructions, is_bodyweight) VALUES
('Push Up', 'push-up', 'strength', ARRAY['chest', 'triceps'], ARRAY['shoulders'], 'beginner', 'Classic bodyweight exercise', ARRAY['Start in plank position', 'Lower chest to floor', 'Push back up'], true),
('Squat', 'squat', 'strength', ARRAY['quadriceps', 'glutes'], ARRAY['hamstrings', 'calves'], 'beginner', 'Fundamental lower body exercise', ARRAY['Feet shoulder-width apart', 'Sit back into squat', 'Stand back up'], true),
('Plank', 'plank', 'strength', ARRAY['core'], ARRAY['shoulders'], 'beginner', 'Isometric core exercise', ARRAY['Start in push-up position', 'Hold body straight', 'Engage core'], true);

-- Sample achievements
INSERT INTO public.achievements (name, description, category, criteria, tier, points) VALUES
('First Workout', 'Complete your first workout', 'workout', '{"workouts_completed": 1}', 'bronze', 10),
('Week Warrior', 'Complete 7 workouts in a week', 'workout', '{"weekly_workouts": 7}', 'silver', 50),
('Consistency King', 'Maintain a 30-day workout streak', 'streak', '{"workout_streak": 30}', 'gold', 100);

-- Sample foods
INSERT INTO public.foods (name, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, category) VALUES
('Chicken Breast', 165, 31, 0, 3.6, 'meat'),
('Brown Rice', 123, 2.6, 23, 0.9, 'grains'),
('Broccoli', 34, 2.8, 7, 0.4, 'vegetables'),
('Banana', 89, 1.1, 23, 0.3, 'fruits'),
('Almonds', 579, 21, 22, 49, 'nuts');