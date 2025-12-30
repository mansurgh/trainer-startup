// =============================================================================
// muscle_map_widget.dart — Interactive Muscle Fatigue Visualization
// =============================================================================
// Premium 3D-like body map with:
// - Stack-based muscle overlays (chest, abs, biceps, etc.)
// - Color.lerp based fatigue visualization (green → red)
// - GestureDetector for interactive tooltips
// - Animated recovery indicators
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

// =============================================================================
// MUSCLE DATA MODEL
// =============================================================================

/// Represents a single muscle group with fatigue level and metadata.
class MuscleData {
  const MuscleData({
    required this.id,
    required this.name,
    required this.localizedName,
    required this.fatigueLevel,
    this.lastWorkoutDate,
    this.recoveryHours = 48,
  });

  /// Unique identifier (e.g., 'chest', 'abs', 'biceps')
  final String id;
  
  /// English name
  final String name;
  
  /// Localized display name
  final String localizedName;
  
  /// Fatigue level from 0.0 (fresh) to 1.0 (exhausted)
  final double fatigueLevel;
  
  /// When this muscle was last trained
  final DateTime? lastWorkoutDate;
  
  /// Typical recovery time in hours
  final int recoveryHours;

  /// Recovery percentage (inverse of fatigue)
  double get recoveryPercent => (1 - fatigueLevel) * 100;
  
  /// Hours since last workout
  int? get hoursSinceWorkout {
    if (lastWorkoutDate == null) return null;
    return DateTime.now().difference(lastWorkoutDate!).inHours;
  }

  /// Human-readable recovery status
  String get statusText {
    if (fatigueLevel < 0.2) return 'Готово';
    if (fatigueLevel < 0.5) return 'Восстанавливается';
    if (fatigueLevel < 0.8) return 'Устало';
    return 'Истощено';
  }

  MuscleData copyWith({
    String? id,
    String? name,
    String? localizedName,
    double? fatigueLevel,
    DateTime? lastWorkoutDate,
    int? recoveryHours,
  }) {
    return MuscleData(
      id: id ?? this.id,
      name: name ?? this.name,
      localizedName: localizedName ?? this.localizedName,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      recoveryHours: recoveryHours ?? this.recoveryHours,
    );
  }
}

// =============================================================================
// PREDEFINED MUSCLE GROUPS
// =============================================================================

/// Standard muscle group definitions
class MuscleGroups {
  static const chest = MuscleData(
    id: 'chest',
    name: 'Chest',
    localizedName: 'Грудь',
    fatigueLevel: 0.0,
    recoveryHours: 48,
  );
  
  static const abs = MuscleData(
    id: 'abs',
    name: 'Abs',
    localizedName: 'Пресс',
    fatigueLevel: 0.0,
    recoveryHours: 24,
  );
  
  static const shoulders = MuscleData(
    id: 'shoulders',
    name: 'Shoulders',
    localizedName: 'Плечи',
    fatigueLevel: 0.0,
    recoveryHours: 48,
  );
  
  static const biceps = MuscleData(
    id: 'biceps',
    name: 'Biceps',
    localizedName: 'Бицепс',
    fatigueLevel: 0.0,
    recoveryHours: 48,
  );
  
  static const triceps = MuscleData(
    id: 'triceps',
    name: 'Triceps',
    localizedName: 'Трицепс',
    fatigueLevel: 0.0,
    recoveryHours: 48,
  );
  
  static const back = MuscleData(
    id: 'back',
    name: 'Back',
    localizedName: 'Спина',
    fatigueLevel: 0.0,
    recoveryHours: 72,
  );
  
  static const quadriceps = MuscleData(
    id: 'quadriceps',
    name: 'Quadriceps',
    localizedName: 'Квадрицепс',
    fatigueLevel: 0.0,
    recoveryHours: 72,
  );
  
  static const hamstrings = MuscleData(
    id: 'hamstrings',
    name: 'Hamstrings',
    localizedName: 'Бицепс бедра',
    fatigueLevel: 0.0,
    recoveryHours: 72,
  );
  
