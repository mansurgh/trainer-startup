import 'package:flutter/material.dart';
import '../core/design_tokens.dart';
import 'home_screen.dart';
import '../l10n/app_localizations.dart';

/// Экран "Составляем персональную программу тренировок"
/// Отображается после завершения onboarding
class GeneratingProgramScreen extends StatefulWidget {
  const GeneratingProgramScreen({super.key});

  @override
  State<GeneratingProgramScreen> createState() => _GeneratingProgramScreenState();
}

class _GeneratingProgramScreenState extends State<GeneratingProgramScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate to HomeScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: DesignTokens.bgBase,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/logo/app_logo.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/logo/trainer_mark.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  
                  // Loading indicator
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DesignTokens.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Main text
                  Text(
                    l10n.generatingProgramTitle,
                    style: DesignTokens.h2.copyWith(
                      fontSize: 22,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtext
                  Text(
                    l10n.generatingProgramSubtitle,
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
