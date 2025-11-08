import 'package:flutter/material.dart';
import '../core/design_tokens.dart';

/// Unified Alert System inspired by shadcn/ui
/// Types: success, error, warning, info
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            config.icon,
            color: config.iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: DesignTokens.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: config.textColor,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: DesignTokens.bodySmall.copyWith(
                      color: config.textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: config.iconColor,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _AlertConfig _getAlertConfig() {
    switch (type) {
      case AlertType.success:
        return _AlertConfig(
          backgroundColor: const Color(0xFF0F1F14),
          borderColor: const Color(0xFF16A34A),
          iconColor: const Color(0xFF22C55E),
          textColor: const Color(0xFF86EFAC),
          icon: Icons.check_circle_outline,
        );
      case AlertType.error:
        return _AlertConfig(
          backgroundColor: const Color(0xFF1F0F14),
          borderColor: const Color(0xFFDC2626),
          iconColor: const Color(0xFFEF4444),
          textColor: const Color(0xFFFCA5A5),
          icon: Icons.error_outline,
        );
      case AlertType.warning:
        return _AlertConfig(
          backgroundColor: const Color(0xFF1F1B0F),
          borderColor: const Color(0xFFEA580C),
          iconColor: const Color(0xFFF97316),
          textColor: const Color(0xFFFDBA74),
          icon: Icons.warning_amber_outlined,
        );
      case AlertType.info:
        return _AlertConfig(
          backgroundColor: const Color(0xFF0F1419),
          borderColor: const Color(0xFF3B82F6),
          iconColor: const Color(0xFF60A5FA),
          textColor: const Color(0xFFBFDBFE),
          icon: Icons.info_outline,
        );
    }
  }

  /// Show as SnackBar
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    AlertType type = AlertType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
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
        margin: const EdgeInsets.only(bottom: 16),
      ),
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
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  _AlertConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}
