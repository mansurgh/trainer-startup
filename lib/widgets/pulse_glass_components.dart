// =============================================================================
// pulse_glass_components.dart — Crimson Liquid Glass UI Components
// =============================================================================
// Premium sport-style glassmorphism components with aggressive red aesthetics
// Inspired by Nike/UFC, heart rate monitors, adrenaline UI
// =============================================================================

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/crimson_theme.dart';

// =============================================================================
// PULSE GLASS CARD — Dark Obsidian Glass Container
// =============================================================================

/// Premium glass card with optional crimson inner glow for active states.
/// Features:
/// - BackdropFilter blur (20px)
/// - Gradient rim light border (white/red → transparent)
/// - Optional inner crimson glow when [isActive] is true
/// - Smoked glass background with red tint
class PulseGlassCard extends StatelessWidget {
  const PulseGlassCard({
    super.key,
    required this.child,
    this.isActive = false,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = kBlurMedium,
    this.glassOpacity = kGlassOpacityMedium,
    this.showBorder = true,
    this.onTap,
    this.glowIntensity = 0.3,
  });

  final Widget child;
  final bool isActive;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double blur;
  final double glassOpacity;
  final bool showBorder;
  final VoidCallback? onTap;
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? kRadiusLG;
    
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            // Smoked glass background with red tint
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kSmokedGlass.withOpacity(glassOpacity * 4),
                kSmokedGlass.withOpacity(glassOpacity * 2),
                kObsidianSurface.withOpacity(glassOpacity * 3),
              ],
            ),
            // Rim light border
            border: showBorder
                ? Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  )
                : null,
            // Inner crimson glow when active
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: kNeonScarlet.withOpacity(glowIntensity),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: Offset.zero,
                    ),
                    BoxShadow(
                      color: kDeepCrimson.withOpacity(glowIntensity * 0.5),
                      blurRadius: 40,
                      spreadRadius: -10,
                      offset: Offset.zero,
                    ),
                  ]
                : null,
          ),
          padding: padding ?? EdgeInsets.all(kSpaceMD),
          child: child,
        ),
      ),
    );

    // Add gradient rim light overlay
    card = Stack(
      children: [
        card,
        // Rim light effect (top-left bright, bottom-right dark)
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
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

// =============================================================================
// RUBY GLASS BUTTON — Gradient Red Button with Glass Shine
// =============================================================================

/// Premium button with crimson gradient and glass shine effect.
class RubyGlassButton extends StatefulWidget {
  const RubyGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.disabled = false,
    this.gradient,
    this.showGlow = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;
  final bool isLoading;
  final bool disabled;
  final Gradient? gradient;
  final bool showGlow;

  @override
  State<RubyGlassButton> createState() => _RubyGlassButtonState();
}

class _RubyGlassButtonState extends State<RubyGlassButton>
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
    final gradient = widget.gradient ?? kCrimsonPrimaryGradient;

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
            gradient: isDisabled
                ? LinearGradient(colors: [
                    kTextDisabled,
                    kTextDisabled.withOpacity(0.8),
                  ])
                : gradient,
            borderRadius: BorderRadius.circular(kRadiusMD),
            // Crimson glow shadow
            boxShadow: widget.showGlow && !isDisabled
                ? [
                    BoxShadow(
                      color: kNeonScarlet.withOpacity(_isPressed ? 0.6 : 0.4),
                      blurRadius: _isPressed ? 28 : 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Glass shine overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kRadiusMD),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.5],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(kTextPrimary),
                        ),
                      )
                    : widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PULSE GLASS TEXT FIELD — Smoked Glass Input
// =============================================================================

/// Glass-style text field with crimson focus state.
class PulseGlassTextField extends StatefulWidget {
  const PulseGlassTextField({
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
  State<PulseGlassTextField> createState() => _PulseGlassTextFieldState();
}

class _PulseGlassTextFieldState extends State<PulseGlassTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusMD),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: kDurationFast,
          decoration: BoxDecoration(
            color: kSmokedGlass.withOpacity(_isFocused ? 0.4 : 0.25),
            borderRadius: BorderRadius.circular(kRadiusMD),
            border: Border.all(
              color: _isFocused
                  ? kNeonScarlet.withOpacity(0.8)
                  : Colors.white.withOpacity(0.1),
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: kNeonScarlet.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
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
              style: kBodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText,
                labelText: widget.labelText,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, 
                        color: _isFocused ? kNeonScarlet : kTextTertiary)
                    : null,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kSpaceMD,
                  vertical: kSpaceMD,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PULSE PROGRESS BAR — Heart Monitor Style
// =============================================================================

/// Gradient progress bar with heart monitor aesthetic.
class PulseProgressBar extends StatelessWidget {
  const PulseProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.showGlow = true,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.animated = true,
  });

