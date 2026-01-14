// =============================================================================
// liquid_glass_components.dart — iOS 26 Liquid Glass UI Components
// =============================================================================
// Premium glassmorphism components with "Cyber Future Blue" aesthetic:
// - LiquidGlassContainer: Core glass container with blur and rim light
// - LiquidGlassButton: Primary button with gradient and glow
// - LiquidGlassTextField: Glass capsule input field
// - LiquidGlassCard: Interactive glass card
// - LiquidGlassNavBar: Floating glass navigation bar
// - LiquidGlassAppBar: Large title header with blur
// - LiquidMeshBackground: Animated mesh gradient background
// =============================================================================

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/liquid_theme.dart';

// =============================================================================
// LIQUID GLASS CONTAINER — Core Glass Component
// =============================================================================

/// A frosted glass container with blur effect, gradient border (rim light),
/// and customizable opacity. The foundation for all glass components.
/// 
/// Use for cards, panels, and any floating UI element.
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.blur = kLiquidBlurMedium,
    this.opacity = kGlassOpacityMedium,
    this.borderOpacity = kGlassBorderOpacityMedium,
    this.gradient,
    this.glowColor,
    this.showGlow = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final Gradient? gradient;
  final Color? glowColor;
  final bool showGlow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 
        BorderRadius.circular(kLiquidRadiusLG);
    final effectivePadding = padding ?? 
        EdgeInsets.all(kLiquidSpaceMD);

    Widget container = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: effectiveBorderRadius,
            // Glass surface gradient
            gradient: gradient ?? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity * 1.5),
                Colors.white.withOpacity(opacity * 0.3),
              ],
            ),
            // Rim light border
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1,
            ),
            // Colored glow shadow
            boxShadow: showGlow ? [
              BoxShadow(
                color: (glowColor ?? kElectricBlue).withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: -8,
                offset: const Offset(0, 8),
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24,
                spreadRadius: -8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      container = Padding(padding: margin!, child: container);
    }

    if (onTap != null) {
      container = _LiquidTapWrapper(onTap: onTap!, child: container);
    }

    return container;
  }
}

// =============================================================================
// LIQUID GLASS BUTTON — Primary CTA with Gradient Glow
// =============================================================================

/// A glassmorphic button with blue-cyan gradient, inner glow,
/// and iOS-style scale-down animation on press.
class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.width,
    this.height,
    this.enabled = true,
    this.isLoading = false,
    this.variant = LiquidButtonVariant.primary,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final bool enabled;
  final bool isLoading;
  final LiquidButtonVariant variant;

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

enum LiquidButtonVariant { primary, secondary, ghost, danger }

class _LiquidGlassButtonState extends State<LiquidGlassButton>
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
    if (widget.enabled && !widget.isLoading) {
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

  Gradient get _gradient {
    if (widget.gradient != null) return widget.gradient!;
    
    switch (widget.variant) {
      case LiquidButtonVariant.primary:
        return kLiquidPrimaryGradient;
      case LiquidButtonVariant.secondary:
        return kLiquidSecondaryGradient;
      case LiquidButtonVariant.ghost:
        return LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        );
      case LiquidButtonVariant.danger:
        return LinearGradient(
          colors: [kNeonError, kNeonError.withOpacity(0.8)],
        );
    }
  }

  Color get _glowColor {
    switch (widget.variant) {
      case LiquidButtonVariant.primary:
        return kElectricBlue;
      case LiquidButtonVariant.secondary:
        return kDeepViolet;
      case LiquidButtonVariant.ghost:
        return Colors.white;
      case LiquidButtonVariant.danger:
        return kNeonError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(kLiquidRadiusMD);
    final effectivePadding = widget.padding ?? 
        EdgeInsets.symmetric(
          horizontal: kLiquidSpaceLG,
          vertical: kLiquidSpaceMD,
        );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: effectiveBorderRadius,
            gradient: widget.enabled ? _gradient : LinearGradient(
              colors: [
                Colors.grey.withOpacity(0.3),
                Colors.grey.withOpacity(0.2),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: widget.enabled ? [
              BoxShadow(
                color: _glowColor.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        kLiquidTextPrimary.withOpacity(0.8),
                      ),
                    ),
                  ),
                )
              : widget.child,
        ),
      ),
    );
  }
}

