import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math' as math;

/// Современные компоненты с анатомией мышц
class ModernComponents {
  // Анатомия мышц для тренировок
  static Widget muscleAnatomyCard({
    required String muscleGroup,
    required String title,
    required String progress,
    required String status,
    required Color accentColor,
    required List<String> exercises,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Иконка мышцы
                _buildMuscleIcon(muscleGroup, accentColor),
                const SizedBox(height: 12),
                // Название
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Статус
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Прогресс
                _buildProgressDots(progress, accentColor),
                const SizedBox(height: 8),
                // Упражнения
                Text(
                  '${exercises.length} упражнений',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 500)).slideX(
      begin: 0.2,
      end: 0,
      duration: const Duration(milliseconds: 500),
    );
  }

  // Иконка мышцы
  static Widget _buildMuscleIcon(String muscleGroup, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getMuscleIcon(muscleGroup),
        color: color,
        size: 24,
      ),
    );
  }

  // Получить иконку для группы мышц
  static IconData _getMuscleIcon(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Icons.fitness_center;
      case 'front delts':
        return Icons.arrow_upward;
      case 'side delts':
        return Icons.arrow_forward;
      case 'back':
        return Icons.arrow_back;
      case 'legs':
        return Icons.directions_walk;
      case 'arms':
        return Icons.accessibility;
      default:
        return Icons.fitness_center;
    }
  }

  // Прогресс точки
  static Widget _buildProgressDots(String progress, Color color) {
    final parts = progress.split('+');
    final current = int.tryParse(parts[0]) ?? 0;
    final increase = int.tryParse(parts[1]) ?? 0;
    final total = current + increase;

    return Row(
      children: [
        Text(
          '$current',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '+$increase',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$total',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Сексуальная кнопка
  static Widget sexyButton({
    required VoidCallback? onPressed,
    required Widget child,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    bool isLoading = false,
    bool isDestructive = false,
  }) {
    final bgColor = backgroundColor ?? const Color(0xFF007AFF);
    final fgColor = foregroundColor ?? Colors.white;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  bgColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                : DefaultTextStyle(
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    child: child,
                  ),
          ),
        ),
      ),
    ).animate().scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(0.95, 0.95),
      duration: const Duration(milliseconds: 100),
    );
  }

  // Сексуальная карточка
  static Widget sexyCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    List<BoxShadow>? shadows,
    bool enableHover = true,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 0.5,
              ),
              boxShadow: shadows ?? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: -10,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(
      begin: 0.2,
      end: 0,
      duration: const Duration(milliseconds: 600),
    );
  }

  // Сексуальный текст
  static Widget sexyText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    Duration delay = const Duration(milliseconds: 200),
  }) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 800),
      delay: delay,
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 800),
      delay: delay,
    );
  }

  // Сексуальный прогресс бар
  static Widget sexyProgress({
    required double value,
    Color? backgroundColor,
    Color? valueColor,
    double height = 8,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  valueColor ?? const Color(0xFF007AFF),
                  (valueColor ?? const Color(0xFF007AFF)).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
            ),
          ),
        ],
      ),
    );
  }

  // Сексуальная иконка с пульсацией
  static Widget pulsingIcon(
    IconData icon, {
    Color? color,
    double size = 24,
    Duration duration = const Duration(seconds: 2),
  }) {
    return Icon(icon, color: color, size: size)
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.1, 1.1),
          duration: duration,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  // Сексуальный список
  static Widget sexyList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 150),
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return child
            .animate()
            .fadeIn(
              duration: const Duration(milliseconds: 600),
              delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
            )
            .slideY(
              begin: 0.2,
              end: 0,
              duration: const Duration(milliseconds: 600),
              delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
            );
      }).toList(),
    );
  }

  // Сексуальный разделитель
  static Widget sexyDivider({
    Color? color,
    double height = 1,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 20),
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color ?? Colors.white.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  // Сексуальный заголовок
  static Widget sexyHeader(
    String title, {
    String? subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // Кнопки
  static Widget glassButton({
    required VoidCallback onPressed,
    required Widget child,
    Color? color,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(child: child),
        ),
      ),
    );
  }

  static Widget animatedButton({
    required VoidCallback onPressed,
    required Widget child,
    Color? color,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: color != null 
            ? [color, color.withValues(alpha: 0.8)]
            : [const Color(0xFF007AFF), const Color(0xFF5B21B6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (color ?? const Color(0xFF007AFF)).withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(child: child),
        ),
      ),
    ).animate().scale(duration: 200.ms);
  }
}

/// Расширения для сексуальных эффектов
extension SexyWidgetExtensions on Widget {
  Widget withSexyFadeIn({Duration delay = const Duration(milliseconds: 200)}) {
    return animate()
        .fadeIn(duration: const Duration(milliseconds: 800), delay: delay)
        .slideY(begin: 0.2, end: 0, duration: const Duration(milliseconds: 800), delay: delay);
  }

  Widget withSexyScale({Duration delay = const Duration(milliseconds: 200)}) {
    return animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 600),
          delay: delay,
        )
        .fadeIn(duration: const Duration(milliseconds: 600), delay: delay);
  }
}