  static const glutes = MuscleData(
    id: 'glutes',
    name: 'Glutes',
    localizedName: 'Ягодицы',
    fatigueLevel: 0.0,
    recoveryHours: 48,
  );
  
  static const calves = MuscleData(
    id: 'calves',
    name: 'Calves',
    localizedName: 'Икры',
    fatigueLevel: 0.0,
    recoveryHours: 24,
  );
  
  static const forearms = MuscleData(
    id: 'forearms',
    name: 'Forearms',
    localizedName: 'Предплечья',
    fatigueLevel: 0.0,
    recoveryHours: 24,
  );

  /// All muscle groups for full body map
  static List<MuscleData> get all => [
    chest, abs, shoulders, biceps, triceps,
    back, quadriceps, hamstrings, glutes, calves, forearms,
  ];
}

// =============================================================================
// MUSCLE POSITION DATA — Positions for body silhouette
// =============================================================================

/// Defines where each muscle overlay should be positioned on the body silhouette.
class MusclePosition {
  const MusclePosition({
    required this.id,
    required this.rect,
    this.rotation = 0,
  });

  final String id;
  final Rect rect; // Relative coordinates (0-1 range)
  final double rotation; // Rotation in radians

  /// Convert relative rect to actual pixels
  Rect toPixels(Size size) {
    return Rect.fromLTWH(
      rect.left * size.width,
      rect.top * size.height,
      rect.width * size.width,
      rect.height * size.height,
    );
  }
}

/// Front body muscle positions (relative coordinates)
const List<MusclePosition> kFrontMusclePositions = [
  // Chest - upper torso
  MusclePosition(
    id: 'chest',
    rect: Rect.fromLTWH(0.25, 0.22, 0.50, 0.12),
  ),
  // Shoulders - left and right
  MusclePosition(
    id: 'shoulders',
    rect: Rect.fromLTWH(0.12, 0.20, 0.76, 0.08),
  ),
  // Abs - mid torso
  MusclePosition(
    id: 'abs',
    rect: Rect.fromLTWH(0.32, 0.34, 0.36, 0.16),
  ),
  // Biceps - left
  MusclePosition(
    id: 'biceps',
    rect: Rect.fromLTWH(0.08, 0.28, 0.12, 0.12),
  ),
  // Quadriceps - upper legs
  MusclePosition(
    id: 'quadriceps',
    rect: Rect.fromLTWH(0.25, 0.52, 0.50, 0.18),
  ),
  // Forearms
  MusclePosition(
    id: 'forearms',
    rect: Rect.fromLTWH(0.05, 0.40, 0.14, 0.14),
  ),
  // Calves
  MusclePosition(
    id: 'calves',
    rect: Rect.fromLTWH(0.28, 0.75, 0.44, 0.15),
  ),
];

/// Back body muscle positions
const List<MusclePosition> kBackMusclePositions = [
  // Upper back / traps
  MusclePosition(
    id: 'back',
    rect: Rect.fromLTWH(0.22, 0.22, 0.56, 0.20),
  ),
  // Triceps
  MusclePosition(
    id: 'triceps',
    rect: Rect.fromLTWH(0.08, 0.28, 0.12, 0.12),
  ),
  // Glutes
  MusclePosition(
    id: 'glutes',
    rect: Rect.fromLTWH(0.28, 0.48, 0.44, 0.10),
  ),
  // Hamstrings
  MusclePosition(
    id: 'hamstrings',
    rect: Rect.fromLTWH(0.26, 0.58, 0.48, 0.16),
  ),
];

// =============================================================================
// MUSCLE MAP WIDGET — Main Interactive Component
// =============================================================================

/// Interactive muscle fatigue visualization map.
/// Displays a body silhouette with colored muscle overlays indicating fatigue levels.
class MuscleMapWidget extends StatefulWidget {
  const MuscleMapWidget({
    super.key,
    required this.muscleData,
    this.showFront = true,
    this.onMuscleTap,
    this.width,
    this.height = 400,
    this.showLabels = false,
    this.showLegend = true,
    this.animateFatigue = true,
  });

  /// Map of muscle ID to fatigue data
  final Map<String, MuscleData> muscleData;
  
