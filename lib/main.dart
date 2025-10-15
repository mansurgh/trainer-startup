import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'state/user_state.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
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
  
  // Очищаем все данные пользователя для демо-режима (каждый запуск как новый пользователь)
  await StorageService.clearAllData();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
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
      home: const OnboardingScreen(), // Всегда показываем онбординг для демо-режима
    );
  }
}
