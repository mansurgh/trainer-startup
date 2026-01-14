// =============================================================================
// noir_demo_screen.dart — Obsidian Glass Landing Screen
// =============================================================================
// Pure monochrome experience: Black canvas, white light, no color
// Typography is the hero; luminance creates hierarchy
// =============================================================================

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/noir_theme.dart';
import '../widgets/noir_glass_components.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class NoirDemoScreen extends StatefulWidget {
  const NoirDemoScreen({super.key});

  @override
  State<NoirDemoScreen> createState() => _NoirDemoScreenState();
}

class _NoirDemoScreenState extends State<NoirDemoScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Subtle white light pulse
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: NoirMeshBackground(
        showMesh: true,
        showVignette: true,
        child: Stack(
          children: [
            // Central white light source (pulsing)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Positioned(
                  top: size.height * 0.15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white
                                .withOpacity(_pulseAnimation.value * 0.15),
                            blurRadius: 150,
                            spreadRadius: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo / Brand Mark
                      _buildBrandMark(),

                      const SizedBox(height: kSpaceXL),

                      // Title
                      Text(
                        'TRAINER',
                        style: kNoirDisplayGiant.copyWith(
                          letterSpacing: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: kSpaceSM),

                      // Tagline
                      Text(
                        'PRECISION FITNESS',
                        style: kNoirOverline.copyWith(
                          color: kContentMedium,
                          letterSpacing: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(flex: 1),

                      // Feature highlights
                      _buildFeatureList(),

                      const Spacer(flex: 1),

                      // CTA Buttons
                      _buildCTAButtons(context),

                      const SizedBox(height: kSpaceXL),

                      // Legal text
                      Text(
                        'By continuing, you agree to our Terms & Privacy Policy',
                        style: kNoirCaption.copyWith(color: kContentLow),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: kSpaceLG),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandMark() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kBorderMedium, width: 2),
        boxShadow: kWhiteGlow(intensity: 0.15, blur: 40),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: kGlassGradient(opacity: 0.1),
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(50, 50),
                painter: _PulseLogoPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      ('TRACK', 'Every rep, every set'),
      ('ANALYZE', 'AI-powered insights'),
      ('TRANSFORM', 'See real results'),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: kSpaceSM),
          child: Row(
            children: [
              // Dot indicator
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: kNoirWhite,
                  shape: BoxShape.circle,
                  boxShadow: kWhiteGlow(intensity: 0.5, blur: 8),
                ),
              ),
              const SizedBox(width: kSpaceMD),
              // Feature text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.$1,
                      style: kNoirButton.copyWith(
                        color: kContentHigh,
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      feature.$2,
                      style: kNoirCaption.copyWith(color: kContentLow),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    return Column(
      children: [
        // Primary: Get Started (solid white)
        SizedBox(
          width: double.infinity,
          child: NoirPrimaryButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const RegisterScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
            child: const Text('GET STARTED'),
          ),
        ),

        const SizedBox(height: kSpaceMD),

        // Secondary: Sign In (glass)
        SizedBox(
          width: double.infinity,
          child: NoirSecondaryButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const LoginScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
            child: const Text('SIGN IN'),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Custom Painters
// =============================================================================

/// Simple abstract pulse/heartbeat logo painter
class _PulseLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kNoirWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final centerY = size.height / 2;

    // ECG-style pulse line
    path.moveTo(0, centerY);
    path.lineTo(size.width * 0.2, centerY);
    path.lineTo(size.width * 0.3, centerY - size.height * 0.15);
    path.lineTo(size.width * 0.4, centerY + size.height * 0.3);
    path.lineTo(size.width * 0.5, centerY - size.height * 0.4);
    path.lineTo(size.width * 0.6, centerY + size.height * 0.2);
    path.lineTo(size.width * 0.7, centerY);
    path.lineTo(size.width, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
