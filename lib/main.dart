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
import 'core/design_tokens.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'config/supabase_config.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/nutrition_goal_checker.dart';
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
    
    print('[Main] Supabase initialized successfully');
  } catch (e) {
    print('[Main] Error initializing Supabase: $e');
  }

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
  
  // Запускаем автоматический мониторинг целей по питанию
  NutritionGoalChecker.startMonitoring();

  // МИГРАЦИЯ: Переносим все профили из SQLite в Supabase
  try {
    final prefs = await SharedPreferences.getInstance();
    final hasMigrated = prefs.getBool('profiles_migrated_to_supabase') ?? false;
    
    if (!hasMigrated) {
      print('[Main] 🔄 Migrating user profiles from SQLite to Supabase...');
      await StorageService.migrateProfilesToSupabase();
      await prefs.setBool('profiles_migrated_to_supabase', true);
      print('[Main] ✅ Profile migration completed');
    } else {
      print('[Main] ℹ️ Profiles already migrated (skip)');
    }
  } catch (e) {
    print('[Main] ❌ Error during profile migration: $e');
  }

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
        print('[Main] ⚠️ UserId mismatch! Stored: $storedUserId, Session: $userId');
        print('[Main] Clearing mismatched user data...');
        
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
        print('[Main] ✅ UserId corrected to: $userId');
      }
      
      print('[Main] 🔍 Attempting to load user data for: $userId');
      final user = await StorageService.getUser();
      
      if (user != null) {
        print('[Main] 📦 User loaded from storage: id=${user.id}, name=${user.name}, age=${user.age}, height=${user.height}, weight=${user.weight}');
        
        if (user.id == userId) {
          // Загружаем данные пользователя в состояние
          ref.read(userProvider.notifier).state = user;
          print('[Main] ✅ User data set to userProvider: ${user.name ?? "NO NAME"}');
          return user;
        } else {
          print('[Main] ⚠️ User ID mismatch! Expected: $userId, Got: ${user.id}');
          return null;
        }
      } else {
        print('[Main] ℹ️ No user data found for: $userId (getUser returned null)');
        return null;
      }
    } catch (e) {
      print('[Main] ❌ Error loading user data: $e');
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trainer',
      theme: buildTheme(),
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
            final session = SupabaseConfig.client.auth.currentSession;
            print('[Main] 🔍 Checking session: ${session?.user.id ?? "NONE"}');
            return session;
          } catch (e) {
            print('[Main] ⚠️ Error checking session: $e');
            return null;
          }
        }),
        builder: (context, snapshot) {
          print('[Main] Auth check - connectionState: ${snapshot.connectionState}');
          
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
          print('[Main] Current session: ${session?.user.id ?? "NONE - LOGGED OUT"}');
          
          if (session != null && session.user.id.isNotEmpty) {
            // Сессия активна - загружаем данные пользователя асинхронно
            print('[Main] ✅ Valid session found - loading user data for: ${session.user.id}');
            
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
          print('[Main] ❌ No session - showing LoginScreen');
          return const LoginScreen(key: ValueKey('login'));
        },
      ),
    );
  }
}
