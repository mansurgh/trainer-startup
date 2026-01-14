// =============================================================================
// muscle_heatmap_widget.dart — Noir Glass Muscle Fatigue Heatmap
// =============================================================================
// Premium monochrome muscle visualization with "Ghost Stack" rendering:
// - Pass 1: Dark silhouette of ALL muscles (background)
// - Pass 2: White glow overlay for fatigued muscles (foreground)
// 
// Features:
// - SVG-based body anatomy (Male/Female)
// - Opacity-based fatigue visualization (strict monochrome)
// - Interactive tap handling with bottom sheet details
// - Smooth front/back view transitions
// - Defensive coding for missing SVG assets
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/noir_theme.dart';
import 'muscle_assets_map.dart';

// =============================================================================
// ENUMS & DATA MODELS
// =============================================================================

/// Body gender for anatomy selection
enum BodyGender { male, female }

/// Muscle group identifiers matching SVG assets
enum MuscleId {
  // Front muscles
  chest,
  abs,
  shoulders,
  biceps,
  forearms,
  quadriceps,
  // Back muscles
  back,
  traps,
  triceps,
  lats,
  glutes,
  hamstrings,
  calves,
}

/// Muscle metadata with fatigue and training info
@immutable
class MuscleInfo {
  const MuscleInfo({
    required this.id,
    required this.nameEn,
    required this.nameRu,
    required this.fatigueLevel,
    this.lastTrainedDate,
    this.recoveryHours = 48,
    this.recommendedExercises = const [],
  });

  /// Muscle identifier
  final MuscleId id;
  
  /// English name
  final String nameEn;
  
  /// Russian name
  final String nameRu;
  
  /// Fatigue level from 0.0 (fresh) to 1.0 (exhausted)
  final double fatigueLevel;
  
  /// When this muscle was last trained
  final DateTime? lastTrainedDate;
  
  /// Typical recovery time in hours
  final int recoveryHours;
  
  /// Recommended exercises for this muscle
  final List<String> recommendedExercises;

  /// Get localized name
  String getName(bool isRussian) => isRussian ? nameRu : nameEn;
  
  /// Days since last workout
  int? get daysSinceLastWorkout {
    if (lastTrainedDate == null) return null;
    return DateTime.now().difference(lastTrainedDate!).inDays;
  }
  
  /// Recovery percentage (inverse of fatigue)
  double get recoveryPercent => (1 - fatigueLevel) * 100;
  
  /// Status based on fatigue level
  MuscleStatus get status {
    if (fatigueLevel < 0.2) return MuscleStatus.fresh;
    if (fatigueLevel < 0.5) return MuscleStatus.recovering;
    if (fatigueLevel < 0.8) return MuscleStatus.fatigued;
    return MuscleStatus.exhausted;
  }

  MuscleInfo copyWith({
    MuscleId? id,
    String? nameEn,
    String? nameRu,
    double? fatigueLevel,
    DateTime? lastTrainedDate,
    int? recoveryHours,
    List<String>? recommendedExercises,
  }) {
    return MuscleInfo(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameRu: nameRu ?? this.nameRu,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      lastTrainedDate: lastTrainedDate ?? this.lastTrainedDate,
      recoveryHours: recoveryHours ?? this.recoveryHours,
      recommendedExercises: recommendedExercises ?? this.recommendedExercises,
    );
  }
}

/// Muscle recovery status
enum MuscleStatus { fresh, recovering, fatigued, exhausted }

// =============================================================================
// PREDEFINED MUSCLE DEFINITIONS
// =============================================================================

