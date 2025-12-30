import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design_tokens.dart';

/// ============================================================================
/// Unified Alert System — iOS 26 Liquid Glass Style
/// Premium glassmorphic alerts with blur and subtle animations
/// ============================================================================
class AppAlert extends StatelessWidget {
  final String title;
  final String? description;
  final AlertType type;
  final VoidCallback? onDismiss;

  const AppAlert({
    super.key,
    required this.title,
    this.description,
    this.type = AlertType.info,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getAlertConfig();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Frosted glass effect
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                config.accentColor.withOpacity(0.15),
                Colors.black.withOpacity(0.4),
              ],
            ),
            border: Border.all(
              color: config.accentColor.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with glow effect
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: config.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  config.icon,
                  color: config.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDismiss != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDismiss?.call();
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _AlertConfig _getAlertConfig() {
    switch (type) {
      case AlertType.success:
        return _AlertConfig(
          accentColor: const Color(0xFF4ADE80),
          icon: Icons.check_circle_rounded,
        );
      case AlertType.error:
        return _AlertConfig(
          accentColor: const Color(0xFFF87171),
          icon: Icons.error_rounded,
        );
      case AlertType.warning:
        return _AlertConfig(
          accentColor: const Color(0xFFFBBF24),
          icon: Icons.warning_rounded,
        );
      case AlertType.info:
        return _AlertConfig(
          accentColor: const Color(0xFF60A5FA),
          icon: Icons.info_rounded,
        );
    }
  }

  /// Show as SnackBar with Glass style
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    AlertType type = AlertType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppAlert(
          title: title,
          description: description,
          type: type,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 80), // Above tab bar
      ),
    );
  }
  
  /// Show error with automatic dismiss
  static void showError(BuildContext context, String message, {String? details}) {
    show(
      context,
      title: message,
      description: details,
      type: AlertType.error,
      duration: const Duration(seconds: 4),
    );
  }
  
  /// Show success with automatic dismiss
  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      title: message,
      type: AlertType.success,
      duration: const Duration(seconds: 2),
    );
  }
}

enum AlertType {
  success,
  error,
  warning,
  info,
}

class _AlertConfig {
  final Color accentColor;
  final IconData icon;

  _AlertConfig({
    required this.accentColor,
    required this.icon,
  });
}
