import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  const bg = Color(0xFF0B0B0F);
  const on = Color(0xFFE7E7EA);

  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF5B21B6), // Более темный фиолетовый
    brightness: Brightness.dark,
    // background (deprecated в 3.22+) не задаём
    surface: const Color(0xFF0F0F0F), // Более темный фон
    tertiary: const Color(0xFF06B6D4), // Более насыщенный голубой
    primary: const Color(0xFF5B21B6), // Темный фиолетовый
    secondary: const Color(0xFF1E1B4B), // Темно-синий
    error: const Color(0xFFFF6B6B), // Мягкий красный
  );

  final display = GoogleFonts.interTextTheme(base.textTheme)
      .apply(displayColor: on, bodyColor: on);
  final body = GoogleFonts.interTextTheme(base.textTheme)
      .apply(displayColor: on, bodyColor: on);

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    textTheme: body.copyWith(
      displayLarge: display.displayLarge,
      displayMedium: display.displayMedium,
      displaySmall: display.displaySmall,
      headlineLarge: display.headlineLarge,
      headlineMedium: display.headlineMedium,
      headlineSmall: display.headlineSmall,
      titleLarge: body.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.3),
      titleSmall: body.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
      bodyLarge: body.bodyLarge?.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyMedium: body.bodyMedium?.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0.1),
      bodySmall: body.bodySmall?.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0.2),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),
    // Улучшенные карточки с Material 3
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.04),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      shadowColor: Colors.black.withValues(alpha: 0.3),
    ),
    // Улучшенные поля ввода
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.8), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.error.withValues(alpha: 0.8)),
      ),
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
    ),
    // Кнопки в стиле Apple
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.2),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        foregroundColor: scheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    // Навигация в стиле Apple
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: 0.15),
      elevation: 0,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: scheme.primary, 
            fontWeight: FontWeight.w700, // Более жирный для выделения
            fontSize: 13, // Чуть больше размер
            letterSpacing: 0.3,
          );
        }
        return TextStyle(
          color: Colors.white.withValues(alpha: 0.4), // Более тусклый
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: scheme.primary, size: 26); // Больше размер для выделения
        }
        return IconThemeData(color: Colors.white.withValues(alpha: 0.4), size: 22); // Более тусклый и меньше
      }),
    ),
    // Список
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Космический фон + зерно
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CosmicBackground(),
        Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.10))),
        child,
      ],
    );
  }
}

class CosmicBackground extends StatefulWidget {
  const CosmicBackground({super.key});
  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController c;
  @override
  void initState() {
    super.initState();
    c = AnimationController(vsync: this, duration: const Duration(seconds: 26))..repeat();
  }
  @override
  void dispose() { c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) {
        final t = c.value;
        final a = Alignment(
          lerpDouble(-0.8, 0.8, (0.5 + 0.5 * math.sin(2*math.pi*t)))!,
          lerpDouble(-0.6, 0.6, (0.5 + 0.5 * math.cos(2*math.pi*t)))!,
        );
        final b = Alignment(
          lerpDouble(0.8, -0.8, (0.5 + 0.5 * math.cos(2*math.pi*t)))!,
          lerpDouble(0.6, -0.6, (0.5 + 0.5 * math.sin(2*math.pi*t)))!,
        );

        return Stack(children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: a, radius: 1.2,
                colors: [scheme.primary.withValues(alpha: 0.22), Colors.transparent],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: b, radius: 1.1,
                colors: [scheme.tertiary.withValues(alpha: 0.18), Colors.transparent],
              ),
            ),
          ),
          const GrainOverlay(opacity: 0.06),
        ]);
      },
    );
  }
}

class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key, this.opacity = 0.05});
  final double opacity;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GrainPainter(opacity), size: Size.infinite);
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.opacity);
  final double opacity; final rnd = math.Random();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    final count = (size.width * size.height / 2500).clamp(2000, 8000).toInt();
    for (int i=0; i<count; i++) {
      canvas.drawPoints(PointMode.points, [Offset(rnd.nextDouble()*size.width, rnd.nextDouble()*size.height)], paint);
    }
  }
  @override
  bool shouldRepaint(covariant _GrainPainter old) => false;
}

/// Плотное стекло
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child; final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.40), blurRadius: 24, spreadRadius: -6, offset: const Offset(0,12)),
          BoxShadow(color: Colors.white.withValues(alpha: 0.06), blurRadius: 0, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