class MuscleDefinitions {
  static const Map<MuscleId, MuscleInfo> defaults = {
    MuscleId.chest: MuscleInfo(
      id: MuscleId.chest,
      nameEn: 'Chest',
      nameRu: 'Грудь',
      fatigueLevel: 0.0,
      recoveryHours: 48,
      recommendedExercises: ['Bench Press', 'Push-ups', 'Dumbbell Flyes'],
    ),
    MuscleId.abs: MuscleInfo(
      id: MuscleId.abs,
      nameEn: 'Abs',
      nameRu: 'Пресс',
      fatigueLevel: 0.0,
      recoveryHours: 24,
      recommendedExercises: ['Crunches', 'Planks', 'Leg Raises'],
    ),
    MuscleId.shoulders: MuscleInfo(
      id: MuscleId.shoulders,
      nameEn: 'Shoulders',
      nameRu: 'Плечи',
      fatigueLevel: 0.0,
      recoveryHours: 48,
      recommendedExercises: ['Shoulder Press', 'Lateral Raises', 'Front Raises'],
    ),
    MuscleId.biceps: MuscleInfo(
      id: MuscleId.biceps,
      nameEn: 'Biceps',
      nameRu: 'Бицепс',
      fatigueLevel: 0.0,
      recoveryHours: 48,
      recommendedExercises: ['Bicep Curls', 'Hammer Curls', 'Chin-ups'],
    ),
    MuscleId.forearms: MuscleInfo(
      id: MuscleId.forearms,
      nameEn: 'Forearms',
      nameRu: 'Предплечья',
      fatigueLevel: 0.0,
      recoveryHours: 24,
      recommendedExercises: ['Wrist Curls', 'Reverse Curls', 'Farmer Walks'],
    ),
    MuscleId.quadriceps: MuscleInfo(
      id: MuscleId.quadriceps,
      nameEn: 'Quadriceps',
      nameRu: 'Квадрицепс',
      fatigueLevel: 0.0,
      recoveryHours: 72,
      recommendedExercises: ['Squats', 'Leg Press', 'Lunges'],
    ),
    MuscleId.back: MuscleInfo(
      id: MuscleId.back,
      nameEn: 'Back',
      nameRu: 'Спина',
      fatigueLevel: 0.0,
      recoveryHours: 72,
      recommendedExercises: ['Pull-ups', 'Rows', 'Deadlifts'],
    ),
    MuscleId.traps: MuscleInfo(
      id: MuscleId.traps,
      nameEn: 'Traps',
      nameRu: 'Трапеции',
      fatigueLevel: 0.0,
      recoveryHours: 48,
      recommendedExercises: ['Shrugs', 'Upright Rows', 'Face Pulls'],
    ),
    MuscleId.triceps: MuscleInfo(
      id: MuscleId.triceps,
      nameEn: 'Triceps',
      nameRu: 'Трицепс',
      fatigueLevel: 0.0,
      recoveryHours: 48,
      recommendedExercises: ['Tricep Dips', 'Pushdowns', 'Skull Crushers'],
    ),
    MuscleId.lats: MuscleInfo(
      id: MuscleId.lats,
      nameEn: 'Lats',
      nameRu: 'Широчайшие',
      fatigueLevel: 0.0,
      recoveryHours: 72,
      recommendedExercises: ['Lat Pulldowns', 'Pull-ups', 'Rows'],
    ),
    MuscleId.glutes: MuscleInfo(
      id: MuscleId.glutes,
      nameEn: 'Glutes',
      nameRu: 'Ягодицы',
      fatigueLevel: 0.0,
      recoveryHours: 48,
      recommendedExercises: ['Hip Thrusts', 'Squats', 'Lunges'],
    ),
    MuscleId.hamstrings: MuscleInfo(
      id: MuscleId.hamstrings,
      nameEn: 'Hamstrings',
      nameRu: 'Бицепс бедра',
      fatigueLevel: 0.0,
      recoveryHours: 72,
      recommendedExercises: ['Romanian Deadlifts', 'Leg Curls', 'Good Mornings'],
    ),
    MuscleId.calves: MuscleInfo(
      id: MuscleId.calves,
      nameEn: 'Calves',
      nameRu: 'Икры',
      fatigueLevel: 0.0,
      recoveryHours: 24,
      recommendedExercises: ['Calf Raises', 'Seated Calf Raises', 'Jump Rope'],
    ),
  };
  
