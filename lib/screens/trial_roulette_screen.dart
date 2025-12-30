import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_tokens.dart';
import '../widgets/app_alert.dart';
import 'onboarding_screen.dart';
import 'premium_subscription_screen.dart';
import 'dart:async';

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

  final List<RouletteItem> _items = [
    RouletteItem(days: 7, probability: 0.99, color: const Color(0xFF16A34A)), // Week - 99%
    RouletteItem(days: 30, probability: 0.0033, color: const Color(0xFF2563EB)), // Month - 0.33%
    RouletteItem(days: 3, probability: 0.0033, color: const Color(0xFFEAB308)), // 3 Days - 0.33%
    RouletteItem(days: 0, probability: 0.0034, color: const Color(0xFFDC2626)), // No Luck - 0.34%
  ];

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

  Future<void> _spinRoulette() async {
    if (_isSpinning || _hasSpun) return;

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    final random = Random();
    
    // Взвешенный случайный выбор (99% шанс на неделю)
    int targetIndex = 0;
    double cumulativeProbability = 0.0;
    double rand = random.nextDouble();
    
    for (int i = 0; i < _items.length; i++) {
      cumulativeProbability += _items[i].probability;
      if (rand <= cumulativeProbability) {
        targetIndex = i;
        break;
      }
    }

    // Рассчитываем угол поворота
    // Сектора расположены по 90 градусов.
    // Item 0 (Week): Центр в -45°. Чтобы попал наверх (-90°), нужно повернуть на -45° (или 315°).
    // Item 1 (Month): Центр в 45°. Чтобы попал наверх, нужно повернуть на -135° (или 225°).
    // Item 2 (3 Days): Центр в 135°. Чтобы попал наверх, нужно повернуть на -225° (или 135°).
    // Item 3 (No Luck): Центр в 225°. Чтобы попал наверх, нужно повернуть на -315° (или 45°).
    // Формула: 315 - (index * 90)
    
    final fullRotations = 5;
    final targetAngle = (fullRotations * 360.0) + (315.0 - (targetIndex * 90.0));
    
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

    setState(() {
      _result = selectedDays;
      _isSpinning = false;
      _hasSpun = true;
    });

    // Show result
    if (mounted) {
      AppAlert.show(
        context,
        title: selectedDays > 0 ? 'Congratulations! 🎉' : 'Try Again!',
        description: selectedDays > 0 
            ? 'You won $selectedDays days of free trial!'
            : 'No luck this time, but you can still get premium!',
        type: selectedDays > 0 ? AlertType.success : AlertType.info,
        duration: const Duration(seconds: 5),
      );
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
                          // Вращающееся колесо
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
                              child: ClipOval(
                                child: Container(
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
                                  child: CustomPaint(
                                    painter: RoulettePainter(_items),
                                  ),
                                ),
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
              // Continue button - ТОЛЬКО если выпало НЕ No Luck
              else if (_result! > 0)
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
                )
              // Если No Luck - показываем ТОЛЬКО инфо о подписке
              else
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Try Again!',
                            style: DesignTokens.h3.copyWith(color: const Color(0xFFDC2626)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No luck this time, but you can still get premium!',
                            style: DesignTokens.bodySmall.copyWith(color: DesignTokens.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Кнопка перехода на Premium
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const PremiumSubscriptionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Get Premium Now',
                        style: DesignTokens.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PremiumSubscriptionScreen(),
                          ),
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
    
    double startAngle = -pi / 2; // Начинаем сверху
    final sweepAngle = (2 * pi) / items.length;

    for (int i = 0; i < items.length; i++) {
      // Рисуем сектор
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
        ..color = Colors.white.withOpacity(0.3)
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

      // Рисуем текст с улучшенной читаемостью
      final text = items[i].days > 0 ? '${items[i].days} days' : 'No Luck';
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.07, // Увеличенный размер
            fontWeight: FontWeight.w900, // Самый жирный шрифт
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
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

// Стрелка-указатель
class ArrowIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Треугольная стрелка вниз
    path.moveTo(size.width / 2, size.height); // Нижняя точка (острие)
    path.lineTo(0, 0); // Верхний левый угол
    path.lineTo(size.width, 0); // Верхний правый угол
    path.close();

    // Тень для стрелки
    canvas.drawShadow(path, Colors.black, 4, true);
    
    // Сама стрелка
    canvas.drawPath(path, paint);
    
    // Белая обводка
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
