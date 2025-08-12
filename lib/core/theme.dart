import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  // мягкая тёмная палитра без чистого #000/#FFF
  const bg = Color(0xFF0B0B0F); // почти чёрный с синеватым подтоном
  const surface = Color(0x141418); // hex-like для понимания: ~ #141418
  const onSurface = Color(0xFFE7E7EA); // не чисто белый
  const outline = Color(0x33FFFFFF);

  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7C3AED),
    brightness: Brightness.dark,
    background: bg,
    surface: const Color(0xFF121217),
    tertiary: const Color(0xFF22D3EE),
  );

  // Шрифты: заголовки — Bricolage Grotesque, текст — Manrope
  final text = base.textTheme;
  final display = GoogleFonts.bricolageGrotesqueTextTheme(text)
      .apply(displayColor: onSurface, bodyColor: onSurface);
  final body = GoogleFonts.manropeTextTheme(text)
      .apply(displayColor: onSurface, bodyColor: onSurface);

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    // комбинируем: для заголовков используем display, для остального body
    textTheme: body.copyWith(
      displayLarge: display.displayLarge,
      displayMedium: display.displayMedium,
      displaySmall: display.displaySmall,
      headlineLarge: display.headlineLarge,
      headlineMedium: display.headlineMedium,
      headlineSmall: display.headlineSmall,
      titleLarge: body.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.04),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: outline),
      ),
    ),
  );
}

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CosmicBackground(), // новый фон
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.10)), // лёгкое затемнение
        ),
         child,
      ],
    );
  }
}

/// Плавно двигающиеся “пятна” + зерно. Никаких ассетов — всё в коде.
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
    c = AnimationController(vsync: this, duration: const Duration(seconds: 26))
      ..repeat();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) {
        // Пара плавно дрейфующих градиентов
        final t = c.value;
        final a = Alignment(
          lerpDouble(-0.8, 0.8, (0.5 + 0.5 * math.sin(2 * math.pi * t)))!,
          lerpDouble(-0.6, 0.6, (0.5 + 0.5 * math.cos(2 * math.pi * t)))!,
        );
        final b = Alignment(
          lerpDouble(0.8, -0.8, (0.5 + 0.5 * math.cos(2 * math.pi * t)))!,
          lerpDouble(0.6, -0.6, (0.5 + 0.5 * math.sin(2 * math.pi * t)))!,
        );

        return Stack(
          children: [
            // Градиент 1
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: a,
                  radius: 1.2,
                  colors: [
                    scheme.primary.withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
              ),
            // Градиент 2 (бирюзовый)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: b,
                  radius: 1.1,
                  colors: [
                    scheme.tertiary.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Зерно (procedural)
            const GrainOverlay(opacity: 0.06),
          ],
        );
      },
    );
  }
}

class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key, this.opacity = 0.05});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GrainPainter(opacity),
      size: Size.infinite,
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.opacity);
  final double opacity;
  final rnd = math.Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    // редкая точечная засветка
    final count = (size.width * size.height / 2500).clamp(2000, 8000).toInt();
    for (int i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      canvas.drawPoints(PointMode.points, [Offset(x, y)], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => false;
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // плотное стекло
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
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