  /// Get muscle info with custom fatigue level
  static MuscleInfo withFatigue(MuscleId id, double fatigue, {DateTime? lastTrained}) {
    final base = defaults[id]!;
    return base.copyWith(
      fatigueLevel: fatigue.clamp(0.0, 1.0),
      lastTrainedDate: lastTrained,
    );
  }
}

// =============================================================================
// MUSCLE HEATMAP WIDGET — Main Component
// =============================================================================

/// Interactive muscle heatmap with Noir Glass aesthetic.
/// 
/// Features:
/// - Male/Female body anatomy
/// - Front/Back view toggle
/// - Monochrome fatigue visualization (opacity-based)
/// - Tap interaction with detail bottom sheet
/// 
/// ```dart
/// MuscleHeatmapWidget(
///   gender: BodyGender.male,
///   fatigueMap: {
///     MuscleId.chest: 0.7,
///     MuscleId.abs: 0.3,
///   },
///   onMuscleTap: (info) => showMuscleDetails(info),
/// )
/// ```
class MuscleHeatmapWidget extends StatefulWidget {
  const MuscleHeatmapWidget({
    super.key,
    required this.fatigueMap,
    this.gender = BodyGender.male,
    this.initialBackView = false,
    this.onMuscleTap,
    this.showViewToggle = true,
    this.showLegend = true,
    this.width,
    this.height = 400,
  });

  /// Map of muscle ID to fatigue level (0.0-1.0)
  final Map<MuscleId, double> fatigueMap;
  
  /// Body gender (affects anatomy SVGs)
  final BodyGender gender;
  
  /// Start with back view
  final bool initialBackView;
  
  /// Callback when muscle is tapped (receives full muscle info)
  final void Function(MuscleInfo muscle)? onMuscleTap;
  
  /// Show front/back toggle button
  final bool showViewToggle;
  
  /// Show fatigue legend
  final bool showLegend;
  
  /// Widget width (defaults to available width)
  final double? width;
  
  /// Widget height
  final double height;

  @override
  State<MuscleHeatmapWidget> createState() => _MuscleHeatmapWidgetState();
}

