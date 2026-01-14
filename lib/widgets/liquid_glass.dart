// =============================================================================
// liquid_glass.dart — iOS 26 Liquid Glass Design System
// =============================================================================
// Premium glassmorphism components with "Cyber Future Blue" aesthetic:
// - GlassCard: Frosted glass cards with blur and inner glow
// - GlassButton: Squircle buttons with scale-down animation
// - GlassTabBar: Translucent bottom navigation
// - GlassSheet: iOS-style bottom sheets with grabber
// - GlassTextField: Rounded input fields without borders
// COLOR PALETTE: Electric Blue (#2E5CFF) to Neon Cyan (#00F0FF)
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// =============================================================================
// LIQUID GLASS COLOR ALIASES (from app_theme.dart)
// =============================================================================
// Electric Blue (#2E5CFF) - kElectricBlue
// Neon Cyan (#00F0FF) - kNeonCyan
// Deep Violet (#7B2FFF) - kDeepViolet
// These are imported from app_theme.dart

// =============================================================================
// CONSTANTS
// =============================================================================

/// Squircle corner radius (iOS-style continuous corners)
const double kGlassRadiusXS = 12.0;
const double kGlassRadiusSM = 16.0;
const double kGlassRadiusMD = 20.0;
const double kGlassRadiusLG = 24.0;
const double kGlassRadiusXL = 32.0;

/// Blur intensities
const double kGlassBlurLight = 10.0;
const double kGlassBlurMedium = 20.0;
const double kGlassBlurHeavy = 40.0;

/// Glass opacity levels
const double kGlassOpacityLight = 0.05;
const double kGlassOpacityMedium = 0.08;
const double kGlassOpacityHeavy = 0.12;

/// Border opacity
const double kGlassBorderOpacity = 0.08;

// =============================================================================
// LIQUID GLASS CARD — Frosted glass container
// =============================================================================

/// A frosted glass card with blur effect and subtle inner glow.
/// 
/// Use for content sections, cards, and floating panels.
/// The card automatically adapts to dark backgrounds.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(kSpaceMD),
    this.margin,
    this.borderRadius,
    this.blur = kGlassBlurMedium,
    this.opacity = kGlassOpacityMedium,
    this.borderColor,
    this.gradient,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 
        BorderRadius.circular(kGlassRadiusLG);
    
    Widget card = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: effectiveBorderRadius,
            gradient: gradient ?? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity * 1.5),
                Colors.white.withOpacity(opacity * 0.5),
              ],
            ),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(kGlassBorderOpacity),
              width: 1,
            ),
            // Inner shadow effect using box shadow
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      card = _GlassTapWrapper(onTap: onTap!, child: card);
    }

    return card;
  }
}

// =============================================================================
// GLASS BUTTON — iOS-style squircle button
// =============================================================================

/// A glassmorphic button with iOS-style scale-down animation on press.
/// 
/// No ripple effect — uses scale transform for tactile feedback.
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(
      horizontal: kSpaceLG,
      vertical: kSpaceMD,
    ),
    this.borderRadius,
    this.color,
    this.gradient,
    this.blur = kGlassBlurLight,
    this.isExpanded = false,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final Gradient? gradient;
  final double blur;
  final bool isExpanded;
  final bool enabled;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(kGlassRadiusMD);
    
    final effectiveGradient = widget.gradient ?? LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        (widget.color ?? kElectricBlue).withOpacity(0.9),
        (widget.color ?? kNeonCyan).withOpacity(0.9),
      ],
    );

    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: effectiveBorderRadius,
                gradient: widget.enabled ? effectiveGradient : LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0.2),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: widget.enabled ? [
                  BoxShadow(
                    color: (widget.color ?? kElectricBlue).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.isExpanded) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

// =============================================================================
// GLASS TAB BAR — iOS-style translucent navigation
// =============================================================================

/// A translucent bottom tab bar with blur effect.
/// 
/// Matches iOS 15+ style with floating appearance.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.blur = kGlassBlurHeavy,
    this.height = 80,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double blur;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height + bottomPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.6),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;
                
                return _GlassTabButton(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Item data for GlassTabBar
class GlassTabItem {
  const GlassTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _GlassTabButton extends StatelessWidget {
  const _GlassTabButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final GlassTabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: isSelected ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kElectricBlue.withOpacity(0.2),
                    kNeonCyan.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(kGlassRadiusSM),
                boxShadow: [
                  BoxShadow(
                    color: kNeonCyan.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: -4,
                  ),
                ],
              ) : null,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24,
                color: isSelected ? kNeonCyan : kTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? kNeonCyan : kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// GLASS SHEET — iOS-style bottom sheet
// =============================================================================

/// Shows a glassmorphic bottom sheet with grabber handle.
/// 
/// Supports drag to dismiss and snap points.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isDismissible = true,
  bool enableDrag = true,
  double initialChildSize = 0.5,
  double minChildSize = 0.25,
  double maxChildSize = 0.9,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(kGlassRadiusXL),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: kGlassBlurHeavy, sigmaY: kGlassBlurHeavy),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kObsidianSurface.withOpacity(0.95),
                  kOledBlack.withOpacity(0.98),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Grabber handle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
                    child: builder(context),
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

// =============================================================================
// GLASS TEXT FIELD — iOS-style input field
// =============================================================================

/// A rounded text field without borders, iOS iMessage style.
class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(kGlassRadiusMD),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        autofocus: autofocus,
        style: kBodyText,
        cursorColor: kNeonCyan,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: kBodyText.copyWith(color: kTextTertiary),
          prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, color: kTextTertiary, size: 20)
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: kSpaceMD,
            vertical: kSpaceMD,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// GLASS SECTION HEADER — iOS-style section title
