// =============================================================================
// muscle_map_svg_widget.dart — Interactive SVG-based Muscle Fatigue Map
// =============================================================================
// Production-ready implementation with:
// - flutter_svg integration
// - Stack-based layering (body_front.svg + muscle layers)
// - ColorFilter.mode with BlendMode.srcIn for dynamic coloring
// - Color.lerp interpolation (Green → Red based on fatigue)
// - GestureDetector for interactive taps
// - HapticFeedback and onMuscleTap callback
// - Gender support (male/female body variants)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import 'dart:developer' as developer;

// =============================================================================
// GENDER ENUM
// =============================================================================

enum BodyGender { male, female }

// =============================================================================
// MUSCLE MAP WIDGET — Main Component
// =============================================================================

/// Interactive SVG-based muscle fatigue map.
/// 
/// Accepts a map of muscle IDs to fatigue levels (0.0 - 1.0).
/// Renders SVG layers with dynamic color based on fatigue.
/// 
/// **Requirements:**
/// - Place SVG assets in `assets/muscles/` (male) and `assets/muscles/female/` (female)
/// - All SVGs must have same ViewBox (0 0 300 600)
/// - Muscle SVGs should be white fill (`fill="white"`)
/// 
/// **Usage:**
/// ```dart
/// MuscleMapWidget(
///   fatigueLevels: {
///     'chest': 0.7,
///     'abs': 0.3,
///     'shoulders': 0.5,
///     'arms': 0.2,
///     'legs': 0.8,
///   },
///   gender: BodyGender.female, // NEW: gender support
///   onMuscleTap: (muscleId) => print('Tapped: $muscleId'),
/// )
/// ```
class MuscleMapWidget extends StatelessWidget {
  const MuscleMapWidget({
    super.key,
    required this.fatigueLevels,
    this.onMuscleTap,
    this.showFront = true,
    this.gender = BodyGender.male,
    this.width = 280,
    this.height = 400,
  });

  /// Map of muscle ID → fatigue level (0.0 fresh, 1.0 exhausted)
  final Map<String, double> fatigueLevels;
  
  /// Callback when a muscle is tapped
  final void Function(String muscleId)? onMuscleTap;
  
  /// Show front view (true) or back view (false)
  final bool showFront;
  
  /// Body gender (male or female) for SVG selection
  final BodyGender gender;
  
  /// Widget dimensions
  final double width;
  final double height;

  /// Get asset path based on gender
  String _getAssetPath(String assetName) {
    if (gender == BodyGender.female) {
      return 'assets/muscles/female/$assetName';
    }
    return 'assets/muscles/$assetName';
  }

  @override
  Widget build(BuildContext context) {
    // Define muscle layers for front view
    final muscleLayers = showFront ? [
      _MuscleLayer(id: 'chest', asset: _getAssetPath('chest.svg')),
      _MuscleLayer(id: 'abs', asset: _getAssetPath('abs.svg')),
      _MuscleLayer(id: 'shoulders', asset: _getAssetPath('shoulders.svg')),
      _MuscleLayer(id: 'arms', asset: _getAssetPath('arms.svg')),
      _MuscleLayer(id: 'legs', asset: _getAssetPath('legs.svg')),
    ] : [
      // Back view layers
      _MuscleLayer(id: 'back', asset: _getAssetPath('back.svg')),
      _MuscleLayer(id: 'traps', asset: _getAssetPath('traps.svg')),
      _MuscleLayer(id: 'glutes', asset: _getAssetPath('glutes.svg')),
    ];

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 0: Body silhouette (gray background)
          SvgPicture.asset(
            showFront 
                ? _getAssetPath('body_front.svg')
                : _getAssetPath('body_back.svg'),
            width: width,
            height: height,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              Color(0xFF333333), // Gray
              BlendMode.srcIn,
            ),
          ),