class _MuscleHeatmapWidgetState extends State<MuscleHeatmapWidget>
    with SingleTickerProviderStateMixin {
  late bool _isBackView;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  
  MuscleId? _highlightedMuscle;

  @override
  void initState() {
    super.initState();
    _isBackView = widget.initialBackView;
    
    _flipController = AnimationController(
      vsync: this,
      duration: kDurationSlow,
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleView() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBackView = !_isBackView;
    });
    
    if (_isBackView) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _handleMuscleTap(MuscleId muscleId) {
    HapticFeedback.mediumImpact();
    
    final fatigueLevel = widget.fatigueMap[muscleId] ?? 0.0;
    final muscleInfo = MuscleDefinitions.withFatigue(muscleId, fatigueLevel);
    
    setState(() {
      _highlightedMuscle = muscleId;
    });
    
    // Reset highlight after animation
    Future.delayed(kDurationMedium, () {
      if (mounted) {
        setState(() => _highlightedMuscle = null);
      }
    });
    
    widget.onMuscleTap?.call(muscleInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View toggle button
        if (widget.showViewToggle)
          _buildViewToggle(),
        
        const SizedBox(height: kSpaceMD),
        
        // Body heatmap with forced AspectRatio for proper layout
        SizedBox(
          width: widget.width ?? double.infinity,
          child: AspectRatio(
            aspectRatio: 0.55, // Tall human body silhouette ratio
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_flipAnimation.value * 3.14159),
                  child: _flipAnimation.value < 0.5
                      ? _buildBodyView(isFront: true)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(3.14159),
                          child: _buildBodyView(isFront: false),
                        ),
                );
              },
            ),
          ),
        ),
        
        // Legend
        if (widget.showLegend)
          _buildLegend(),
      ],
    );
  }

  Widget _buildViewToggle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: kBlurMedium, sigmaY: kBlurMedium),
        child: Container(
          padding: const EdgeInsets.all(kSpaceXS),
          decoration: BoxDecoration(
            color: kSurfaceGlass,
            borderRadius: BorderRadius.circular(kRadiusFull),
            border: Border.all(color: kBorderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleButton(
                label: 'Front',
                isSelected: !_isBackView,
                onTap: () {
                  if (_isBackView) _toggleView();
                },
              ),
              const SizedBox(width: kSpaceXS),
              _buildToggleButton(
                label: 'Back',
                isSelected: _isBackView,
                onTap: () {
                  if (!_isBackView) _toggleView();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: kDurationMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: kSpaceMD,
          vertical: kSpaceSM,
        ),
        decoration: BoxDecoration(
          color: isSelected ? kContentHigh.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusFull),
        ),
        child: Text(
          label,
          style: kNoirBodySmall.copyWith(
            color: isSelected ? kContentHigh : kContentMedium,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Ghost Stack rendering strategy (VISIBILITY BOOSTED):
  /// 1. PASS 1 (Background): Faint white holographic outline of ALL muscles
  /// 2. PASS 2 (Foreground): Bright white glow for fatigued muscles
  /// This creates visible "ghostly" anatomy against black background
  Widget _buildBodyView({required bool isFront}) {
    final muscles = isFront ? MuscleAssets.frontMuscles : MuscleAssets.backMuscles;
    
    // DEBUG: Inject dummy data if fatigueMap is empty
    final effectiveFatigueMap = widget.fatigueMap.isEmpty
        ? <MuscleId, double>{
            MuscleId.chest: 0.8,
            MuscleId.abs: 0.4,
            MuscleId.quadriceps: 0.6,
            MuscleId.shoulders: 0.5,
            MuscleId.back: 0.7,
            MuscleId.glutes: 0.3,
          }
        : widget.fatigueMap;
    
    // Get unique assets to avoid rendering the same SVG multiple times
    final uniqueAssets = MuscleAssets.getUniqueAssets(muscles, widget.gender);
    
    debugPrint('🎨 MuscleHeatmap: Building ${isFront ? "FRONT" : "BACK"} view');
    debugPrint('📊 MuscleHeatmap: Fatigue map has ${effectiveFatigueMap.length} entries');
    debugPrint('📁 MuscleHeatmap: Unique assets: ${uniqueAssets.keys.toList()}');
    
    return Stack(
      fit: StackFit.expand, // CRITICAL: Forces Stack to fill parent
      alignment: Alignment.center,
      children: [
        // =====================================================================
        // PASS 1: Holographic ghost layer (ALL muscles - faint white)
        // =====================================================================
        // Body outline silhouette - visible against black background
        Positioned.fill(
          child: _buildSvgSafe(
            path: MuscleAssets.getBodySilhouettePath(widget.gender, isFront: isFront),
            color: Colors.white.withOpacity(0.15), // Boosted visibility
          ),
        ),
        
        // All muscle silhouettes (holographic ghost layer)
        ...uniqueAssets.keys.map((assetPath) {
          return Positioned.fill(
            child: _buildSvgSafe(
              path: assetPath,
              color: Colors.white.withOpacity(0.1), // Faint holographic outline
            ),
          );
        }),
        
        // =====================================================================
        // PASS 2: Bright white glow foreground (fatigued muscles)
        // =====================================================================
        ...uniqueAssets.entries.map((entry) {
          final assetPath = entry.key;
          final musclesUsingAsset = entry.value;
          
          // Get max fatigue among muscles sharing this asset
          final maxFatigue = MuscleAssets.getMaxFatigueForAsset(
            assetPath, 
            uniqueAssets, 
            effectiveFatigueMap, // Use effective map with debug data
          );
          
          // Check if any muscle using this asset is highlighted
          final isHighlighted = musclesUsingAsset.any(
            (m) => _highlightedMuscle == m,
          );
          
          // Skip if no fatigue and not highlighted (stays as ghost)
          if (maxFatigue <= 0.0 && !isHighlighted) {
            return const SizedBox.shrink();
          }
          
          debugPrint('🔥 MuscleHeatmap: Rendering GLOW for $assetPath @ ${(maxFatigue * 100).toInt()}% fatigue');
          
          // Calculate white glow opacity based on fatigue
          // Linear scale: fatigue 0.0 → 0.0 opacity, fatigue 1.0 → 0.9 opacity
          // This ensures visible difference between fatigue levels
          final glowOpacity = isHighlighted 
              ? 1.0 
              : (maxFatigue * 0.9).clamp(0.0, 0.9);
          
          return Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Tap triggers the first muscle using this asset
                if (musclesUsingAsset.isNotEmpty) {
                  _handleMuscleTap(musclesUsingAsset.first);
                }
              },
              behavior: HitTestBehavior.translucent,
              child: _buildSvgSafe(
                path: assetPath,
                color: Colors.white.withOpacity(glowOpacity), // Pure white glow
                animate: isHighlighted,
              ),
            ),
          );
        }),
      ],
    );
  }
  
  /// Safely builds an SVG widget with error handling for missing assets
  Widget _buildSvgSafe({
    required String path,
    required Color color,
    bool animate = false,
  }) {
    // DEBUG: Log asset loading attempts
    debugPrint('🦴 MuscleHeatmap: Loading SVG → $path');
    
    Widget svg;
    try {
      svg = SvgPicture.asset(
        path,
        width: double.infinity,   // Fill available width
        height: double.infinity,  // Fill available height
        fit: BoxFit.contain,      // Maintain aspect ratio within bounds
        alignment: Alignment.center,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (context) {
          debugPrint('⏳ MuscleHeatmap: Placeholder loading for $path');
          return const SizedBox.shrink();
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ SVG ERROR for $path: $e');
      debugPrint('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return const SizedBox.shrink();
    }
    
    if (animate) {
      svg = svg.animate()
          .fadeIn(duration: kDurationFast)
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02))
          .then()
          .scale(begin: const Offset(1.02, 1.02), end: const Offset(1.0, 1.0));
    }
    
    return svg;
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: kSpaceLG),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(label: 'Fresh', opacity: 0.1),
          const SizedBox(width: kSpaceMD),
          _buildLegendItem(label: 'Tired', opacity: 0.5),
          const SizedBox(width: kSpaceMD),
          _buildLegendItem(label: 'Exhausted', opacity: 1.0),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required String label, required double opacity}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: kContentHigh.withOpacity(opacity),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: kBorderMedium),
          ),
        ),
        const SizedBox(width: kSpaceXS),
        Text(
          label,
          style: kNoirCaption.copyWith(color: kContentMedium),
        ),
      ],
    );
  }
}