  /// Show front view (true) or back view (false)
  final bool showFront;
  
  /// Callback when a muscle is tapped
  final void Function(MuscleData muscle)? onMuscleTap;
  
  /// Widget dimensions
  final double? width;
  final double height;
  
  /// Show muscle labels on the map
  final bool showLabels;
  
  /// Show color legend at bottom
  final bool showLegend;
  
  /// Animate fatigue level changes
  final bool animateFatigue;

  @override
  State<MuscleMapWidget> createState() => _MuscleMapWidgetState();
}

class _MuscleMapWidgetState extends State<MuscleMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String? _selectedMuscleId;
  OverlayEntry? _tooltipOverlay;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: kDurationSlow,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: kCurveEaseOut,
    );
    
    if (widget.animateFatigue) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeTooltip();
    super.dispose();
  }

  void _removeTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  void _showMuscleTooltip(MuscleData muscle, Offset globalPosition) {
    _removeTooltip();
    HapticFeedback.lightImpact();
    
    setState(() {
      _selectedMuscleId = muscle.id;
    });

    _tooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: globalPosition.dx - 80,
        top: globalPosition.dy - 100,
        child: Material(
          color: Colors.transparent,
          child: _MuscleTooltip(muscle: muscle),
        ),
      ),
    );

    Overlay.of(context).insert(_tooltipOverlay!);

    // Auto-dismiss after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _selectedMuscleId == muscle.id) {
        _removeTooltip();
        setState(() {
          _selectedMuscleId = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final positions = widget.showFront 
        ? kFrontMusclePositions 
        : kBackMusclePositions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Body map
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              
              return Stack(
                children: [
                  // Body silhouette (base layer)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BodySilhouettePainter(
                        isFront: widget.showFront,
                        color: kObsidianBorder.withOpacity(0.3),
                      ),
                    ),
                  ),
                  
                  // Muscle overlays
                  ...positions.map((position) {
                    final muscle = widget.muscleData[position.id];
                    if (muscle == null) return const SizedBox.shrink();
                    
                    final pixelRect = position.toPixels(size);
                    
                    return AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Positioned(
                          left: pixelRect.left,
                          top: pixelRect.top,
                          width: pixelRect.width,
                          height: pixelRect.height,
                          child: BodyPartOverlay(
                            muscle: muscle,
                            isSelected: _selectedMuscleId == muscle.id,
                            animationValue: _fadeAnimation.value,
                            onTap: () {
                              widget.onMuscleTap?.call(muscle);
                            },
                            onLongPress: (details) {
                              _showMuscleTooltip(muscle, details.globalPosition);
                            },
                          ),
                        );
                      },
                    );
                  }),
                  
                  // Labels overlay
                  if (widget.showLabels)
                    ...positions.map((position) {
                      final muscle = widget.muscleData[position.id];
                      if (muscle == null) return const SizedBox.shrink();
                      
                      final pixelRect = position.toPixels(size);
                      
                      return Positioned(
                        left: pixelRect.center.dx - 30,
                        top: pixelRect.center.dy - 8,
                        child: Text(
                          muscle.localizedName,
                          style: kCaptionText.copyWith(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ),
        
        // Legend
        if (widget.showLegend) ...[
          const SizedBox(height: kSpaceMD),
          _FatigueLegend(),
        ],
      ],
    );
  }
}

// =============================================================================
// BODY PART OVERLAY — Single Muscle Visualization
// =============================================================================

/// Individual muscle overlay with fatigue color and interaction.
class BodyPartOverlay extends StatelessWidget {
  const BodyPartOverlay({
    super.key,
    required this.muscle,
    this.isSelected = false,
    this.animationValue = 1.0,
    this.onTap,
    this.onLongPress,
  });

  final MuscleData muscle;
  final bool isSelected;
  final double animationValue;
  final VoidCallback? onTap;
  final void Function(LongPressStartDetails details)? onLongPress;