          // Layers 1-N: Muscle overlays
          ...muscleLayers.map((layer) {
            final fatigueLevel = fatigueLevels[layer.id] ?? 0.0;
            final color = _getFatigueColor(fatigueLevel);

            return Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _handleMuscleTap(layer.id, fatigueLevel),
                child: SvgPicture.asset(
                  layer.asset,
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    color,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Get color based on fatigue level.
  /// - 0.0: Nearly transparent (slight white glow)
  /// - 0.1-1.0: Green → Red interpolation
  Color _getFatigueColor(double fatigueLevel) {
    if (fatigueLevel <= 0.0) {
      return Colors.white.withOpacity(0.1); // Barely visible
    }

    // Green for low fatigue, Red for high fatigue
    const greenColor = Color(0xFF32D74B); // kSuccessGreen
    const redColor = Color(0xFFFF453A);   // kErrorRed

    return Color.lerp(greenColor, redColor, fatigueLevel.clamp(0.0, 1.0))!;
  }

  /// Handle muscle tap with haptic feedback and callback
  void _handleMuscleTap(String muscleId, double fatigueLevel) {
    HapticFeedback.lightImpact();
    developer.log('Muscle tapped: $muscleId (fatigue: ${(fatigueLevel * 100).toInt()}%)');
    onMuscleTap?.call(muscleId);
  }
}

// =============================================================================
// MUSCLE LAYER DATA MODEL
// =============================================================================

class _MuscleLayer {
  const _MuscleLayer({
    required this.id,
    required this.asset,
  });

  final String id;
  final String asset;
}

// =============================================================================
// ADVANCED VERSION WITH TOOLTIP (Optional Enhancement)
// =============================================================================

/// Enhanced muscle map with tooltip overlay on tap.
class MuscleMapWidgetWithTooltip extends StatefulWidget {
  const MuscleMapWidgetWithTooltip({
    super.key,
    required this.fatigueLevels,
    this.muscleNames = const {},
    this.showFront = true,
    this.gender = BodyGender.male,
    this.width = 280,
    this.height = 400,
  });

  final Map<String, double> fatigueLevels;
  final Map<String, String> muscleNames; // e.g., {'chest': 'Грудь'}
  final bool showFront;
  final BodyGender gender;
  final double width;
  final double height;

  @override
  State<MuscleMapWidgetWithTooltip> createState() => _MuscleMapWidgetWithTooltipState();
}

class _MuscleMapWidgetWithTooltipState extends State<MuscleMapWidgetWithTooltip> {
  String? _selectedMuscle;
  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main muscle map
        MuscleMapWidget(
          fatigueLevels: widget.fatigueLevels,
          showFront: widget.showFront,
          gender: widget.gender,
          width: widget.width,
          height: widget.height,
          onMuscleTap: (muscleId) {
            setState(() {
              _selectedMuscle = muscleId;
              // Position tooltip at center (you can improve this with gesture details)
              _tapPosition = Offset(widget.width / 2, widget.height / 2);
            });

            // Auto-hide after 2 seconds
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _selectedMuscle = null;
                  _tapPosition = null;
                });
              }
            });
          },
        ),

        // Tooltip overlay
        if (_selectedMuscle != null && _tapPosition != null)
          Positioned(
            left: _tapPosition!.dx - 80,
            top: _tapPosition!.dy - 80,
            child: _MuscleTooltip(
              muscleId: _selectedMuscle!,
              muscleName: widget.muscleNames[_selectedMuscle] ?? _selectedMuscle!,
              fatigueLevel: widget.fatigueLevels[_selectedMuscle] ?? 0.0,
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// MUSCLE TOOLTIP
// =============================================================================

class _MuscleTooltip extends StatelessWidget {
  const _MuscleTooltip({
    required this.muscleId,
    required this.muscleName,
    required this.fatigueLevel,
  });

  final String muscleId;
  final String muscleName;
  final double fatigueLevel;

  @override
  Widget build(BuildContext context) {
    final recoveryPercent = ((1 - fatigueLevel) * 100).toInt();
    final color = _getFatigueColor(fatigueLevel);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kObsidianSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
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
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  muscleName,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Восстановление: $recoveryPercent%',
            style: const TextStyle(
              color: kTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: kObsidianBorder,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 1 - fatigueLevel,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kSuccessGreen, color],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getStatusText(fatigueLevel),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFatigueColor(double fatigueLevel) {
    if (fatigueLevel <= 0.0) return kSuccessGreen;
    return Color.lerp(kSuccessGreen, kErrorRed, fatigueLevel.clamp(0.0, 1.0))!;
  }

  String _getStatusText(double fatigueLevel) {
    if (fatigueLevel < 0.2) return 'Готово';
    if (fatigueLevel < 0.5) return 'Восстанавливается';
    if (fatigueLevel < 0.8) return 'Устало';
    return 'Истощено';
  }
}

// =============================================================================
// FALLBACK WIDGET (When SVG assets not ready)
// =============================================================================

/// Fallback widget using CustomPainter instead of SVG.
/// Use this if SVG assets are not yet prepared.
class MuscleMapFallback extends StatelessWidget {
  const MuscleMapFallback({
    super.key,
    required this.fatigueLevels,
    this.width = 280,
    this.height = 400,
  });

  final Map<String, double> fatigueLevels;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: kObsidianSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kObsidianBorder),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.accessibility_new,
              size: 64,
              color: kTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'SVG Assets Not Found',
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prepare SVG files as per\nSVG_SPECIFICATIONS.md',
              style: TextStyle(
                color: kTextTertiary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
