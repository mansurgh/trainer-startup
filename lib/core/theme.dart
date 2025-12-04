import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: DesignTokens.primaryAccent,
    brightness: Brightness.dark,
    surface: DesignTokens.surface,
    tertiary: DesignTokens.secondaryAccent,
    primary: DesignTokens.primaryAccent,
    secondary: DesignTokens.surface,
    error: DesignTokens.error,
    onSurface: DesignTokens.textPrimary,
    onPrimary: Colors.white,
  );

  // Глобальная типографика: Inter — современный, чистый шрифт
  final display = GoogleFonts.interTextTheme(base.textTheme)
    .apply(displayColor: DesignTokens.textPrimary, bodyColor: DesignTokens.textPrimary);
  final body = GoogleFonts.interTextTheme(base.textTheme)
    .apply(displayColor: DesignTokens.textPrimary, bodyColor: DesignTokens.textSecondary);

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: DesignTokens.bgBase,
    textTheme: body.copyWith(
      displayLarge: DesignTokens.h1.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      displayMedium: DesignTokens.h2.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      displaySmall: DesignTokens.h3.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      headlineLarge: DesignTokens.h1.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      headlineMedium: DesignTokens.h2.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      headlineSmall: DesignTokens.h3.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      titleLarge: DesignTokens.h2.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      titleMedium: DesignTokens.h3.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      titleSmall: DesignTokens.bodyLarge.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      bodyLarge: DesignTokens.bodyLarge.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      bodyMedium: DesignTokens.bodyMedium.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
      bodySmall: DesignTokens.bodySmall.copyWith(fontFamily: GoogleFonts.inter().fontFamily),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),
    // Premium карточки с новыми токенами
    cardTheme: CardThemeData(
      color: DesignTokens.cardSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLarge)),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    // Улучшенные поля ввода (темно-серые)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DesignTokens.surface, // Темно-серый вместо прозрачного
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        borderSide: BorderSide(color: DesignTokens.cardSurface), // Серая рамка
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        borderSide: BorderSide(color: DesignTokens.cardSurface), // Серая рамка
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        borderSide: const BorderSide(color: DesignTokens.primaryAccent, width: 2), // Изумрудная при фокусе
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        borderSide: const BorderSide(color: DesignTokens.error),
      ),
      labelStyle: const TextStyle(color: DesignTokens.textSecondary),
      hintStyle: const TextStyle(color: DesignTokens.textTertiary),
    ),
    // Premium кнопки (темно-серые с изумрудным текстом)
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DesignTokens.cardSurface, // Темно-серый фон
        foregroundColor: DesignTokens.primaryAccent, // Изумрудный текст
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space24, vertical: DesignTokens.space16),
        textStyle: DesignTokens.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, DesignTokens.buttonHeightLarge),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignTokens.surface, // Темно-серый фон
        foregroundColor: DesignTokens.textPrimary, // Белый текст
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space24, vertical: DesignTokens.space16),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, DesignTokens.buttonHeightLarge),
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
    // Dropdown меню (темно-серое)
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide(color: DesignTokens.cardSurface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide(color: DesignTokens.cardSurface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.primaryAccent, width: 2),
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(DesignTokens.surface),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      ),
    ),
  );
}

/// Premium фон с градиентами
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: DesignTokens.backgroundGradient,
          ),
        ),
        const CosmicBackground(),
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.1))),
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
