// =============================================================================
// noir_glass_components.dart — Obsidian Glass UI Components
// =============================================================================
// Strict monochrome glassmorphism components
// No colors — only luminance, light, and shadow
// =============================================================================

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/noir_theme.dart';

// =============================================================================
// NOIR 3D GLASS CONTAINER — Premium "Cold Tech" Glass Effect
// =============================================================================
// Realistic 3D glass with:
// - Gradient fill: Top-Left (White 10%) -> Bottom-Right (Black 40%)
// - Gradient border: Top (White 30%) -> Bottom (Transparent) = "3D Light Edge"
// - BackdropFilter blur for depth
// - Cold blueish-grey shadow for "expensive" feel
// =============================================================================

/// Premium 3D Glass container with "Cold Tech" aesthetic.
/// Use for auth inputs, cards, dialogs - anywhere you want premium feel.
class Noir3DGlassContainer extends StatelessWidget {
  const Noir3DGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 15.0,
    this.isActive = false,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double blur;
  final bool isActive;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? kRadiusLG;

    Widget container = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: CustomPaint(
          painter: _Noir3DGlassBorderPainter(
            borderRadius: radius,
            isActive: isActive,
          ),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              // 3D Glass Gradient Fill: Top-Left light -> Bottom-Right dark
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x1AFFFFFF), // White 10% at top-left
                  Color(0x0DFFFFFF), // White 5% middle
                  Color(0x66000000), // Black 40% at bottom-right
                ],
                stops: [0.0, 0.4, 1.0],
              ),
              // Cold shadow for depth
              boxShadow: [
                // Primary cold shadow
                BoxShadow(
                  color: const Color(0xFF1E3A5F).withOpacity(0.3), // Cold blue-grey
                  blurRadius: 30,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
                // Subtle ambient glow
                BoxShadow(
                  color: Colors.white.withOpacity(isActive ? 0.08 : 0.03),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: padding ?? const EdgeInsets.all(kSpaceMD),
            child: child,
          ),
        ),
      ),
    );

    if (margin != null) {
      container = Padding(padding: margin!, child: container);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}

/// Custom painter for gradient border effect (3D Light Edge)
class _Noir3DGlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final bool isActive;

  _Noir3DGlassBorderPainter({
    required this.borderRadius,
    this.isActive = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Gradient border: Top (White 30%) -> Bottom (Transparent)
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x4DFFFFFF), // White 30% at top
          Color(0x1AFFFFFF), // White 10% middle
          Color(0x00FFFFFF), // Transparent at bottom
        ],
        stops: [0.0, 0.3, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 1.5 : 1.0;

    canvas.drawRRect(rrect, borderPaint);

    // Extra highlight on top edge for 3D effect
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(isActive ? 0.4 : 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw only top edge highlight
    final topEdgePath = Path()
      ..moveTo(borderRadius, 0)
      ..lineTo(size.width - borderRadius, 0);
    canvas.drawPath(topEdgePath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _Noir3DGlassBorderPainter oldDelegate) =>
      oldDelegate.isActive != isActive;
}

// =============================================================================
// NOIR 3D GLASS INPUT — Premium Text Field with Cold Glass Effect
// =============================================================================

/// Premium glass text field for auth screens.
class Noir3DGlassInput extends StatefulWidget {
  const Noir3DGlassInput({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool autofocus;

  @override
  State<Noir3DGlassInput> createState() => _Noir3DGlassInputState();
}

class _Noir3DGlassInputState extends State<Noir3DGlassInput> {
  bool _isFocused = false;
  final _focusNode = FocusNode();

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: kNoirCaption.copyWith(
              color: kContentMedium,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Noir3DGlassContainer(
          isActive: _isFocused,
          padding: EdgeInsets.zero,
          borderRadius: kRadiusMD,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            autofocus: widget.autofocus,
            style: kNoirBodyLarge.copyWith(color: kContentHigh),
            cursorColor: kContentHigh,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: kNoirBodyLarge.copyWith(color: kContentLow),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: kContentMedium, size: 22)
                  : null,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 0 : kSpaceMD,
                vertical: kSpaceMD,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// NOIR GLASS CONTAINER — Core Building Block
// =============================================================================

/// Monochrome glass container that replaces Card/Container.
/// Uses luminance (glow) instead of color for state indication.
class NoirGlassContainer extends StatelessWidget {
  const NoirGlassContainer({
    super.key,
    required this.child,
    this.isGlow = false,
    this.glowIntensity = 0.3,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = kBlurMedium,
    this.surfaceOpacity = 0.05,
    this.showBorder = true,
    this.onTap,
  });

  final Widget child;
  final bool isGlow;
  final double glowIntensity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double blur;
  final double surfaceOpacity;
  final bool showBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? kRadiusLG;

    Widget container = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            // Glass surface gradient
            gradient: kGlassGradient(opacity: surfaceOpacity),
            // Rim light border
            border: showBorder
                ? Border.all(color: kBorderLight, width: 1)
                : null,
            // White backlight glow when active
            boxShadow: isGlow
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(glowIntensity),
                      blurRadius: 30,
                      spreadRadius: -5,
                      offset: Offset.zero,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(glowIntensity * 0.3),
                      blurRadius: 60,
                      spreadRadius: 0,
                      offset: Offset.zero,
                    ),
                  ]
                : null,
          ),
          padding: padding ?? const EdgeInsets.all(kSpaceMD),
          child: child,
        ),
      ),
    );

    // Rim light overlay (white -> transparent gradient border effect)
    container = Stack(
      children: [
        container,
        if (showBorder)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: kRimLightGradient,
                ),
              ),
            ),
          ),
      ],
    );

    if (margin != null) {
      container = Padding(padding: margin!, child: container);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}

