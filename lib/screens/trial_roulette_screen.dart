import 'dart:math' show Random, pi, cos, sin;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_service.dart';
import '../theme/noir_theme.dart';
import '../widgets/app_alert.dart';
import '../l10n/app_localizations.dart';
import 'onboarding_screen.dart';
import 'premium_subscription_screen.dart';
import 'dart:async';

// ============================================================================
// DATA MODEL
// ============================================================================
class RouletteItem {
  final int days;
  final double probability;
  final Color color;
  final int visualWeight; // Visual size weight (not probability)

  RouletteItem({
    required this.days,
    required this.probability,
    required this.color,
    this.visualWeight = 1,
  });
}

// ============================================================================
// MAIN SCREEN
// ============================================================================
class TrialRouletteScreen extends ConsumerStatefulWidget {
  const TrialRouletteScreen({super.key});

  @override
  ConsumerState<TrialRouletteScreen> createState() => _TrialRouletteScreenState();
}

class _TrialRouletteScreenState extends ConsumerState<TrialRouletteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSpinning = false;
  bool _hasSpun = false;
  int? _result; // null = not spun, 0 = no luck, 7/14/30 = days

  // NOIR Glass Wheel - Monochrome sections with white borders
  // LOGICAL probabilities: 7 days = 98%, 3 days = 1.5%, 30 days = 0.4%, No Luck = 0.1%
  // VISUAL weights: 7 days takes 50% (3/6), others 16.67% each (1/6)
  final List<RouletteItem> _items = [
    RouletteItem(days: 7, probability: 0.980, color: kNoirGraphite, visualWeight: 3), // Week - Dark gray (98% prob, 50% visual)
    RouletteItem(days: 30, probability: 0.004, color: kNoirBlack, visualWeight: 1), // Month - Black (0.4% prob, ~17% visual)
    RouletteItem(days: 3, probability: 0.015, color: kNoirSteel, visualWeight: 1), // 3 Days - Steel (1.5% prob, ~17% visual)
    RouletteItem(days: 0, probability: 0.001, color: kNoirCarbon, visualWeight: 1), // No Luck - Carbon (0.1% prob, ~17% visual)
  ];

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    // Инициализируем анимацию с начальным значением 0
    _animation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Weighted random selection based on probability distribution
  int _selectWeightedIndex() {
    final double roll = _random.nextDouble(); // 0.0 to 1.0
    double cumulative = 0.0;
    
    for (int i = 0; i < _items.length; i++) {
      cumulative += _items[i].probability;
      if (roll < cumulative) {
        return i;
      }
    }
    
    // Fallback to first item (7 days) if rounding errors
    return 0;
  }

  Future<void> _spinRoulette() async {
    if (_isSpinning || _hasSpun) return;

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    // =========================================================================
    // WEIGHTED PROBABILITY SELECTION
    // 7 Days: 98% | 3 Days: 1.5% | 30 Days: 0.4% | No Luck: 0.1%
    // =========================================================================
    final int targetIndex = _selectWeightedIndex();
    
    // Calculate target angle based on visual weights
    // Total weight = 3 + 1 + 1 + 1 = 6
    final totalWeight = _items.fold<int>(0, (sum, item) => sum + item.visualWeight);
    final degreesPerWeight = 360.0 / totalWeight;
    
    // Calculate cumulative angles to find the center of target sector
    double targetSectorStart = 0.0;
    for (int i = 0; i < targetIndex; i++) {
      targetSectorStart += _items[i].visualWeight * degreesPerWeight;
    }
    final targetSectorSweep = _items[targetIndex].visualWeight * degreesPerWeight;
    final targetSectorCenter = targetSectorStart + (targetSectorSweep / 2);
    
    // We start drawing at -90° (top), and want the center of the target sector to land at top
    // So we need to rotate by: 360 - targetSectorCenter (to bring it to top)
    const fullRotations = 5;
    final targetAngle = (fullRotations * 360.0) + (360.0 - targetSectorCenter);
    
    // Создаем анимацию с physics-based easing
    _animation = Tween<double>(
      begin: 0,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Запускаем анимацию
    _controller.reset();
    await _controller.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));

    final int selectedDays = _items[targetIndex].days;

    // Save trial to profile if user won any days
    if (selectedDays > 0) {
      try {
        await ProfileService().activateTrial(selectedDays);
      } catch (e) {
        debugPrint('[TrialRoulette] Error saving trial: $e');
      }
    }

    setState(() {
      _result = selectedDays;
      _isSpinning = false;
      _hasSpun = true;
    });

    // Show result
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppAlert.show(
        context,
        title: selectedDays > 0 ? l10n.congratulations : l10n.tryAgain,
        description: selectedDays > 0 
            ? l10n.youWonDays(selectedDays)
            : l10n.noLuckButPremium,
        type: selectedDays > 0 ? AlertType.success : AlertType.info,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: kNoirBlack,
      body: Container(
        // Noir Glass: RadialGradient for depth (dark grey center -> black edges)
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1A1A1A), // Dark grey center
              Color(0xFF0D0D0D), // Near-black
              Color(0xFF000000), // Pure black edges
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Title
                Text(
                  l10n.testYourLuck,
                  style: kNoirDisplayMedium.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.spinWheelSubtitle,
                  style: kNoirBodyLarge.copyWith(
                    color: kContentMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Roulette Wheel with Indicator
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Используем минимальное измерение для создания идеального круга
                        final size = constraints.maxWidth < constraints.maxHeight 
                            ? constraints.maxWidth * 0.8  // 80% ширины
                            : constraints.maxHeight * 0.8; // или 80% высоты
                        
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Вращающееся колесо with glass effect
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _animation.value * pi / 180,
                                  child: child,
                                );
                              },
                              child: SizedBox(
                                width: size,
                                height: size,
                                child: Stack(
                                  children: [
                                    // Main wheel
                                    ClipOval(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: kContentHigh,
                                            width: 4,
                                          ),
                                          boxShadow: [
                                            // Primary white glow
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.3),
                                              blurRadius: 40,
                                              spreadRadius: 8,
                                            ),
                                            // Secondary white glow for glass effect
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.15),
                                              blurRadius: 60,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: CustomPaint(
                                          size: Size(size, size),
                                          painter: RoulettePainter(_items),
                                        ),
                                      ),
                                    ),
                                    // Glass overlay for premium 3D effect
                                    Positioned.fill(
                                      child: ClipOval(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withOpacity(0.15),
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.1),
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Стрелка-указатель сверху (не вращается)
                            Positioned(
                              top: -10,
                              child: CustomPaint(
                                size: const Size(30, 40),
                                painter: ArrowIndicatorPainter(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Result Display - REMOVED (only toast notification shown)
                // Black message box removed per user request

                // Spin Button
                if (_result == null)
                  ElevatedButton(
                    onPressed: _isSpinning ? null : _spinRoulette,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kContentHigh,
                      foregroundColor: kNoirBlack,
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
                              valueColor: AlwaysStoppedAnimation<Color>(kNoirBlack),
                            ),
                          )
                        : Text(
                            l10n.spinTheWheel,
                            style: kNoirBodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: kNoirBlack,
                            ),
                          ),
                  )
                // Continue button - ТОЛЬКО если выпало НЕ No Luck
                else if (_result! > 0)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kContentHigh,
                      foregroundColor: kNoirBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.continueButton,
                      style: kNoirBodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: kNoirBlack,
                      ),
                    ),
                  )
                // Если No Luck - показываем ТОЛЬКО инфо о подписке
                else
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          // Noir Glass: Dark semi-transparent
                          color: kNoirCarbon.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kContentMedium.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: kContentMedium, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              l10n.tryAgain,
                              style: kNoirTitleLarge.copyWith(color: kContentHigh),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.noLuckButPremium,
                              style: kNoirBodySmall.copyWith(color: kContentMedium),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Кнопка перехода на Premium - Noir Glass style
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const PremiumSubscriptionScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kContentHigh,
                          foregroundColor: kNoirBlack,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.getPremiumNow,
                          style: kNoirBodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: kNoirBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Subscription Info - Noir Glass card (NO PRICE)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // Noir Glass: Semi-transparent frosted glass
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.premiumFeatures,
                            style: kNoirBodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: kContentHigh,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.premiumFeaturesList,
                            style: kNoirBodySmall.copyWith(
                              color: kContentMedium,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Buy Premium Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PremiumSubscriptionScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kContentHigh,
                                foregroundColor: kNoirBlack,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                l10n.buyPremiumNow,
                                style: kNoirBodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: kNoirBlack,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTERS
// ============================================================================
class RoulettePainter extends CustomPainter {
  final List<RouletteItem> items;

  RoulettePainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Calculate total visual weight for proportional sectors
    final totalWeight = items.fold<int>(0, (sum, item) => sum + item.visualWeight);
    final radiansPerWeight = (2 * pi) / totalWeight;
    
    double startAngle = -pi / 2; // Начинаем сверху

    for (int i = 0; i < items.length; i++) {
      // Sweep angle based on visual weight (7 days = 3 weights = 50%)
      final sweepAngle = items[i].visualWeight * radiansPerWeight;
      
      // Рисуем сектор с градиентом для 3D эффекта
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

      // Рисуем белую границу между секторами
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(startAngle),
          center.dy + radius * sin(startAngle),
        ),
        borderPaint,
      );

      // Рисуем текст - белый на темных секциях
      final text = items[i].days > 0 ? '${items[i].days} days' : 'No Luck';
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: kContentHigh,
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Позиционируем текст в центре сектора
      final angle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.65; // Чуть ближе к центру
      final textX = center.dx + textRadius * cos(angle) - textPainter.width / 2;
      final textY = center.dy + textRadius * sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(textX, textY));

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Стрелка-указатель с металлическим эффектом
class ArrowIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    
    // Треугольная стрелка вниз
    path.moveTo(size.width / 2, size.height); // Нижняя точка (острие)
    path.lineTo(0, 0); // Верхний левый угол
    path.lineTo(size.width, 0); // Верхний правый угол
    path.close();

    // Тень для глубины
    canvas.drawShadow(path, Colors.black, 8, true);
    
    // Металлический градиент (Chrome/Steel)
    final metallicPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE8E8E8), // Светлый хром
          Color(0xFFB8B8B8), // Средний сталь
          Color(0xFF707070), // Тёмный сталь
          Color(0xFFA0A0A0), // Отблеск
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, metallicPaint);
    
    // Белая обводка для блеска
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
    
    // Внутренний блик (highlight) на левой грани
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width / 2, size.height * 0.5))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final highlightPath = Path()
      ..moveTo(size.width / 2, size.height * 0.3)
      ..lineTo(size.width * 0.2, size.height * 0.1);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
