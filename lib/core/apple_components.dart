import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'design_tokens.dart';

/// Премиум компоненты в стиле Apple
class AppleComponents {
  // Премиум кнопка в стиле Apple (темно-серая с изумрудным текстом)
  static Widget premiumButton({
    required VoidCallback? onPressed,
    required Widget child,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    bool isLoading = false,
    bool isDestructive = false,
  }) {
    final bgColor = backgroundColor ?? (isDestructive ? DesignTokens.error : DesignTokens.cardSurface);
    final fgColor = foregroundColor ?? (isDestructive ? Colors.white : DesignTokens.primaryAccent);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    child: child,
                  ),
          ),
        ),
      ),
    ).animate().scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(0.96, 0.96),
      duration: const Duration(milliseconds: 100),
    );
  }

  // Премиум карточка в стиле Apple
  static Widget premiumCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    List<BoxShadow>? shadows,
    bool enableHover = true,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
              boxShadow: shadows ?? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  // Стеклянная карточка с размытием
  static Widget glassCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    double blur = 20,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  // Премиум текст с анимацией
  static Widget premiumText(
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
      duration: const Duration(milliseconds: 600),
      delay: delay,
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 600),
      delay: delay,
    );
  }

  // Премиум индикатор прогресса
  static Widget premiumProgress({
    required double value,
    Color? backgroundColor,
    Color? valueColor,
    double height = 6,
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
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
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

  // Премиум иконка с пульсацией
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
          end: const Offset(1.05, 1.05),
          duration: duration,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  // Премиум список с анимацией
  static Widget premiumList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return child
            .animate()
            .fadeIn(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
            )
            .slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
            );
      }).toList(),
    );
  }

  // Премиум разделитель
  static Widget premiumDivider({
    Color? color,
    double height = 0.5,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 16),
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  // Премиум заголовок секции
  static Widget sectionHeader(
    String title, {
    String? subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.6),
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
}

/// Расширения для удобства использования
extension AppleWidgetExtensions on Widget {
  Widget withAppleFadeIn({Duration delay = const Duration(milliseconds: 200)}) {
    return animate()
        .fadeIn(duration: const Duration(milliseconds: 600), delay: delay)
        .slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 600), delay: delay);
  }

  Widget withAppleScale({Duration delay = const Duration(milliseconds: 200)}) {
    return animate()
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 400),
          delay: delay,
        )
        .fadeIn(duration: const Duration(milliseconds: 400), delay: delay);
  }
}
