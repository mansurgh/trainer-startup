import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_tokens.dart';
import '../widgets/app_alert.dart';
import 'onboarding_screen.dart';
import 'dart:async';

class TrialRouletteScreen extends ConsumerStatefulWidget {
  const TrialRouletteScreen({super.key});

  @override
  ConsumerState<TrialRouletteScreen> createState() => _TrialRouletteScreenState();
}

class _TrialRouletteScreenState extends ConsumerState<TrialRouletteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSpinning = false;
  int? _result; // null = not spun, 0 = no luck, 7/14/30 = days

  final List<RouletteItem> _items = [
    RouletteItem(days: 7, probability: 0.60, color: const Color(0xFF16A34A)), // 60%
    RouletteItem(days: 0, probability: 0.10, color: const Color(0xFFDC2626)), // 10%
    RouletteItem(days: 7, probability: 0.15, color: const Color(0xFF16A34A)), // 15%
    RouletteItem(days: 14, probability: 0.10, color: const Color(0xFF3B82F6)), // 10%
    RouletteItem(days: 7, probability: 0.04, color: const Color(0xFF16A34A)), // 4%
    RouletteItem(days: 30, probability: 0.01, color: const Color(0xFFF59E0B)), // 1%
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spinRoulette() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    // Pick result based on probabilities
    final random = Random();
    double roll = random.nextDouble();
    double cumulative = 0;
    int selectedDays = 7; // default

    for (final item in _items) {
      cumulative += item.probability;
      if (roll <= cumulative) {
        selectedDays = item.days;
        break;
      }
    }

    // Animate
    await _controller.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _result = selectedDays;
      _isSpinning = false;
    });

    // Show result
    if (selectedDays > 0) {
      if (mounted) {
        AppAlert.show(
          context,
          title: 'Congratulations! 🎉',
          description: 'You won $selectedDays days of free trial!',
          type: AlertType.success,
          duration: const Duration(seconds: 5),
        );
      }
    } else {
      if (mounted) {
        AppAlert.show(
          context,
          title: 'Not this time',
          description: 'But you can still purchase a subscription below',
          type: AlertType.info,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Title
              Text(
                'Test Your Luck!',
                style: DesignTokens.h1.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Spin the wheel for a chance to win free trial days',
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Roulette Wheel
              Expanded(
                child: Center(
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 8.0).animate(
                      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
                    ),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: DesignTokens.textPrimary,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DesignTokens.textPrimary.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CustomPaint(
                          painter: RoulettePainter(_items),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Result Display
              if (_result != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _result! > 0 
                        ? const Color(0xFF0F1F14)
                        : const Color(0xFF1F0F14),
                    border: Border.all(
                      color: _result! > 0
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _result! > 0 ? Icons.celebration : Icons.close_rounded,
                        color: _result! > 0
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _result! > 0 
                            ? '$_result Days Free Trial!' 
                            : 'No Luck This Time',
                        style: DesignTokens.h2.copyWith(
                          color: _result! > 0
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFFCA5A5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Spin Button
              if (_result == null)
                ElevatedButton(
                  onPressed: _isSpinning ? null : _spinRoulette,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.textPrimary,
                    foregroundColor: DesignTokens.bgBase,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSpinning
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.bgBase),
                          ),
                        )
                      : Text(
                          'SPIN THE WHEEL',
                          style: DesignTokens.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: DesignTokens.bgBase,
                          ),
                        ),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.textPrimary,
                    foregroundColor: DesignTokens.bgBase,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: DesignTokens.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.bgBase,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Subscription Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DesignTokens.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DesignTokens.textSecondary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Premium Subscription',
                      style: DesignTokens.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• AI Personal Trainer & Nutritionist\n'
                      '• Custom Workout Plans\n'
                      '• Meal Planning & Tracking\n'
                      '• Progress Analytics\n'
                      '• Unlimited Everything',
                      style: DesignTokens.bodySmall.copyWith(
                        color: DesignTokens.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '\$9.99/month',
                      style: DesignTokens.h2.copyWith(
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Buy Premium Button
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to payment screen
                        AppAlert.show(
                          context,
                          title: 'Coming Soon',
                          description: 'Premium subscription payment will be available soon!',
                          type: AlertType.info,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.textPrimary,
                        foregroundColor: DesignTokens.bgBase,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Buy Premium Now',
                        style: DesignTokens.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.bgBase,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouletteItem {
  final int days;
  final double probability;
  final Color color;

  RouletteItem({
    required this.days,
    required this.probability,
    required this.color,
  });
}

class RoulettePainter extends CustomPainter {
  final List<RouletteItem> items;

  RoulettePainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    double startAngle = -pi / 2;
    final sweepAngle = (2 * pi) / items.length;

    for (int i = 0; i < items.length; i++) {
      final paint = Paint()
        ..color = items[i].color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw text
      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i].days > 0 ? '${items[i].days}d' : '❌',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final angle = startAngle + sweepAngle / 2;
      final textX = center.dx + (radius * 0.6) * cos(angle) - textPainter.width / 2;
      final textY = center.dy + (radius * 0.6) * sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(textX, textY));

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