  /// Calculate color based on fatigue level.
  /// Uses Color.lerp from green (fresh) to red (exhausted).
  Color get fatigueColor {
    final level = muscle.fatigueLevel.clamp(0.0, 1.0) * animationValue;
    
    // Multi-stop gradient: Green → Yellow → Orange → Red
    if (level < 0.33) {
      return Color.lerp(
        kSuccessGreen,
        kWarningAmber,
        level / 0.33,
      )!;
    } else if (level < 0.66) {
      return Color.lerp(
        kWarningAmber,
        const Color(0xFFFF6B35), // Orange
        (level - 0.33) / 0.33,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFFF6B35),
        kErrorRed,
        (level - 0.66) / 0.34,
      )!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      onLongPressStart: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: kDurationMedium,
        curve: kCurveEaseOut,
        decoration: BoxDecoration(
          color: fatigueColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(kRadiusMD),
          border: isSelected
              ? Border.all(color: kTextPrimary, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: fatigueColor.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: fatigueColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
        ),
      ),
    );
  }
}

// =============================================================================
// MUSCLE TOOLTIP — Popup with detailed info
// =============================================================================

class _MuscleTooltip extends StatelessWidget {
  const _MuscleTooltip({required this.muscle});

  final MuscleData muscle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(kSpaceSM),
      decoration: BoxDecoration(
        color: kObsidianSurface,
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border.all(color: kObsidianBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Muscle name
          Text(
            muscle.localizedName,
            style: kDenseSubheading.copyWith(fontSize: 14),
          ),
          const SizedBox(height: kSpaceXS),
          
          // Recovery bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kRadiusFull),
                  child: LinearProgressIndicator(
                    value: 1 - muscle.fatigueLevel,
                    backgroundColor: kObsidianBorder,
                    valueColor: AlwaysStoppedAnimation(_getStatusColor()),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: kSpaceSM),
              Text(
                '${muscle.recoveryPercent.round()}%',
                style: kCaptionText.copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpaceXS),
          
          // Status text
          Text(
            muscle.statusText,
            style: kCaptionText.copyWith(color: kTextTertiary),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (muscle.fatigueLevel < 0.2) return kSuccessGreen;
    if (muscle.fatigueLevel < 0.5) return kWarningAmber;
    if (muscle.fatigueLevel < 0.8) return const Color(0xFFFF6B35);
    return kErrorRed;
  }
}

// =============================================================================
// FATIGUE LEGEND — Color scale explanation
// =============================================================================

class _FatigueLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: kSuccessGreen, label: 'Готово'),
        const SizedBox(width: kSpaceMD),
        _LegendItem(color: kWarningAmber, label: 'Восстанавливается'),
        const SizedBox(width: kSpaceMD),
        _LegendItem(color: kErrorRed, label: 'Устало'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: kSpaceXS),
        Text(
          label,
          style: kCaptionText.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

// =============================================================================
// BODY SILHOUETTE PAINTER — CustomPainter for body outline
// =============================================================================

class _BodySilhouettePainter extends CustomPainter {
  _BodySilhouettePainter({
    required this.isFront,
    required this.color,
  });

  final bool isFront;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Simple body silhouette path (normalized to 0-1, scale to size)
    final path = _createBodyPath(size);
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }

  Path _createBodyPath(Size size) {
    final w = size.width;
    final h = size.height;
    
    final path = Path();
    
    // Head
    final headCenterX = w * 0.5;
    final headTop = h * 0.02;
    final headRadius = w * 0.08;
    path.addOval(Rect.fromCircle(
      center: Offset(headCenterX, headTop + headRadius),
      radius: headRadius,
    ));
    
    // Neck
    path.moveTo(w * 0.45, h * 0.12);
    path.lineTo(w * 0.45, h * 0.16);
    path.moveTo(w * 0.55, h * 0.12);
    path.lineTo(w * 0.55, h * 0.16);
    
    // Torso outline
    path.moveTo(w * 0.35, h * 0.16);
    path.lineTo(w * 0.15, h * 0.20); // Left shoulder
    path.lineTo(w * 0.08, h * 0.22); // Left arm start
    path.lineTo(w * 0.05, h * 0.42); // Left elbow
    path.lineTo(w * 0.02, h * 0.52); // Left hand
    path.moveTo(w * 0.15, h * 0.20);
    path.lineTo(w * 0.22, h * 0.48); // Left waist
    path.lineTo(w * 0.25, h * 0.52); // Left hip
    path.lineTo(w * 0.22, h * 0.72); // Left knee
    path.lineTo(w * 0.20, h * 0.92); // Left foot
    
    // Right side (mirrored)
    path.moveTo(w * 0.65, h * 0.16);
    path.lineTo(w * 0.85, h * 0.20); // Right shoulder
    path.lineTo(w * 0.92, h * 0.22);
    path.lineTo(w * 0.95, h * 0.42);
    path.lineTo(w * 0.98, h * 0.52);
    path.moveTo(w * 0.85, h * 0.20);
    path.lineTo(w * 0.78, h * 0.48);
    path.lineTo(w * 0.75, h * 0.52);
    path.lineTo(w * 0.78, h * 0.72);
    path.lineTo(w * 0.80, h * 0.92);
    
    // Connect torso
    path.moveTo(w * 0.35, h * 0.16);
    path.lineTo(w * 0.65, h * 0.16);
    path.moveTo(w * 0.25, h * 0.52);
    path.lineTo(w * 0.75, h * 0.52);
    
    return path;
  }

  @override
  bool shouldRepaint(covariant _BodySilhouettePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isFront != isFront;
  }
}

// =============================================================================
// COMPACT MUSCLE LIST — Alternative visualization
// =============================================================================

/// Compact list view of muscle fatigue (for use in cards/sheets).
class MuscleListWidget extends StatelessWidget {
  const MuscleListWidget({
    super.key,
    required this.muscles,
    this.onMuscleTap,
    this.maxItems = 6,
  });