// =============================================================================
// LIQUID GLASS TEXT FIELD — Glass Capsule Input
// =============================================================================

/// A rounded text field with glass background, no underline, iOS-style.
class LiquidGlassTextField extends StatefulWidget {
  const LiquidGlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.autofocus = false,
    this.enabled = true,
    this.errorText,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final bool autofocus;
  final bool enabled;
  final String? errorText;

  @override
  State<LiquidGlassTextField> createState() => _LiquidGlassTextFieldState();
}

class _LiquidGlassTextFieldState extends State<LiquidGlassTextField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: EdgeInsets.only(
              left: kLiquidSpaceSM,
              bottom: kLiquidSpaceXS,
            ),
            child: Text(
              widget.labelText!,
              style: kLiquidCaption.copyWith(
                color: _isFocused ? kNeonCyan : kLiquidTextSecondary,
              ),
            ),
          ),
        AnimatedContainer(
          duration: kLiquidDurationFast,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_isFocused ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(kLiquidRadiusMD),
            border: Border.all(
              color: hasError 
                  ? kNeonError 
                  : _isFocused 
                      ? kNeonCyan 
                      : Colors.white.withOpacity(0.08),
              width: _isFocused || hasError ? 1.5 : 1,
            ),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: (hasError ? kNeonError : kNeonCyan).withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: -4,
              ),
            ] : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            style: kLiquidBodyLarge,
            cursorColor: kNeonCyan,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: kLiquidBodyMedium.copyWith(
                color: kLiquidTextTertiary,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused ? kNeonCyan : kLiquidTextTertiary,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: kLiquidSpaceMD,
                vertical: kLiquidSpaceMD,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(
              left: kLiquidSpaceSM,
              top: kLiquidSpaceXS,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14,
                  color: kNeonError,
                ),
                SizedBox(width: kLiquidSpaceXS),
                Text(
                  widget.errorText!,
                  style: kLiquidCaption.copyWith(color: kNeonError),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// LIQUID MESH BACKGROUND — Animated Gradient Background
// =============================================================================

/// An animated mesh gradient background with subtle floating orbs.
/// Use as the root background for screens.
class LiquidMeshBackground extends StatefulWidget {
  const LiquidMeshBackground({
    super.key,
    this.child,
    this.showOrbs = true,
    this.orbColors,
    this.intensity = 1.0,
  });

  final Widget? child;
  final bool showOrbs;
  final List<Color>? orbColors;
  final double intensity;

  @override
  State<LiquidMeshBackground> createState() => _LiquidMeshBackgroundState();
}

class _LiquidMeshBackgroundState extends State<LiquidMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base dark gradient
        Container(
          decoration: const BoxDecoration(
            gradient: kDeepBackgroundGradient,
          ),
        ),
        // Animated orbs
        if (widget.showOrbs)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => CustomPaint(
              painter: _OrbPainter(
                animation: _controller.value,
                colors: widget.orbColors ?? [
                  kElectricBlue.withOpacity(0.15 * widget.intensity),
                  kDeepViolet.withOpacity(0.1 * widget.intensity),
                  kNeonCyan.withOpacity(0.08 * widget.intensity),
                ],
              ),
              size: Size.infinite,
            ),
          ),
        // Subtle noise overlay for texture
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
        ),
        // Child content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.animation,
    required this.colors,
  });

  final double animation;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    
    // Orb 1 - Blue, top right
    final orb1Center = Offset(
      size.width * 0.8 + math.sin(animation * 2 * math.pi) * 30,
      size.height * 0.2 + math.cos(animation * 2 * math.pi) * 20,
    );
    paint.color = colors[0];
    canvas.drawCircle(orb1Center, size.width * 0.3, paint);
    
    // Orb 2 - Purple, bottom left
    final orb2Center = Offset(
      size.width * 0.2 + math.cos(animation * 2 * math.pi + 1) * 25,
      size.height * 0.7 + math.sin(animation * 2 * math.pi + 1) * 30,
    );
    paint.color = colors.length > 1 ? colors[1] : colors[0];
    canvas.drawCircle(orb2Center, size.width * 0.25, paint);
    
    // Orb 3 - Cyan, center
    if (colors.length > 2) {
      final orb3Center = Offset(
        size.width * 0.5 + math.sin(animation * 2 * math.pi + 2) * 20,
        size.height * 0.5 + math.cos(animation * 2 * math.pi + 2) * 25,
      );
      paint.color = colors[2];
      canvas.drawCircle(orb3Center, size.width * 0.2, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// =============================================================================
// LIQUID GLASS NAV BAR — Floating Island Navigation
// =============================================================================

/// A floating glass navigation bar with blur effect, island-style.
class LiquidGlassNavBar extends StatelessWidget {
  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.blur = kLiquidBlurHeavy,
    this.height = 70,
    this.margin,
  });

  final List<LiquidNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double blur;
  final double height;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final effectiveMargin = margin ?? EdgeInsets.fromLTRB(
      kLiquidSpaceMD,
      0,
      kLiquidSpaceMD,
      bottomPadding + kLiquidSpaceSM,
    );

    return Padding(
      padding: effectiveMargin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kLiquidRadiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kLiquidRadiusXL),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.06),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: kElectricBlue.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: -10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;

                return _LiquidNavButton(
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

class LiquidNavItem {
  const LiquidNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _LiquidNavButton extends StatelessWidget {
  const _LiquidNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final LiquidNavItem item;
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
              duration: kLiquidDurationFast,
              padding: const EdgeInsets.all(8),
              decoration: isSelected
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kElectricBlue.withOpacity(0.2),
                          kNeonCyan.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(kLiquidRadiusSM),
                      boxShadow: [
                        BoxShadow(
                          color: kNeonCyan.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: -4,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24,
                color: isSelected ? kNeonCyan : kLiquidTextTertiary,
              ),
            ),
            SizedBox(height: kLiquidSpaceXXS),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? kNeonCyan : kLiquidTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LIQUID GLASS APP BAR — Large Title with Blur
// =============================================================================

/// An iOS-style large title header with translucent blur on scroll.
class LiquidGlassAppBar extends StatelessWidget {
  const LiquidGlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBlur = true,
    this.blur = kLiquidBlurMedium,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBlur;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    Widget content = Padding(
      padding: EdgeInsets.fromLTRB(
        kLiquidSpaceMD,
        topPadding + kLiquidSpaceSM,
        kLiquidSpaceMD,
        kLiquidSpaceMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with leading/actions
          if (leading != null || actions != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                leading ?? const SizedBox(width: 40),
                if (actions != null)
                  Row(children: actions!)
                else
                  const SizedBox(width: 40),
              ],
            ),
          SizedBox(height: kLiquidSpaceSM),
          // Subtitle
          if (subtitle != null)
            Text(
              subtitle!,
              style: kLiquidCaption.copyWith(
                color: kLiquidTextTertiary,
                letterSpacing: 0.5,
              ),
            ),
          // Large title
          Text(
            title,
            style: kLiquidTitleLarge,
          ),
        ],
      ),
    );

    if (showBlur) {
      content = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kLiquidBlack.withOpacity(0.8),
                  kLiquidBlack.withOpacity(0.0),
                ],
              ),
            ),
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}

