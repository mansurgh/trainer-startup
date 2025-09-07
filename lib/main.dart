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
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Стабильные настройки окна (без прозрачности), «мобильный» размер
  await windowManager.ensureInitialized();
  await windowManager.setTitle('PulseFit Pro');
  await windowManager.setSize(const Size(410, 750)); // 19.5:9 близко к iPhone 15
  await windowManager.setMinimumSize(const Size(380, 680));
  await windowManager.center();

  // Инициализация уведомлений
  await NotificationService.initialize();
  await NotificationService.requestPermissions();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PulseFit Pro',
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
      home: user == null ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
