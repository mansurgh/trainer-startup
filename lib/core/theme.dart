import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7C3AED), // deep violet
    brightness: Brightness.dark,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.black,
    textTheme: GoogleFonts.urbanistTextTheme(base.textTheme)
        .apply(displayColor: Colors.white, bodyColor: Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white24),
      ),
    ),
  );
}

/// Gradient + glow background wrapper
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            center: const Alignment(-0.6, -0.6),
            colors: [scheme.primary.withOpacity(0.25), Colors.black],
          ),
        ),
      ),
      Align(
        alignment: const Alignment(1.1, -1.0),
        child: Container(
          height: 320,
          width: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: scheme.secondary.withOpacity(0.18),
                blurRadius: 180,
                spreadRadius: 40,
              ),
            ],
          ),
        ),
      ),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),
      ),
      child,
    ]);
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(padding: padding, child: child),
        ),
      ),
    );
  }
}