// =============================================================================
// MUSCLE DETAIL BOTTOM SHEET
// =============================================================================

/// Shows detailed muscle information in a Noir Glass bottom sheet.
Future<void> showMuscleDetailSheet(
  BuildContext context, {
  required MuscleInfo muscle,
  required bool isRussian,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => MuscleDetailSheet(
      muscle: muscle,
      isRussian: isRussian,
    ),
  );
}

class MuscleDetailSheet extends StatelessWidget {
  const MuscleDetailSheet({
    super.key,
    required this.muscle,
    required this.isRussian,
  });

  final MuscleInfo muscle;
  final bool isRussian;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(kRadiusXL),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: kBlurHeavy, sigmaY: kBlurHeavy),
        child: Container(
          decoration: BoxDecoration(
            gradient: kGlassGradient(opacity: 0.08),
            border: Border(
              top: BorderSide(color: kBorderMedium),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(kSpaceLG),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kContentLow,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: kSpaceLG),
                  
                  // Muscle name and status
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              muscle.getName(isRussian),
                              style: kNoirTitleMedium,
                            ),
                            const SizedBox(height: kSpaceXS),
                            _buildStatusBadge(),
                          ],
                        ),
                      ),
                      _buildRecoveryCircle(),
                    ],
                  ),
                  
                  const SizedBox(height: kSpaceLG),
                  
                  // Last trained info
                  _buildInfoRow(
                    icon: Icons.history_rounded,
                    label: isRussian ? 'Последняя тренировка' : 'Last trained',
                    value: _getLastTrainedText(),
                  ),
                  
                  const SizedBox(height: kSpaceMD),
                  
                  // Recovery time
                  _buildInfoRow(
                    icon: Icons.timer_outlined,
                    label: isRussian ? 'Время восстановления' : 'Recovery time',
                    value: '${muscle.recoveryHours}h',
                  ),
                  
                  const SizedBox(height: kSpaceLG),
                  
                  // Recommended exercises
                  Text(
                    isRussian ? 'Рекомендуемые упражнения' : 'Recommended Exercises',
                    style: kNoirBodyMedium.copyWith(color: kContentMedium),
                  ),
                  
                  const SizedBox(height: kSpaceMD),
                  
                  ...muscle.recommendedExercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: kSpaceSM),
                    child: _buildExerciseChip(exercise),
                  )),
                  
                  const SizedBox(height: kSpaceMD),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (statusText, statusColor) = _getStatusInfo();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpaceSM,
        vertical: kSpaceXS,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(kRadiusSM),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: kNoirCaption.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color) _getStatusInfo() {
    switch (muscle.status) {
      case MuscleStatus.fresh:
        return (isRussian ? 'Готово' : 'Fresh', kContentHigh);
      case MuscleStatus.recovering:
        return (isRussian ? 'Восстанавливается' : 'Recovering', kNoirSilver);
      case MuscleStatus.fatigued:
        return (isRussian ? 'Устало' : 'Fatigued', kNoirMist);
      case MuscleStatus.exhausted:
        return (isRussian ? 'Истощено' : 'Exhausted', kNoirFog);
    }
  }

  Widget _buildRecoveryCircle() {
    final recoveryPercent = muscle.recoveryPercent;
    
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 4,
            backgroundColor: kNoirSlate,
            color: Colors.transparent,
          ),
          // Progress circle
          CircularProgressIndicator(
            value: recoveryPercent / 100,
            strokeWidth: 4,
            backgroundColor: Colors.transparent,
            color: kContentHigh.withOpacity(0.8),
          ),
          // Percentage text
          Text(
            '${recoveryPercent.toInt()}%',
            style: kNoirBodySmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getLastTrainedText() {
    final days = muscle.daysSinceLastWorkout;
    if (days == null) {
      return isRussian ? 'Нет данных' : 'No data';
    }
    if (days == 0) {
      return isRussian ? 'Сегодня' : 'Today';
    }
    if (days == 1) {
      return isRussian ? 'Вчера' : 'Yesterday';
    }
    return isRussian ? '$days дней назад' : '$days days ago';
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(kSpaceSM),
          decoration: BoxDecoration(
            color: kSurfaceGlass,
            borderRadius: BorderRadius.circular(kRadiusSM),
          ),
          child: Icon(icon, size: 20, color: kContentMedium),
        ),
        const SizedBox(width: kSpaceMD),
        Expanded(
          child: Text(
            label,
            style: kNoirBodyMedium.copyWith(color: kContentMedium),
          ),
        ),
        Text(
          value,
          style: kNoirBodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseChip(String exercise) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpaceMD,
        vertical: kSpaceSM,
      ),
      decoration: BoxDecoration(
        color: kSurfaceGlass,
        borderRadius: BorderRadius.circular(kRadiusSM),
        border: Border.all(color: kBorderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 16,
            color: kContentMedium,
          ),
          const SizedBox(width: kSpaceSM),
          Text(
            exercise,
            style: kNoirBodySmall,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SAMPLE DATA GENERATOR
// =============================================================================

/// Generate sample fatigue data for demo purposes
Map<MuscleId, double> generateSampleFatigueMap() {
  return {
    MuscleId.chest: 0.7,
    MuscleId.abs: 0.3,
    MuscleId.shoulders: 0.5,
    MuscleId.biceps: 0.2,
    MuscleId.forearms: 0.1,
    MuscleId.quadriceps: 0.8,
    MuscleId.back: 0.6,
    MuscleId.traps: 0.4,
    MuscleId.triceps: 0.5,
    MuscleId.glutes: 0.3,
    MuscleId.hamstrings: 0.7,
    MuscleId.calves: 0.2,
  };
}