// =============================================================================
// NOIR PRIMARY BUTTON — Solid White, Black Text
// =============================================================================

class NoirPrimaryButton extends StatefulWidget {
  const NoirPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.disabled = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;
  final bool isLoading;
  final bool disabled;

  @override
  State<NoirPrimaryButton> createState() => _NoirPrimaryButtonState();
}

class _NoirPrimaryButtonState extends State<NoirPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kDurationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: kCurveEaseOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.disabled || widget.isLoading) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: isDisabled ? kNoirSlate : kNoirWhite,
            borderRadius: BorderRadius.circular(kRadiusMD),
            // Subtle glow when pressed
            boxShadow: _isPressed && !isDisabled
                ? kWhiteGlow(intensity: 0.2, blur: 16)
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        isDisabled ? kContentLow : kNoirBlack,
                      ),
                    ),
                  )
                : DefaultTextStyle(
                    style: kNoirButton.copyWith(
                      color: isDisabled ? kContentLow : kNoirBlack,
                    ),
                    child: widget.child,
                  ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// NOIR SECONDARY BUTTON — Glass with White Border
// =============================================================================

class NoirSecondaryButton extends StatefulWidget {
  const NoirSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.disabled = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;
  final bool isLoading;
  final bool disabled;

  @override
  State<NoirSecondaryButton> createState() => _NoirSecondaryButtonState();
}

class _NoirSecondaryButtonState extends State<NoirSecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.isLoading;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusMD),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: kDurationFast,
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: _isPressed
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(kRadiusMD),
              border: Border.all(
                color: isDisabled
                    ? kBorderLight
                    : (_isPressed ? kBorderGlow : kBorderMedium),
                width: 1,
              ),
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(kNoirWhite),
                      ),
                    )
                  : DefaultTextStyle(
                      style: kNoirButton.copyWith(
                        color: isDisabled ? kContentDisabled : kContentHigh,
                      ),
                      child: widget.child,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// NOIR TEXT FIELD — Glass Input
// =============================================================================

class NoirTextField extends StatefulWidget {
  const NoirTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final int maxLines;

  @override
  State<NoirTextField> createState() => _NoirTextFieldState();
}

class _NoirTextFieldState extends State<NoirTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusMD),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedContainer(
          duration: kDurationFast,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_isFocused ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(kRadiusMD),
            border: Border.all(
              color: _isFocused ? kBorderGlow : kBorderLight,
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: _isFocused ? kWhiteGlow(intensity: 0.1, blur: 12) : null,
          ),
          child: Focus(
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofocus: widget.autofocus,
              maxLines: widget.maxLines,
              style: kNoirBodyLarge,
              cursorColor: kNoirWhite,
              decoration: InputDecoration(
                hintText: widget.hintText,
                labelText: widget.labelText,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon,
                        color: _isFocused ? kContentHigh : kContentLow)
                    : null,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: kSpaceMD,
                  vertical: kSpaceMD,
                ),
                hintStyle: kNoirBodyMedium.copyWith(color: kContentLow),
                labelStyle: kNoirBodyMedium.copyWith(color: kContentMedium),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// NOIR PROGRESS BAR — White to Transparent
// =============================================================================

class NoirProgressBar extends StatelessWidget {
  const NoirProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.showGlow = false,
    this.isDashed = false,
  });

  final double progress;
  final double height;
  final bool showGlow;
  final bool isDashed;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: kNoirSlate,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          // Progress fill
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clampedProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: kProgressGradient,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: showGlow ? kWhiteGlow(intensity: 0.3, blur: 8) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// NOIR CIRCULAR INDICATOR — Monochrome Ring
// =============================================================================

