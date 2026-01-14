// =============================================================================
// hard_paywall_screen.dart — Trial Expired Hard Paywall
// =============================================================================
// This screen is shown when the user's 7-day trial has ended and they
// have not subscribed. The user CANNOT close this screen - they must
// subscribe to continue using the app.
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/noir_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_alert.dart';
import 'premium_subscription_screen.dart';

class HardPaywallScreen extends StatefulWidget {
  const HardPaywallScreen({super.key});

  @override
  State<HardPaywallScreen> createState() => _HardPaywallScreenState();
}

class _HardPaywallScreenState extends State<HardPaywallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Prevent back button from closing
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: kNoirBlack,
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF0D0D0D),
                Color(0xFF000000),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60), // Push lock down from top

                      // Animated lock icon with glow
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final glowIntensity = 0.2 + (_pulseController.value * 0.3);
                      return Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.02),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(glowIntensity),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFFFFF),
                                  Color(0xFFB0B0B0),
                                  Color(0xFFE0E0E0),
                                  Color(0xFF909090),
                                ],
                                stops: [0.0, 0.3, 0.6, 1.0],
                              ).createShader(bounds);
                            },
                            child: const Icon(
                              Icons.lock_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                  const SizedBox(height: 48),

                  // Title
                  Text(
                    l10n.trialEnded,
                    style: kNoirDisplayMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    l10n.trialEndedSubtitle,
                    style: kNoirBodyLarge.copyWith(
                      color: kContentMedium,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms),

                  const SizedBox(height: 48),

                  // Benefits list - Noir Glass card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildBenefitRow(
                              Icons.fitness_center_rounded,
                              l10n.personalizedWorkouts,
                            ),
                            const SizedBox(height: 16),
                            _buildBenefitRow(
                              Icons.restaurant_rounded,
                              l10n.mealPlans,
                            ),
                            const SizedBox(height: 16),
                            _buildBenefitRow(
                              Icons.auto_awesome_rounded,
                              l10n.aiCoach247,
                            ),
                            const SizedBox(height: 16),
                            _buildBenefitRow(
                              Icons.trending_up_rounded,
                              l10n.progressTracking,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 48),

                  // Subscribe button - Primary CTA
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PremiumSubscriptionScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: kContentHigh,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          l10n.subscribeNow,
                          style: kNoirBodyLarge.copyWith(
                            color: kNoirBlack,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ).animate()
                      .fadeIn(duration: 600.ms, delay: 500.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // Restore purchases link
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      AppAlert.show(
                        context,
                        title: l10n.restoringPurchases,
                        description: l10n.checkingPurchases,
                        type: AlertType.info,
                      );
                      // TODO: Implement restore purchases logic
                    },
                    child: Text(
                      l10n.restorePurchases,
                      style: kNoirBodyMedium.copyWith(
                        color: kContentMedium,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ).animate()
                      .fadeIn(duration: 400.ms, delay: 600.ms),

                  const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: kContentHigh,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: kNoirBodyMedium.copyWith(
              color: kContentHigh,
            ),
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          color: const Color(0xFF4ADE80),
          size: 22,
        ),
      ],
    );
  }
}
