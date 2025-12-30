import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:window_manager/window_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'theme/app_theme.dart';
import 'core/design_tokens.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'config/supabase_config.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/nutrition_goal_checker.dart';
import 'services/auth_service.dart';
import 'state/user_state.dart';
import 'models/user_model.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Load secrets and initialize Supabase
  try {
    final secretsString = await rootBundle.loadString('secrets.json');
    final secrets = json.decode(secretsString);
    
    await SupabaseConfig.initialize(
      supabaseUrl: secrets['SUPABASE_URL'],
      supabaseAnonKey: secrets['SUPABASE_ANON_KEY'],
    );
  } catch (_) {}

  // Стабильные настройки окна (без прозрачности), «мобильный» размер
  await windowManager.ensureInitialized();
  await windowManager.setTitle('Trainer');
  await windowManager.setSize(const Size(410, 750)); // 19.5:9 близко к iPhone 15
  await windowManager.setMinimumSize(const Size(380, 680));
  await windowManager.center();

  // Инициализация сервисов
  await StorageService.initialize();
  await NotificationService.initialize();
  await NotificationService.requestPermissions();
  
  // Инициализация AuthService (bulletproof auth layer)
  await AuthService().initialize();
  
  // Запускаем автоматический мониторинг целей по питанию
  NutritionGoalChecker.startMonitoring();

  // МИГРАЦИЯ: Переносим все профили из SQLite в Supabase
  try {
    final prefs = await SharedPreferences.getInstance();
    final hasMigrated = prefs.getBool('profiles_migrated_to_supabase') ?? false;
    
    if (!hasMigrated) {
      await StorageService.migrateProfilesToSupabase();
      await prefs.setBool('profiles_migrated_to_supabase', true);
    }
  } catch (_) {}

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  // Загрузка данных пользователя из локальной БД (асинхронная версия)
  Future<UserModel?> _loadUserDataAsync(WidgetRef ref, String userId) async {
    try {
      // Проверяем что userId в SharedPreferences совпадает с сессией
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('user_id');
      
      if (storedUserId != userId) {
        // Очищаем данные неправильного пользователя
        if (storedUserId != null) {
          final keys = prefs.getKeys().toList();
          for (final key in keys) {
            if (key.contains('_${storedUserId}_') || key.contains('_$storedUserId')) {
              await prefs.remove(key);
            }
          }
        }
        
        // Устанавливаем правильный userId
        await prefs.setString('user_id', userId);
      }
      
      final user = await StorageService.getUser();
      
      if (user != null && user.id == userId) {
        ref.read(userProvider.notifier).state = user;
        return user;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trainer',
      theme: buildPremiumDarkTheme(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
      ],
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
      home: FutureBuilder<Session?>(
        future: Future(() async {
          try {
            return SupabaseConfig.client.auth.currentSession;
          } catch (_) {
            return null;
          }
        }),
        builder: (context, snapshot) {
          // Показываем загрузку пока проверяем сессию
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: DesignTokens.bgBase,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          
          // Проверяем реальную текущую сессию
          final session = snapshot.data;
          
          if (session != null && session.user.id.isNotEmpty) {
            // Сессия активна - загружаем данные пользователя асинхронно
            return FutureBuilder<UserModel?>(
              future: _loadUserDataAsync(ref, session.user.id),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: DesignTokens.bgBase,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                
                return HomeScreen(key: ValueKey(session.user.id), initialIndex: 0);
              },
            );
          }
          // Нет сессии - всегда начинаем с экрана авторизации (LoginScreen)
          return const LoginScreen(key: ValueKey('login'));
        },
      ),
    );
  }
}