class NoirCircularIndicator extends StatelessWidget {
  const NoirCircularIndicator({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.child,
    this.showGlow = false,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          if (showGlow)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: kWhiteGlow(intensity: 0.2 * progress, blur: 25),
              ),
            ),
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _NoirRingPainter(
              progress: 1.0,
              strokeWidth: strokeWidth,
              color: kNoirSlate,
            ),
          ),
          // Progress ring (white)
          CustomPaint(
            size: Size(size, size),
            painter: _NoirRingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              color: kNoirWhite,
            ),
          ),
          // Child content
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _NoirRingPainter extends CustomPainter {
  _NoirRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  final double progress;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NoirRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// =============================================================================
// NOIR STAT CARD — Massive Typography Focus
// =============================================================================

class NoirStatCard extends StatelessWidget {
  const NoirStatCard({
    super.key,
    required this.value,
    required this.label,
    this.unit,
    this.icon,
    this.isHighlighted = false,
  });

  final String value;
  final String label;
  final String? unit;
  final IconData? icon;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return NoirGlassContainer(
      isGlow: isHighlighted,
      glowIntensity: 0.2,
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label row
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isHighlighted ? kContentHigh : kContentLow,
                ),
                const SizedBox(width: kSpaceXS),
              ],
              Text(
                label.toUpperCase(),
                style: kNoirOverline.copyWith(
                  color: isHighlighted ? kContentHigh : kContentLow,
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpaceSM),
          // Value — MASSIVE typography
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: kNoirDisplayLarge.copyWith(
                  color: isHighlighted ? kContentHigh : kContentHigh.withOpacity(0.9),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: kSpaceXS),
                Text(
                  unit!,
                  style: kNoirCaption.copyWith(color: kContentMedium),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// NOIR SUCCESS INDICATOR — White Glow (Not Green!)
// =============================================================================

class NoirSuccessIndicator extends StatefulWidget {
  const NoirSuccessIndicator({
    super.key,
    this.size = 64,
    this.showAnimation = true,
  });

  final double size;
  final bool showAnimation;

  @override
  State<NoirSuccessIndicator> createState() => _NoirSuccessIndicatorState();
}

class _NoirSuccessIndicatorState extends State<NoirSuccessIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    if (widget.showAnimation) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kNoirWhite,
              // Intense white glow for success (replaces green)
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.6 * _glowAnimation.value),
                  blurRadius: 30 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.3 * _glowAnimation.value),
                  blurRadius: 60 * _glowAnimation.value,
                  spreadRadius: 10 * _glowAnimation.value,
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              size: widget.size * 0.6,
              color: kNoirBlack,
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// NOIR FLOATING NAV BAR — Black Glass Island
// =============================================================================

class NoirGlassNavBar extends StatelessWidget {
  const NoirGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NoirNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kSpaceMD),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpaceSM,
              vertical: kSpaceSM,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(kRadiusXL),
              border: Border.all(color: kBorderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;

                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: kDurationFast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpaceMD,
                      vertical: kSpaceSM,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(kRadiusLG),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          // Active = Solid White, Inactive = Grey 50%
                          color: isSelected
                              ? kNoirWhite
                              : kNoirSilver.withOpacity(0.5),
                          size: 24,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: kSpaceSM),
                          Text(
                            item.label,
                            style: kNoirCaption.copyWith(
                              color: kNoirWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NoirNavItem {
  const NoirNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// =============================================================================
// NOIR MESH BACKGROUND — Subtle Grid Pattern
// =============================================================================

class NoirMeshBackground extends StatelessWidget {
  const NoirMeshBackground({
    super.key,
    this.child,
    this.showMesh = true,
    this.showVignette = true,
  });

  final Widget? child;
  final bool showMesh;
  final bool showVignette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: kNoirBlack),
      child: Stack(
        children: [
          // Subtle mesh grid
          if (showMesh)
            Positioned.fill(
              child: CustomPaint(
                painter: _NoirMeshPainter(),
              ),
            ),
          // Vignette effect (darker edges)
          if (showVignette)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          // Child content
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _NoirMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5;

    const spacing = 50.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// NOIR DASHED LINE — For Charts (Distinguishes data without color)
// =============================================================================

class NoirDashedLine extends StatelessWidget {
  const NoirDashedLine({
    super.key,
    this.direction = Axis.horizontal,
    this.dashWidth = 4,
    this.dashSpace = 4,
    this.thickness = 1,
    this.color,
  });

  final Axis direction;
  final double dashWidth;
  final double dashSpace;
  final double thickness;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(
        direction: direction,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        thickness: thickness,
        color: color ?? kNoirSilver,
      ),
      child: direction == Axis.horizontal
          ? const SizedBox(width: double.infinity, height: 1)
          : const SizedBox(width: 1, height: double.infinity),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.direction,
    required this.dashWidth,
    required this.dashSpace,
    required this.thickness,
    required this.color,
  });

  final Axis direction;
  final double dashWidth;
  final double dashSpace;
  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    if (direction == Axis.horizontal) {
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    } else {
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + dashWidth),
          paint,
        );
        startY += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// NOIR GLASS DIALOG — Universal Dialog Component
// =============================================================================

/// Monochrome glass dialog that replaces AlertDialog.
/// Use this for ALL dialogs in the app.
/// 
/// Example:
/// ```dart
/// showDialog(
///   context: context,
///   barrierColor: Colors.black.withOpacity(0.8),
///   builder: (ctx) => NoirGlassDialog(
///     title: 'Подтверждение',
///     content: 'Вы уверены?',
///     icon: Icons.warning_rounded,
///     confirmText: 'Да',
///     cancelText: 'Нет',
///     onConfirm: () => Navigator.pop(ctx, true),
///   ),
/// );
/// ```
class NoirGlassDialog extends StatelessWidget {
  const NoirGlassDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.icon,
    this.iconColor,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
    this.isDestructive = false,
  });

  final String title;
  final String? content;
  final Widget? contentWidget;
  final IconData? icon;
  final Color? iconColor;
  final String confirmText;
  final VoidCallback onConfirm;
  final String? cancelText;
  final VoidCallback? onCancel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(kSpaceLG),
            decoration: BoxDecoration(
              color: kNoirGraphite.withOpacity(0.95),
              borderRadius: BorderRadius.circular(kRadiusXL),
              border: Border.all(color: kNoirSteel.withOpacity(0.5)),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (iconColor ?? kContentHigh).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor ?? kContentHigh, size: 32),
                    ),
                    const SizedBox(height: kSpaceMD),
                  ],
                  
                  // Title
                  Text(
                    title,
                    style: kNoirTitleMedium.copyWith(
                      color: kContentHigh,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Content
                  if (content != null) ...[
                    const SizedBox(height: kSpaceSM),
                    Text(
                      content!,
                      style: kNoirBodyMedium.copyWith(color: kContentMedium),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  // Custom content widget
                  if (contentWidget != null) ...[
                    const SizedBox(height: kSpaceMD),
                    contentWidget!,
                  ],
                  
                  const SizedBox(height: kSpaceLG),
                  
                  // Buttons
                  Row(
                    children: [
                      if (cancelText != null) ...[
                        Expanded(
                          child: TextButton(
                            onPressed: onCancel ?? () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: kContentMedium,
                              padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                            ),
                            child: Text(cancelText!),
                          ),
                        ),
                        const SizedBox(width: kSpaceMD),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDestructive 
                                ? const Color(0xFFF87171) 
                                : kContentHigh,
                            foregroundColor: isDestructive 
                                ? Colors.white 
                                : kNoirBlack,
                            padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadiusMD),
                            ),
                          ),
                          child: Text(
                            confirmText, 
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show a simple confirmation dialog
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    IconData? icon,
    String confirmText = 'Да',
    String cancelText = 'Отмена',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => NoirGlassDialog(
        title: title,
        content: content,
        icon: icon,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
  }

  /// Show a simple alert dialog (no cancel button)
  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String content,
    IconData? icon,
    String confirmText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => NoirGlassDialog(
        title: title,
        content: content,
        icon: icon,
        confirmText: confirmText,
        onConfirm: () => Navigator.pop(ctx),
      ),
    );
  }
}