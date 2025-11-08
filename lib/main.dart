import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'config/supabase_config.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'l10n/app_localizations.dart';

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

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trainer',
      theme: buildTheme(),
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
      home: SupabaseConfig.client.auth.currentUser != null
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
