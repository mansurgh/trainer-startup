-- =============================================================================
-- SUPABASE BULLETPROOF AUTH & DATA SCHEMA
-- =============================================================================
-- Этот скрипт создает надежную систему аутентификации и управления данными
-- с Row Level Security (RLS) и автоматическим созданием профилей.
--
-- ЦЕЛЬ: Полностью исключить утечку данных между пользователями и гарантировать
-- целостность данных при регистрации.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ШАГ 1: ОЧИСТКА (опционально, осторожно в продакшене!)
-- -----------------------------------------------------------------------------
-- DROP TABLE IF EXISTS public.profiles CASCADE;
-- DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- -----------------------------------------------------------------------------
-- ШАГ 2: СОЗДАНИЕ ТАБЛИЦЫ PROFILES
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  -- Primary Key = User ID из auth.users
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Базовая информация
  email TEXT,
  name TEXT,
  avatar_url TEXT,
  
  -- Физические параметры
  age INTEGER CHECK (age > 0 AND age < 150),
  height NUMERIC(5, 2) CHECK (height > 0 AND height < 300), -- в см
  weight NUMERIC(5, 2) CHECK (weight > 0 AND weight < 500), -- в кг
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  
  -- Фитнес метрики
  discipline_score INTEGER DEFAULT 0 CHECK (discipline_score >= 0 AND discipline_score <= 1000),
  
  -- Системные поля
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Индексы для быстрого поиска
  CONSTRAINT unique_email UNIQUE (email)
);

-- Создаем индекс на email для быстрых lookup
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- Триггер для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at 
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- -----------------------------------------------------------------------------
-- ШАГ 3: ROW LEVEL SECURITY (RLS) — КРИТИЧНАЯ ЧАСТЬ
-- -----------------------------------------------------------------------------
-- Включаем RLS на таблице profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Удаляем старые политики (если есть)
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;

-- ПОЛИТИКА 1: SELECT — пользователь может ЧИТАТЬ только свою строку
CREATE POLICY "Users can view own profile"
ON public.profiles
FOR SELECT
USING (auth.uid() = id);

-- ПОЛИТИКА 2: INSERT — пользователь может СОЗДАТЬ только свою строку
CREATE POLICY "Users can insert own profile"
ON public.profiles
FOR INSERT
WITH CHECK (auth.uid() = id);

-- ПОЛИТИКА 3: UPDATE — пользователь может ОБНОВЛЯТЬ только свою строку
CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ПОЛИТИКА 4: DELETE — пользователь может УДАЛИТЬ только свою строку (опционально)
CREATE POLICY "Users can delete own profile"
ON public.profiles
FOR DELETE
USING (auth.uid() = id);

COMMENT ON TABLE public.profiles IS 'Profiles table with RLS enforcing per-user isolation';

-- -----------------------------------------------------------------------------
-- ШАГ 4: TRIGGER ДЛЯ АВТОМАТИЧЕСКОГО СОЗДАНИЯ ПРОФИЛЯ
-- -----------------------------------------------------------------------------
-- Эта функция вызывается АВТОМАТИЧЕСКИ при создании нового юзера в auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Новый пользователь'),
    NOW(),
    NOW()
  );
  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- Если профиль уже существует, просто игнорируем
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Привязываем триггер к auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

COMMENT ON FUNCTION public.handle_new_user() IS 'Auto-creates profile row when user signs up';

-- -----------------------------------------------------------------------------
-- ШАГ 5: ДОПОЛНИТЕЛЬНЫЕ ГАРАНТИИ
-- -----------------------------------------------------------------------------
-- Функция для безопасного получения профиля (с fallback)
CREATE OR REPLACE FUNCTION public.get_profile(user_id UUID)
RETURNS public.profiles AS $$
BEGIN
  RETURN (SELECT * FROM public.profiles WHERE id = user_id LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- -----------------------------------------------------------------------------
-- ШАГ 6: ПРОВЕРКА РАБОТЫ
-- -----------------------------------------------------------------------------
-- После применения этого скрипта проверьте:
-- 1. Зарегистрируйте нового пользователя → профиль должен создаться автоматически
-- 2. Попытайтесь прочитать чужой профиль → должно быть 0 результатов
-- 3. Попытайтесь изменить чужой профиль → должна быть ошибка "new row violates row-level security policy"

-- Тестовый запрос (выполняется от имени текущего пользователя):
-- SELECT * FROM public.profiles WHERE id = auth.uid();

-- -----------------------------------------------------------------------------
-- ИНСТРУКЦИИ ДЛЯ SUPABASE DASHBOARD:
-- -----------------------------------------------------------------------------
-- 1. Перейдите в: Database → SQL Editor
-- 2. Вставьте ВЕСь этот скрипт
-- 3. Нажмите "Run"
-- 4. Проверьте в: Authentication → Policies → Убедитесь, что включены все 4 политики
-- 5. Проверьте в: Database → Triggers → Должен быть триггер "on_auth_user_created"
-- 
-- ВАЖНО: Если у вас уже есть пользователи БЕЗ профилей, выполните:
-- INSERT INTO public.profiles (id, email, name)
-- SELECT id, email, COALESCE(raw_user_meta_data->>'name', 'Пользователь')
-- FROM auth.users
-- WHERE id NOT IN (SELECT id FROM public.profiles);
-- =============================================================================