// =============================================================================
// LIQUID GRADIENT TEXT — Gradient Filled Text
// =============================================================================

/// Text with blue-cyan gradient fill for emphasis.
class LiquidGradientText extends StatelessWidget {
  const LiquidGradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => (gradient ?? kLiquidPrimaryGradient)
          .createShader(bounds),
      child: Text(
        text,
        style: (style ?? kLiquidTitleMedium).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

// =============================================================================
// LIQUID GLOW TEXT — Text with Neon Glow Effect
// =============================================================================

/// Text with colored shadow glow for neon effect.
class LiquidGlowText extends StatelessWidget {
  const LiquidGlowText(
    this.text, {
    super.key,
    this.style,
    this.glowColor,
    this.glowRadius = 12.0,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Color? glowColor;
  final double glowRadius;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? kNeonCyan;

    return Text(
      text,
      style: (style ?? kLiquidTitleMedium).copyWith(
        color: kLiquidTextPrimary,
        shadows: [
          Shadow(
            color: effectiveGlowColor.withOpacity(0.8),
            blurRadius: glowRadius,
          ),
          Shadow(
            color: effectiveGlowColor.withOpacity(0.4),
            blurRadius: glowRadius * 2,
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

// =============================================================================
// LIQUID PROGRESS BAR — Gradient Progress with Glow
// =============================================================================

/// Linear progress bar with blue-cyan gradient and glow effect.
class LiquidProgressBar extends StatelessWidget {
  const LiquidProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.showGlow = true,
  });

  final double value;
  final double height;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 
        BorderRadius.circular(kLiquidRadiusFull);
    final clampedValue = value.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.08),
        borderRadius: effectiveBorderRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Progress fill
              AnimatedContainer(
                duration: kLiquidDurationMedium,
                curve: kLiquidCurveEaseOut,
                width: constraints.maxWidth * clampedValue,
                decoration: BoxDecoration(
                  gradient: gradient ?? kLiquidPrimaryGradient,
                  borderRadius: effectiveBorderRadius,
                  boxShadow: showGlow
                      ? [
                          BoxShadow(
                            color: kNeonCyan.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// LIQUID CIRCULAR PROGRESS — Ring Progress with Glow
// =============================================================================

/// Circular progress indicator with gradient stroke and glow.
class LiquidCircularProgress extends StatelessWidget {
  const LiquidCircularProgress({
    super.key,
    required this.value,
    required this.size,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.gradient,
    this.child,
    this.showGlow = true,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Widget? child;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showGlow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kNeonCyan.withOpacity(0.2 * value.clamp(0.0, 1.0)),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            )
          : null,
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
                backgroundColor ?? Colors.white.withOpacity(0.08),
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
              valueColor: const AlwaysStoppedAnimation(kNeonCyan),
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
// LIQUID DIVIDER — Gradient Divider Line
// =============================================================================

/// A horizontal divider with subtle gradient fade.
class LiquidDivider extends StatelessWidget {
  const LiquidDivider({
    super.key,
    this.height = 1,
    this.margin,
    this.color,
  });

  final double height;
  final EdgeInsets? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? EdgeInsets.symmetric(vertical: kLiquidSpaceMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            (color ?? Colors.white).withOpacity(0.1),
            (color ?? Colors.white).withOpacity(0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

/// Wrapper that adds scale-down tap animation
class _LiquidTapWrapper extends StatefulWidget {
  const _LiquidTapWrapper({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_LiquidTapWrapper> createState() => _LiquidTapWrapperState();
}

class _LiquidTapWrapperState extends State<_LiquidTapWrapper>
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
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
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
// LIQUID ICON BUTTON — Glass Icon Button
// =============================================================================

/// A circular glass icon button with optional glow.
class LiquidIconButton extends StatefulWidget {
  const LiquidIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 22,
    this.color,
    this.showGlow = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final bool showGlow;

  @override
  State<LiquidIconButton> createState() => _LiquidIconButtonState();
}

class _LiquidIconButtonState extends State<LiquidIconButton>
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
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    final effectiveColor = widget.color ?? kLiquidTextPrimary;
    
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
            boxShadow: widget.showGlow
                ? [
                    BoxShadow(
                      color: effectiveColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: effectiveColor,
          ),
        ),
      ),
    );
  }
}