  final double progress;
  final double height;
  final bool showGlow;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? borderRadius;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? height / 2;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Stack(
        children: [
          // Progress fill
          AnimatedFractionallySizedBox(
            duration: animated ? kDurationMedium : Duration.zero,
            curve: kCurveEaseOut,
            alignment: Alignment.centerLeft,
            widthFactor: clampedProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient ?? kCrimsonPrimaryGradient,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: showGlow
                    ? [
                        BoxShadow(
                          color: kNeonScarlet.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          // Shine effect
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PULSE CIRCULAR INDICATOR — Heart Rate Ring
// =============================================================================

/// Circular progress indicator with crimson gradient and glow.
class PulseCircularIndicator extends StatelessWidget {
  const PulseCircularIndicator({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.child,
    this.showGlow = true,
    this.backgroundColor,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final bool showGlow;
  final Color? backgroundColor;

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
                boxShadow: [
                  BoxShadow(
                    color: kNeonScarlet.withOpacity(0.3 * progress),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              strokeWidth: strokeWidth,
              color: backgroundColor ?? Colors.white.withOpacity(0.1),
            ),
          ),
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _GradientRingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              gradient: SweepGradient(
                startAngle: -math.pi / 2,
                endAngle: 3 * math.pi / 2,
                colors: [kDarkRuby, kDeepCrimson, kNeonScarlet, kPlasmaRed],
                stops: const [0.0, 0.3, 0.7, 1.0],
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

class _RingPainter extends CustomPainter {
  _RingPainter({
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
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
  });

  final double progress;
  final double strokeWidth;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// =============================================================================
// PULSE MESH BACKGROUND — Animated Dark Grid with Red Accents
// =============================================================================

/// Animated mesh background with subtle crimson accents.
class PulseMeshBackground extends StatefulWidget {
  const PulseMeshBackground({
    super.key,
    this.child,
    this.animated = true,
    this.showMesh = true,
    this.meshColor,
  });

  final Widget? child;
  final bool animated;
  final bool showMesh;
  final Color? meshColor;

  @override
  State<PulseMeshBackground> createState() => _PulseMeshBackgroundState();
}

class _PulseMeshBackgroundState extends State<PulseMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: kDeepBackgroundGradient,
      ),
      child: Stack(
        children: [
          // Crimson glow orb (animated)
          if (widget.animated)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final value = _controller.value;
                return Positioned(
                  left: MediaQuery.of(context).size.width * 
                      (0.3 + 0.4 * math.sin(value * 2 * math.pi)),
                  top: MediaQuery.of(context).size.height * 
                      (0.2 + 0.2 * math.cos(value * 2 * math.pi)),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          kDeepCrimson.withOpacity(0.15),
                          kDeepCrimson.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          // Secondary glow orb
          if (widget.animated)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final value = _controller.value;
                return Positioned(
                  right: MediaQuery.of(context).size.width * 
                      (0.2 + 0.3 * math.cos(value * 2 * math.pi + math.pi)),
                  bottom: MediaQuery.of(context).size.height * 
                      (0.3 + 0.2 * math.sin(value * 2 * math.pi + math.pi)),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          kNeonScarlet.withOpacity(0.1),
                          kNeonScarlet.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          // Subtle grid mesh
          if (widget.showMesh)
            Positioned.fill(
              child: CustomPaint(
                painter: _MeshPainter(
                  color: widget.meshColor ?? kCrimsonBorder.withOpacity(0.3),
                ),
              ),
            ),
          // Child content
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 40.0;

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
  bool shouldRepaint(covariant _MeshPainter oldDelegate) =>
      oldDelegate.color != color;
}

// =============================================================================
// PULSE STAT CARD — Workout Metric Display
// =============================================================================

/// Compact stat card for displaying workout metrics (calories, time, reps).
class PulseStatCard extends StatelessWidget {
  const PulseStatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.unit,
    this.isActive = false,
    this.showGlow = true,
    this.valueStyle,
  });

  final String value;
  final String label;
  final IconData? icon;
  final String? unit;
  final bool isActive;
  final bool showGlow;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return PulseGlassCard(
      isActive: isActive,
      padding: EdgeInsets.all(kSpaceMD),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and label row
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? kNeonScarlet : kTextTertiary,
                ),
                SizedBox(width: kSpaceXS),
              ],
              Text(
                label.toUpperCase(),
                style: kOverline.copyWith(
                  color: isActive ? kNeonScarlet : kTextTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: kSpaceSM),
          // Value row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: valueStyle ?? kStatsNumber.copyWith(
                  color: isActive ? kTextPrimary : kTextPrimary.withOpacity(0.9),
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: kSpaceXS),
                Text(
                  unit!,
                  style: kCaption.copyWith(
                    color: kTextSecondary,
                  ),
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
// WORKOUT SUMMARY CARD — Demo Implementation
// =============================================================================

/// Complete workout summary card showcasing the aggressive red-glass aesthetic.
class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({
    super.key,
    required this.calories,
    required this.duration,
    required this.heartRate,
    this.workoutName = 'HIIT Training',
    this.isLive = false,
  });

  final int calories;
  final Duration duration;
  final int heartRate;
  final String workoutName;
  final bool isLive;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PulseGlassCard(
      isActive: isLive,
      glowIntensity: isLive ? 0.4 : 0,
      padding: EdgeInsets.all(kSpaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Workout name with italic style
              Text(
                workoutName.toUpperCase(),
                style: kTitleMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1,
                ),
              ),
              // Live indicator
              if (isLive)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: kSpaceSM,
                    vertical: kSpaceXS,
                  ),
                  decoration: BoxDecoration(
                    gradient: kCrimsonPrimaryGradient,
                    borderRadius: BorderRadius.circular(kRadiusFull),
                    boxShadow: kCrimsonGlow(opacity: 0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: kTextPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: kSpaceXS),
                      Text(
                        'LIVE',
                        style: kOverline.copyWith(
                          color: kTextPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: kSpaceLG),
          
          // Main stats row
          Row(
            children: [
              // Duration (large)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DURATION',
                      style: kOverline.copyWith(color: kTextTertiary),
                    ),
                    SizedBox(height: kSpaceXS),
                    ShaderMask(
                      shaderCallback: (bounds) => 
                          kCrimsonPrimaryGradient.createShader(bounds),
                      child: Text(
                        _formatDuration(duration),
                        style: kDisplayLarge.copyWith(
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Divider
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.1),
              ),
              SizedBox(width: kSpaceMD),
              
              // Secondary stats
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Calories
                    _buildMiniStat(
                      icon: Icons.local_fire_department,
                      value: '$calories',
                      unit: 'kcal',
                      iconColor: kEmberOrange,
                    ),
                    SizedBox(height: kSpaceMD),
                    // Heart rate
                    _buildMiniStat(
                      icon: Icons.favorite,
                      value: '$heartRate',
                      unit: 'bpm',
                      iconColor: kNeonScarlet,
                      isActive: isLive,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: kSpaceLG),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'INTENSITY',
                    style: kOverline.copyWith(color: kTextTertiary),
                  ),
                  Text(
                    '${(heartRate / 200 * 100).round()}%',
                    style: kCaption.copyWith(
                      color: kNeonScarlet,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: kSpaceSM),
              PulseProgressBar(
                progress: heartRate / 200,
                height: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String unit,
    required Color iconColor,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(kSpaceXS),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(kRadiusSM),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        SizedBox(width: kSpaceSM),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: kDisplaySmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: kSpaceXXS),
                Text(
                  unit,
                  style: kCaption.copyWith(color: kTextTertiary),
                ),
              ],
            ),
          ],
        ),
        if (isActive)
          Padding(
            padding: EdgeInsets.only(left: kSpaceXS),
            child: _PulsingDot(),
          ),
      ],
    );
  }
}

/// Animated pulsing dot for live indicators.
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
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
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kNeonScarlet,
            boxShadow: [
              BoxShadow(
                color: kNeonScarlet.withOpacity(0.5 * _controller.value),
                blurRadius: 8 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// FLOATING NAV BAR — Glass Bottom Navigation
// =============================================================================

/// Floating glass navigation bar with crimson active states.
class PulseGlassNavBar extends StatelessWidget {
  const PulseGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<PulseNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(kSpaceMD),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: kSpaceSM,
              vertical: kSpaceSM,
            ),
            decoration: BoxDecoration(
              color: kSmokedGlass.withOpacity(0.5),
              borderRadius: BorderRadius.circular(kRadiusXL),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: kSpaceMD,
                      vertical: kSpaceSM,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? kCrimsonPrimaryGradient : null,
                      borderRadius: BorderRadius.circular(kRadiusLG),
                      boxShadow: isSelected
                          ? kCrimsonGlow(opacity: 0.3, blur: 12)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? kTextPrimary : kTextTertiary,
                          size: 24,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: kSpaceSM),
                          Text(
                            item.label,
                            style: kCaption.copyWith(
                              color: kTextPrimary,
                              fontWeight: FontWeight.w700,
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

/// Navigation item for [PulseGlassNavBar].
class PulseNavItem {
  const PulseNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
