# Настройка Email Verification в Supabase

## Проблема
При регистрации нового пользователя Supabase отправляет письмо для подтверждения email. 
До подтверждения вход невозможен (ошибка: "Email not confirmed").

## Решение для разработки

### Вариант 1: Отключить email verification (РЕКОМЕНДУЕТСЯ для тестирования)

1. Откройте Supabase Dashboard: https://supabase.com/dashboard/project/medbukurycohkymdbmiz
2. Перейдите в **Authentication** → **Providers** → **Email**
3. Найдите **"Confirm email"**
4. **Отключите** этот переключатель
5. Нажмите **Save**

Теперь новые пользователи смогут входить сразу после регистрации без подтверждения email.

### Вариант 2: Подтвердить email вручную

1. Откройте Supabase Dashboard
2. Перейдите в **Authentication** → **Users**
3. Найдите пользователя (first@mail.ru)
4. Нажмите на email пользователя
5. Справа в панели найдите **"Email Confirmed"**
6. Переключите на **true**
7. Нажмите **Save**

### Вариант 3: Настроить Email Templates (для продакшена)

1. **Authentication** → **Email Templates**
2. Настройте SMTP сервер (SendGrid, Mailgun, AWS SES)
3. Измените шаблон письма подтверждения
4. Установите правильный redirect URL

## Текущая обработка ошибок

Приложение уже показывает понятное сообщение:
```
Login failed
Please verify your email before logging in
```

## Автоматическое подтверждение email через SQL (опционально)

Если хотите автоматически подтверждать email при регистрации:

```sql
-- Создайте функцию для автоматического подтверждения
CREATE OR REPLACE FUNCTION public.auto_confirm_email()
RETURNS TRIGGER AS $$
BEGIN
  -- Автоматически подтверждаем email для новых пользователей
  UPDATE auth.users
  SET email_confirmed_at = NOW(),
      confirmed_at = NOW()
  WHERE id = NEW.id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Создайте триггер
CREATE TRIGGER on_auth_user_created_confirm_email
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_email();
```

⚠️ **Важно:** Используйте этот метод только для разработки! 
Для продакшена обязательна верификация email.

## Рекомендация

Для тестирования используйте **Вариант 1** (отключить Confirm email).
Перед релизом включите обратно и настройте SMTP для отправки писем.
