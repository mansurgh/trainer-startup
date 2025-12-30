import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'premium_typography.dart';

/// PulseFit Pro - Premium UI Widgets
/// Премиальные компоненты с glassmorphism, анимациями и микровзаимодействиями
class PremiumWidgets {
  
  // ===== COLORS =====
  static const Color bgPrimary = Color(0xFF000000);
  static const Color bgSecondary = Color(0xFF0A0A0A);
  static const Color surfaceCard = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF252525);
  static const Color borderSubtle = Color(0xFF2A2A2A);
  static const Color accentGlow = Color(0xFF00D9FF); // Neon cyan glow
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentSuccess = Color(0xFF00FF88);
  static const Color accentWarning = Color(0xFFFF9500);
  static const Color accentError = Color(0xFFFF3B30);

  // ===== GLASSMORPHIC CARD =====
  
  /// Премиальная карточка с blur эффектом и subtle градиентом
  static Widget glassCard({
    required Widget child,
    EdgeInsets? padding,
    double? width,
    double? height,
    VoidCallback? onTap,
    Color? glowColor,
    bool showGlow = false,
    double borderRadius = 20,
  }) {
    return GestureDetector(
      onTap: onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap();
      } : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: showGlow && glowColor != null ? [
            BoxShadow(
              color: glowColor.withOpacity(0.15),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
          ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
  
  // ===== PREMIUM BUTTON =====
  
  /// Кнопка с градиентом и shine эффектом
  static Widget premiumButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isPrimary = true,
    bool isLoading = false,
    double? width,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: isPrimary ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFE0E0E0),
                ],
              ) : null,
              color: isPrimary ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: isPrimary ? null : Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        isPrimary ? Colors.black : Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: isPrimary ? Colors.black : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: isPrimary ? Colors.black : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
  
  // ===== STAT CARD =====
  
  /// Карточка статистики с числом и лейблом
  static Widget statCard({
    required String value,
    required String label,
    IconData? icon,
    Color? accentColor,
    String? trend, // "+5%" или "-2%"
    bool isPositiveTrend = true,
  }) {
    final color = accentColor ?? Colors.white;
    
    return glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositiveTrend ? accentSuccess : accentError).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: isPositiveTrend ? accentSuccess : accentError,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
  
  // ===== PROGRESS RING =====
  
  /// Круговой прогресс с анимацией
  static Widget progressRing({
    required double progress, // 0.0 - 1.0
    required String centerText,
    String? subtitle,
    double size = 120,
    Color? progressColor,
    double strokeWidth = 10,
  }) {
    final color = progressColor ?? accentGlow;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.08)),
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: size * 0.1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  // ===== ACTIVITY HEATMAP =====
  
  /// GitHub-style activity grid
  static Widget activityHeatmap({
    required List<int> activityData, // 0-4 intensity for each day
    int weeksToShow = 12,
    Color? baseColor,
  }) {
    final color = baseColor ?? accentSuccess;
    final daysToShow = weeksToShow * 7;
    final data = activityData.length >= daysToShow 
        ? activityData.sublist(activityData.length - daysToShow)
        : List.filled(daysToShow - activityData.length, 0) + activityData;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 4),
          child: Row(
            children: _getMonthLabels(weeksToShow).map((label) => 
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ).toList(),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'].asMap().entries.map((entry) {
                // Показываем только нечётные дни
                if (entry.key % 2 == 1) {
                  return SizedBox(
                    height: 14,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 9,
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 14);
              }).toList(),
            ),
            const SizedBox(width: 4),
            // Grid
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: weeksToShow,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final intensity = data[index].clamp(0, 4);
                  return Container(
                    decoration: BoxDecoration(
                      color: _getIntensityColor(intensity, color),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  static List<String> _getMonthLabels(int weeks) {
    final now = DateTime.now();
    final labels = <String>[];
    
    for (int i = weeks - 1; i >= 0; i -= 4) {
      final date = now.subtract(Duration(days: i * 7));
      labels.add(_getMonthAbbr(date.month));
    }
    
    return labels.take(3).toList();
  }
  
  static String _getMonthAbbr(int month) {
    const months = ['', 'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 
                    'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'];
    return months[month];
  }
  
  static Color _getIntensityColor(int intensity, Color baseColor) {
    switch (intensity) {
      case 0:
        return Colors.white.withOpacity(0.05);
      case 1:
        return baseColor.withOpacity(0.25);
      case 2:
        return baseColor.withOpacity(0.5);
      case 3:
        return baseColor.withOpacity(0.75);
      case 4:
        return baseColor;
      default:
        return Colors.white.withOpacity(0.05);
    }
  }
  
  // ===== STREAK BADGE =====
  
  /// Бейдж серии тренировок
  static Widget streakBadge({
    required int streak,
    bool isAnimated = true,
    bool isRussian = true,
  }) {
    // Правильные склонения для русского языка
    String getDaysText(int days, bool russian) {
      if (!russian) return days == 1 ? 'day' : 'days';
      
      if (days % 100 >= 11 && days % 100 <= 19) return 'дней';
      switch (days % 10) {
        case 1: return 'день';
        case 2:
        case 3:
        case 4: return 'дня';
        default: return 'дней';
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$streak ${getDaysText(streak, isRussian)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                isRussian ? 'серия' : 'streak',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // ===== PERSONAL RECORD CARD =====
  
  /// Карточка личного рекорда
  static Widget personalRecordCard({
    required String exercise,
    required String value,
    required String date,
    IconData icon = Icons.emoji_events,
  }) {
    return glassCard(
      padding: const EdgeInsets.all(16),
      showGlow: true,
      glowColor: accentGold,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentGold.withOpacity(0.3),
                  accentGold.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accentGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'PR',
              style: TextStyle(
                color: accentGold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // ===== DAILY SUCCESS METER =====
  
  /// Измеритель успеха дня с несколькими параметрами
  static Widget dailySuccessMeter({
    required double willpower, // 0-1 сила воли (выполнение запланированного)
    required double intensity, // 0-1 интенсивность (насколько тяжёлые тренировки)
    required double consistency, // 0-1 консистентность (регулярность)
    String? motivationalText,
    bool isRussian = true,
  }) {
    final overallScore = ((willpower + intensity + consistency) / 3 * 100).round();
    
    return glassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRussian ? 'Успех дня' : "Today's Success",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$overallScore%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMeterBar(isRussian ? 'Сила воли' : 'Willpower', willpower, Colors.white),
          const SizedBox(height: 12),
          _buildMeterBar(isRussian ? 'Интенсивность' : 'Intensity', intensity, Colors.white),
          const SizedBox(height: 12),
          _buildMeterBar(isRussian ? 'Консистентность' : 'Consistency', consistency, Colors.white),
          if (motivationalText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('💪', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      motivationalText,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  static Widget _buildMeterBar(String label, double value, Color color) {
    // Используем нейтральные белые цвета вместо ярких
    const barColor = Colors.white;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * value,
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
  
  static Color _getScoreColor(int score) {
    if (score >= 80) return accentSuccess;
    if (score >= 60) return accentGlow;
    if (score >= 40) return accentWarning;
    return accentError;
  }
  
  // ===== SHIMMER LOADING =====
  
  /// Shimmer эффект для загрузки
  static Widget shimmerPlaceholder({
    double? width,
    double? height,
    double borderRadius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(
      duration: 1500.ms,
      color: Colors.white.withOpacity(0.1),
    );
  }
}

/// Animated value counter widget
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
  });
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          value.toString(),
          style: style ?? TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}