  final List<MuscleData> muscles;
  final void Function(MuscleData)? onMuscleTap;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final sortedMuscles = List<MuscleData>.from(muscles)
      ..sort((a, b) => b.fatigueLevel.compareTo(a.fatigueLevel));
    
    final displayMuscles = sortedMuscles.take(maxItems).toList();

    return Column(
      children: displayMuscles.map((muscle) {
        return Padding(
          padding: const EdgeInsets.only(bottom: kSpaceSM),
          child: _MuscleListItem(
            muscle: muscle,
            onTap: () => onMuscleTap?.call(muscle),
          ),
        );
      }).toList(),
    );
  }
}

class _MuscleListItem extends StatelessWidget {
  const _MuscleListItem({
    required this.muscle,
    this.onTap,
  });

  final MuscleData muscle;
  final VoidCallback? onTap;

  Color get statusColor {
    if (muscle.fatigueLevel < 0.3) return kSuccessGreen;
    if (muscle.fatigueLevel < 0.6) return kWarningAmber;
    return kErrorRed;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpaceMD,
          vertical: kSpaceSM,
        ),
        decoration: BoxDecoration(
          color: kObsidianSurface,
          borderRadius: BorderRadius.circular(kRadiusMD),
          border: Border.all(color: kObsidianBorder),
        ),
        child: Row(
          children: [
            // Muscle indicator
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: kSpaceMD),
            
            // Name and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    muscle.localizedName,
                    style: kBodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  Text(
                    muscle.statusText,
                    style: kCaptionText.copyWith(color: statusColor),
                  ),
                ],
              ),
            ),
            
            // Progress indicator
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${muscle.recoveryPercent.round()}%',
                    style: kCaptionText.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(kRadiusFull),
                    child: LinearProgressIndicator(
                      value: 1 - muscle.fatigueLevel,
                      backgroundColor: kObsidianBorder,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DEMO / SAMPLE DATA GENERATOR
// =============================================================================

/// Generates sample muscle fatigue data for demo/preview purposes.
Map<String, MuscleData> generateSampleMuscleData() {
  final random = math.Random();
  
  return {
    for (final muscle in MuscleGroups.all)
      muscle.id: muscle.copyWith(
        fatigueLevel: random.nextDouble(),
        lastWorkoutDate: DateTime.now().subtract(
          Duration(hours: random.nextInt(96)),
        ),
      ),
  };
}
