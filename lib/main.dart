import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:window_manager/window_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/noir_theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'config/supabase_config.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/nutrition_goal_checker.dart';
import 'services/auth_service.dart';
import 'widgets/auth_wrapper.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';

// =============================================================================
// LOG FILTER — Only show custom [TAG] logs, suppress Flutter framework noise
// =============================================================================
class _LogFilter {
  static final Set<String> _suppressedPatterns = {
    'KeyDown',
    'KeyUp', 
    'RawKeyEvent',
    'FocusManager',
    'Scrollable',
    'GestureBinding',
    'RendererBinding',
    'SchedulerBinding',
    'ServicesBinding',
    'SemanticsBinding',
    'flutter:',
    'package:flutter/',
  };

  /// Check if log should be shown (only [TAG] formatted logs)
  static bool shouldShow(String message) {
    // Always show custom tagged logs like [Auth], [Profile], etc.
    if (message.startsWith('[') && message.contains(']')) {
      return true;
    }
    // Suppress framework noise
    for (final pattern in _suppressedPatterns) {
      if (message.contains(pattern)) {
        return false;
      }
    }
    return false; // By default, suppress untagged logs
  }
}

/// Custom logger that only shows [TAG] formatted logs
void log(String message, {String? tag}) {
  if (!kDebugMode) return;
  
  final formatted = tag != null ? '[$tag] $message' : message;
  if (_LogFilter.shouldShow(formatted)) {
    developer.log(formatted);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Suppress Flutter framework debug logs in debug mode
  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null && _LogFilter.shouldShow(message)) {
        debugPrintSynchronously(message, wrapWidth: wrapWidth);
      }
    };
  }
  
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
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale from provider (reactive to changes)
    final locale = ref.watch(localeProvider);
    final isLocaleInitialized = ref.watch(localeInitializedProvider);
    
    // Show loading while locale is being detected
    if (!isLocaleInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildNoirGlassTheme(),
        home: const _NoirSplashScreen(),
      );
    }
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trainer',
      theme: buildNoirGlassTheme(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocales.supported,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
      home: const AuthWrapper(),
    );
  }
}

// =============================================================================
// NOIR SPLASH SCREEN — Premium Loading Experience
// =============================================================================
class _NoirSplashScreen extends StatefulWidget {
  const _NoirSplashScreen();

  @override
  State<_NoirSplashScreen> createState() => _NoirSplashScreenState();
}

class _NoirSplashScreenState extends State<_NoirSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNoirBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF2A2A2A), // Light source at top
              Color(0xFF0D0D0D),
              kNoirBlack,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Breathing Logo with Glow
              AnimatedBuilder(
                animation: _breatheAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breatheAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15),
                        blurRadius: 50,
                        spreadRadius: 15,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        blurRadius: 100,
                        spreadRadius: 25,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/logo/app_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fitness_center_rounded,
                              size: 56,
                              color: kContentHigh,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // App Name
              Text(
                'TRAINER',
                style: kNoirTitleLarge.copyWith(
                  letterSpacing: 8,
                  fontWeight: FontWeight.w300,
                  color: kContentHigh,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
