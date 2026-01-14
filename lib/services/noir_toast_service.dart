// =============================================================================
// noir_toast_service.dart — Global Noir Glass Toast Notifications
// =============================================================================
// Unified notification system with strict Noir Glass aesthetic:
// - BackdropFilter blur effect
// - Semi-transparent dark background
// - White text with monochrome icons
// - No Material design colors (red/green/blue)
// - Debouncing to prevent duplicate toasts from rapid taps
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/noir_theme.dart';

/// Toast notification types
enum ToastType {
  success,
  error,
  info,
  warning,
}

/// Global Noir Glass Toast Service
/// 
/// Usage:
/// ```dart
/// NoirToast.show(context, 'Message saved');
/// NoirToast.success(context, 'Profile updated');
/// NoirToast.error(context, 'Failed to load data');
/// ```
class NoirToast {
  NoirToast._(); // Prevent instantiation
  
  // Debouncing: track last shown message and timestamp
  static String? _lastMessage;
  static DateTime? _lastShowTime;
  static const _debounceDelay = Duration(milliseconds: 500);

  /// Show a toast notification with Noir Glass style
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
    bool showAtTop = false,
  }) {
    // Debounce: skip if same message shown within debounce window
    final now = DateTime.now();
    if (_lastMessage == message && 
        _lastShowTime != null && 
        now.difference(_lastShowTime!) < _debounceDelay) {
      return;
    }
    
    // Update debounce tracking
    _lastMessage = message;
    _lastShowTime = now;
    
    HapticFeedback.mediumImpact();
    
    // Hide any existing toast
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Get icon and subtle accent based on type
    final config = _getConfig(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _NoirToastContent(
          message: message,
          subtitle: subtitle,
          icon: config.icon,
          iconColor: config.iconColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.only(
          bottom: showAtTop ? 0 : 100, // Above tab bar
          top: showAtTop ? 60 : 0,
          left: 16,
          right: 16,
        ),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  /// Success toast (white checkmark icon)
  static void success(BuildContext context, String message, {String? subtitle}) {
    show(context, message, type: ToastType.success, subtitle: subtitle);
  }

  /// Error toast (white error icon)
  static void error(BuildContext context, String message, {String? subtitle}) {
    show(
      context, 
      message, 
      type: ToastType.error, 
      subtitle: subtitle,
      duration: const Duration(seconds: 4),
    );
  }

  /// Info toast (white info icon)
  static void info(BuildContext context, String message, {String? subtitle}) {
    show(context, message, type: ToastType.info, subtitle: subtitle);
  }

  /// Warning toast (white warning icon)
  static void warning(BuildContext context, String message, {String? subtitle}) {
    show(context, message, type: ToastType.warning, subtitle: subtitle);
  }

  static _ToastConfig _getConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          icon: Icons.check_circle_rounded,
          iconColor: kContentHigh, // Pure white - monochrome
        );
      case ToastType.error:
        return _ToastConfig(
          icon: Icons.error_rounded,
          iconColor: kContentHigh.withOpacity(0.9), // Slightly dimmer white
        );
      case ToastType.warning:
        return _ToastConfig(
          icon: Icons.warning_rounded,
          iconColor: kContentHigh.withOpacity(0.85),
        );
      case ToastType.info:
        return _ToastConfig(
          icon: Icons.info_rounded,
          iconColor: kContentMedium,
        );
    }
  }
}

class _ToastConfig {
  final IconData icon;
  final Color iconColor;

  const _ToastConfig({
    required this.icon,
    required this.iconColor,
  });
}

/// Internal toast content widget with Noir Glass style
class _NoirToastContent extends StatelessWidget {
  const _NoirToastContent({
    required this.message,
    this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String message;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusLG),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: kBlurHeavy, sigmaY: kBlurHeavy),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpaceMD,
            vertical: kSpaceSM + 4,
          ),
          decoration: BoxDecoration(
            // Semi-transparent dark background
            color: kNoirBlack.withOpacity(0.85),
            // Subtle gradient overlay
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(kRadiusLG),
            // Subtle white border
            border: Border.all(
              color: kBorderMedium,
              width: 1,
            ),
            // Removed boxShadow to eliminate dark border effect
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with subtle glow container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusSM),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: kSpaceSM),
              
              // Text content
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: kNoirBodyMedium.copyWith(
                        color: kContentHigh,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: kNoirCaption.copyWith(
                          color: kContentMedium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