// =============================================================================

/// A section header with large title and optional action.
class GlassSectionHeader extends StatelessWidget {
  const GlassSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: kSpaceMD,
      vertical: kSpaceSM,
    ),
  });

  final String title;
  final String? action;
  final VoidCallback? onActionTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                action!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: kNeonCyan,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// GLASS STAT CARD — Quick stat display
// =============================================================================

/// A compact stat card with icon, value, and label.
class GlassStatCard extends StatelessWidget {
  const GlassStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.onTap,
    this.onInfoTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    Widget card = GlassCard(
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? kElectricBlue).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(kGlassRadiusSM),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? kNeonCyan,
                ),
              ),
              if (onInfoTap != null)
                GestureDetector(
                  onTap: onInfoTap,
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: kTextTertiary,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: kCaptionText.copyWith(color: kTextSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
    
    if (onTap != null) {
      return _GlassTapWrapper(onTap: onTap!, child: card);
    }
    return card;
  }
}

// =============================================================================
// GLASS AVATAR — Profile picture with glass border
// =============================================================================

/// A profile avatar with glassmorphic border effect.
class GlassAvatar extends StatelessWidget {
  const GlassAvatar({
    super.key,
    this.imageUrl,
    this.size = 80,
    this.onTap,
    this.showEditBadge = false,
  });

  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: kNeonCyan.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          if (showEditBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kElectricBlue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kOledBlack,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 12,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: kObsidianSurface,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: kTextTertiary,
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

/// Wrapper that adds scale-down tap animation
class _GlassTapWrapper extends StatefulWidget {
  const _GlassTapWrapper({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_GlassTapWrapper> createState() => _GlassTapWrapperState();
}

class _GlassTapWrapperState extends State<_GlassTapWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// =============================================================================
// GLASS LARGE TITLE — iOS-style collapsing title
// =============================================================================

/// A large title that collapses on scroll, iOS-style.
class GlassLargeTitle extends StatelessWidget {
  const GlassLargeTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceLG, kSpaceMD, kSpaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: kCaptionText.copyWith(
                      color: kTextTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// =============================================================================
// GLASS PROGRESS INDICATOR — Circular progress with glass effect
// =============================================================================

/// A circular progress indicator with glass backdrop.
class GlassCircularProgress extends StatelessWidget {
  const GlassCircularProgress({
    super.key,
    required this.value,
    required this.size,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.valueColor,
    this.child,
  });

  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                backgroundColor ?? Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Progress
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(
                valueColor ?? kNeonCyan,
              ),
            ),
          ),
          // Center content
          if (child != null) child!,
        ],
      ),
    );
  }
}

// =============================================================================
// OFFLINE BANNER — Graceful offline indicator
// =============================================================================

/// A subtle banner indicating offline mode.
class GlassOfflineBanner extends StatelessWidget {
  const GlassOfflineBanner({
    super.key,
    this.message = 'Нет подключения к сети',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpaceMD,
        vertical: kSpaceSM,
      ),
      borderColor: kNeonWarning.withOpacity(0.3),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 18,
            color: kNeonWarning,
          ),
          const SizedBox(width: kSpaceSM),
          Expanded(
            child: Text(
              message,
              style: kCaptionText.copyWith(color: kNeonWarning),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.refresh,
                  size: 18,
                  color: kNeonCyan,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
