import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'premium_components.dart';
import 'modern_components.dart';

/// Совместимый слой для временной поддержки старых SexyComponents
/// Делегирует в PremiumComponents/ModernComponents, чтобы не ломать существующие экраны.
class SexyComponents {
  static Widget sexyText(String text, {TextStyle? style}) {
    return Text(text, style: style ?? DesignTokens.bodyMedium);
  }

  static Widget sexyCard({required Widget child, VoidCallback? onTap}) {
    return PremiumComponents.glassCard(child: child, onTap: onTap);
  }

  static Widget sexyButton({
    required VoidCallback? onPressed,
    required Widget child,
    Color? backgroundColor,
  }) {
    // backgroundColor не поддерживается напрямую glassButton, оставим визуал по умолчанию
    return PremiumComponents.glassButton(
      onPressed: onPressed,
      isPrimary: backgroundColor != null,
      child: child,
    );
  }

  static Widget sexyProgress({
    required double value,
    Color? valueColor,
    double height = 6,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        backgroundColor: Colors.white.withOpacity(0.08),
        valueColor: AlwaysStoppedAnimation(valueColor ?? DesignTokens.primaryAccent),
      ),
    );
  }

  static Widget sexyHeader(String title, {String? subtitle, Widget? trailing}) {
    return ModernComponents.sexyHeader(title, subtitle: subtitle, trailing: trailing);
  }

  static Widget sexyList({required List<Widget> children}) {
    return ModernComponents.sexyList(children: children);
  }

  static Widget muscleAnatomyCard({
    required String muscleGroup,
    required String title,
    required String progress,
    required String status,
    required Color accentColor,
    required List<String> exercises,
    VoidCallback? onTap,
  }) {
    return ModernComponents.muscleAnatomyCard(
      muscleGroup: muscleGroup,
      title: title,
      progress: progress,
      status: status,
      accentColor: accentColor,
      exercises: exercises,
      onTap: onTap,
    );
  }
}
