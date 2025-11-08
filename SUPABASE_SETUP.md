# Supabase Setup Instructions

## ✅ Что уже сделано:

1. **Добавлены зависимости** в `pubspec.yaml`:
   - `supabase_flutter: ^2.10.3`
   - `flutter_secure_storage: ^9.2.4`

2. **Создана SQL схема** (`supabase_complete_schema.sql`):
   - Таблицы: profiles, workout_sessions, exercise_logs, nutrition_logs, body_measurements, chat_messages
   - RLS (Row Level Security) политики
   - Triggers для auto-update
   - Views для статистики

3. **Созданы сервисы**:
   - `lib/config/supabase_config.dart` - конфигурация
   - `lib/services/auth_service.dart` - auth операции

4. **Создан экран**:
   - `lib/screens/login_screen.dart` - полнофункциональный экран входа

5. **Обновлен onboarding**:
   - Убран переход на BodyScanScreen
   - Переход сразу на HomeScreen после регистрации

## 📋 Что нужно сделать для запуска:

### Шаг 1: Создать проект Supabase

1. Зайдите на https://supabase.com
2. Создайте новый проект (Project name: `pulsefit-pro` или любое другое)
3. Дождитесь завершения создания (~2 минуты)

### Шаг 2: Скопировать credentials

1. В Supabase проекте зайдите в **Settings** → **API**
2. Скопируйте:
   - **Project URL** (например: `https://abcdefgh.supabase.co`)
   - **anon/public key** (длинный JWT токен)

### Шаг 3: Добавить в secrets.json

Откройте `secrets.json` и добавьте:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "RAPIDAPI_KEY": "your-existing-key"
}
```

### Шаг 4: Запустить SQL схему

1. В Supabase зайдите в **SQL Editor**
2. Создайте новый query
3. Скопируйте весь код из `supabase_complete_schema.sql`
4. Нажмите **Run** (должно выполниться успешно)
5. Проверьте, что таблицы созданы в **Table Editor**

### Шаг 5: Включить Email Auth

1. Зайдите в **Authentication** → **Providers**
2. Включите **Email** (должен быть включен по умолчанию)
3. В **Email Templates** можете настроить дизайн писем (опционально)

### Шаг 6: Обновить main.dart

В `lib/main.dart` добавьте инициализацию Supabase:

```dart
import 'config/supabase_config.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load secrets
  final secretsString = await rootBundle.loadString('secrets.json');
  final secrets = json.decode(secretsString);
  
  // Initialize Supabase
  await SupabaseConfig.initialize(
    supabaseUrl: secrets['SUPABASE_URL'],
    supabaseAnonKey: secrets['SUPABASE_ANON_KEY'],
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### Шаг 7: Обновить routing

В `lib/main.dart` измените начальный экран на проверку auth:

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: FutureBuilder(
        future: SupabaseConfig.client.auth.currentSession,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final session = snapshot.data;
          if (session != null) {
            return const HomeScreen(); // Есть сессия - на главный экран
          }
          return const LoginScreen(); // Нет сессии - на вход
        },
      ),
    );
  }
}
```

## 🎯 Следующие шаги:

1. ✅ Закончить auth экраны (RegisterScreen, ForgotPasswordScreen)
2. ✅ Интегрировать ProfileService для работы с профилями
3. ✅ Рулетка для новых пользователей (trial period)
4. ✅ Paywall экран для expired subscriptions
5. ✅ Сохранение workout sessions в Supabase

## 🚀 Команда для запуска:

```bash
flutter run -d windows --dart-define-from-file=secrets.json
```

## 🔧 Troubleshooting:

- **Ошибка "Invalid API credentials"**: Проверьте SUPABASE_URL и SUPABASE_ANON_KEY в secrets.json
- **Ошибка при регистрации**: Убедитесь, что Email Auth включен в Supabase
- **RLS ошибки**: Проверьте, что SQL схема выполнена полностью
- **Windows SSL error**: Добавьте `--no-sound-null-safety` если нужно
