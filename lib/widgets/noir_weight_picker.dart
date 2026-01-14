// =============================================================================
// noir_weight_picker.dart — iOS-Style Drum Picker for Weight Input
// =============================================================================
// Premium CupertinoPicker with Noir Glass styling:
// - Dual pickers for integer and decimal parts
// - Supports metric (kg) and imperial (lb)
// - BackdropFilter blur effect
// - Haptic feedback on scroll
// - Trend arrows showing progress towards goal
// =============================================================================

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/noir_theme.dart';
import '../providers/unit_system_provider.dart';
import '../providers/profile_provider.dart';
import '../l10n/app_localizations.dart';

/// Weight trend direction relative to goal
enum WeightTrend {
  positive,  // Moving towards goal
  negative,  // Moving away from goal
  neutral,   // No change or no goal
}

/// Noir Glass Weight Picker Dialog
/// Returns the selected weight in METRIC (kg) regardless of display unit
class NoirWeightPicker extends ConsumerStatefulWidget {
  const NoirWeightPicker({
    super.key,
    required this.initialWeight,
    this.previousWeight,
    this.targetWeight,
    this.goal,
    this.onSave,
  });

  /// Initial weight in kg (metric)
  final double initialWeight;
  
  /// Previous weight for trend calculation (in kg)
  final double? previousWeight;
  
  /// Target weight for goal direction (in kg)
  final double? targetWeight;
  
  /// User's goal: 'lose_weight', 'gain_muscle', 'maintain'
  final String? goal;
  
  /// Callback when save is pressed, returns weight in kg
  final void Function(double weightKg)? onSave;

  /// Show the picker as a modal bottom sheet
  static Future<double?> show(
    BuildContext context, {
    required double initialWeightKg,
    double? previousWeightKg,
    double? targetWeightKg,
    String? goal,
  }) async {
    return showModalBottomSheet<double>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => NoirWeightPicker(
        initialWeight: initialWeightKg,
        previousWeight: previousWeightKg,
        targetWeight: targetWeightKg,
        goal: goal,
      ),
    );
  }

  @override
  ConsumerState<NoirWeightPicker> createState() => _NoirWeightPickerState();
}

class _NoirWeightPickerState extends ConsumerState<NoirWeightPicker> {
  late int _integerPart;
  late int _decimalPart;
  
  late FixedExtentScrollController _integerController;
  late FixedExtentScrollController _decimalController;

  @override
  void initState() {
    super.initState();
    _initializeFromWeight(widget.initialWeight);
  }

  void _initializeFromWeight(double weightKg) {
    final system = ref.read(unitSystemProvider);
    final displayWeight = UnitConverter.convertWeightFromMetric(weightKg, system);
    
    _integerPart = displayWeight.floor();
    _decimalPart = ((displayWeight - _integerPart) * 10).round();
    
    // Clamp to valid range
    final range = UnitConverter.weightRange(system);
    _integerPart = _integerPart.clamp(range.min.floor(), range.max.floor());
    _decimalPart = _decimalPart.clamp(0, 9);
    
    _integerController = FixedExtentScrollController(
      initialItem: _integerPart - range.min.floor(),
    );
    _decimalController = FixedExtentScrollController(
      initialItem: _decimalPart,
    );
  }

  double get _currentWeightInMetric {
    final system = ref.read(unitSystemProvider);
    final displayWeight = _integerPart + (_decimalPart / 10);
    return UnitConverter.convertWeightToMetric(displayWeight, system);
  }

  /// Calculate trend based on goal and previous weight
  WeightTrend _calculateTrend() {
    final currentKg = _currentWeightInMetric;
    final previousKg = widget.previousWeight;
    final targetKg = widget.targetWeight;
    final goal = widget.goal;
    
    if (previousKg == null) return WeightTrend.neutral;
    
    final change = currentKg - previousKg;
    if (change.abs() < 0.1) return WeightTrend.neutral; // No significant change
    
    // Determine if the change is positive (towards goal)
    bool isPositive;
    if (goal == 'lose_weight' || goal == 'lose') {
      isPositive = change < 0; // Losing weight is positive
    } else if (goal == 'gain_muscle' || goal == 'gain') {
      isPositive = change > 0; // Gaining weight is positive
    } else if (targetKg != null) {
      // Use target weight to determine direction
      final distanceBefore = (previousKg - targetKg).abs();
      final distanceNow = (currentKg - targetKg).abs();
      isPositive = distanceNow < distanceBefore; // Getting closer to target
    } else {
      return WeightTrend.neutral;
    }
    
    return isPositive ? WeightTrend.positive : WeightTrend.negative;
  }

  @override
  void dispose() {
    _integerController.dispose();
    _decimalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final system = ref.watch(unitSystemProvider);
    final range = UnitConverter.weightRange(system);
    final unit = UnitConverter.weightUnit(system);
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: kNoirCarbon.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
            border: Border.all(color: kNoirSteel.withOpacity(0.3)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Padding(
                  padding: const EdgeInsets.only(top: kSpaceMD),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kContentLow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(kSpaceLG),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context)!.cancelButton,
                          style: kNoirBodyLarge.copyWith(color: kContentMedium),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.weightLabel,
                        style: kNoirTitleMedium.copyWith(color: kContentHigh),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          final weightKg = _currentWeightInMetric;
                          widget.onSave?.call(weightKg);
                          Navigator.pop(context, weightKg);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.doneButton,
                          style: kNoirBodyLarge.copyWith(
                            color: kContentHigh,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Current value display with trend
                Container(
                  padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_integerPart.$_decimalPart $unit',
                        style: kNoirDisplayMedium.copyWith(
                          color: kContentHigh,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.previousWeight != null) ...[
                        const SizedBox(width: kSpaceSM),
                        _buildTrendIndicator(),
                      ],
                    ],
                  ),
                ),
                
                // Change from previous weight
                if (widget.previousWeight != null)
                  _buildChangeDisplay(system),
                
                // Drum pickers
                SizedBox(
                  height: 220,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Integer part picker
                      SizedBox(
                        width: 100,
                        child: CupertinoPicker(
                          scrollController: _integerController,
                          itemExtent: 50,
                          selectionOverlay: _buildSelectionOverlay(),
                          onSelectedItemChanged: (index) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _integerPart = range.min.floor() + index;
                            });
                          },
                          children: List.generate(
                            (range.max - range.min).floor() + 1,
                            (index) => _buildPickerItem('${range.min.floor() + index}'),
                          ),
                        ),
                      ),
                      
                      // Decimal separator
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: kSpaceXS),
                        child: Text(
                          '.',
                          style: kNoirDisplaySmall.copyWith(
                            color: kContentHigh,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Decimal part picker
                      SizedBox(
                        width: 60,
                        child: CupertinoPicker(
                          scrollController: _decimalController,
                          itemExtent: 50,
                          selectionOverlay: _buildSelectionOverlay(),
                          onSelectedItemChanged: (index) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _decimalPart = index;
                            });
                          },
                          children: List.generate(
                            10,
                            (index) => _buildPickerItem('$index'),
                          ),
                        ),
                      ),
                      
                      // Unit label
                      Padding(
                        padding: const EdgeInsets.only(left: kSpaceSM),
                        child: Text(
                          unit,
                          style: kNoirTitleMedium.copyWith(
                            color: kContentMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unit toggle
                Padding(
                  padding: const EdgeInsets.all(kSpaceLG),
                  child: _UnitToggle(
                    isMetric: system == UnitSystem.metric,
                    onToggle: () async {
                      HapticFeedback.lightImpact();
                      // Save current weight in kg before switching
                      final currentKg = _currentWeightInMetric;
                      await ref.read(unitSystemStateProvider.notifier).toggle();
                      // Reinitialize with same kg value
                      setState(() {
                        _initializeFromWeight(currentKg);
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: kSpaceMD),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerItem(String text) {
    return Center(
      child: Text(
        text,
        style: kNoirTitleLarge.copyWith(
          color: kContentHigh,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: kContentLow.withOpacity(0.3), width: 1),
          bottom: BorderSide(color: kContentLow.withOpacity(0.3), width: 1),
        ),
      ),
    );
  }

  /// Build trend indicator arrow
  Widget _buildTrendIndicator() {
    final trend = _calculateTrend();
    
    if (trend == WeightTrend.neutral) {
      return const SizedBox.shrink();
    }
    
    final isPositive = trend == WeightTrend.positive;
    final color = isPositive ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    final icon = isPositive ? Icons.trending_down : Icons.trending_up;
    
    // For gain muscle goal, positive is trending up
    final actualIcon = (widget.goal == 'gain_muscle' || widget.goal == 'gain')
        ? (isPositive ? Icons.trending_up : Icons.trending_down)
        : icon;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(kRadiusSM),
      ),
      child: Icon(
        actualIcon,
        color: color,
        size: 24,
      ),
    );
  }

  /// Build change display (difference from previous weight)
  Widget _buildChangeDisplay(UnitSystem system) {
    final currentKg = _currentWeightInMetric;
    final previousKg = widget.previousWeight!;
    final changeKg = currentKg - previousKg;
    
    if (changeKg.abs() < 0.05) {
      return const SizedBox.shrink();
    }
    
    final displayChange = UnitConverter.convertWeightFromMetric(changeKg.abs(), system);
    final unit = UnitConverter.weightUnit(system);
    final sign = changeKg >= 0 ? '+' : '-';
    final trend = _calculateTrend();
    
    final color = trend == WeightTrend.positive 
        ? const Color(0xFF4ADE80)
        : trend == WeightTrend.negative 
            ? const Color(0xFFF87171)
            : kContentMedium;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpaceSM),
      child: Text(
        '$sign${displayChange.toStringAsFixed(1)} $unit',
        style: kNoirBodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// =============================================================================
// Unit Toggle Widget
// =============================================================================

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({
    required this.isMetric,
    required this.onToggle,
  });

  final bool isMetric;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(kSpaceXS),
        decoration: BoxDecoration(
          color: kNoirGraphite.withOpacity(0.5),
          borderRadius: BorderRadius.circular(kRadiusLG),
          border: Border.all(color: kNoirSteel.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption('кг/см', isMetric),
            const SizedBox(width: kSpaceXS),
            _buildOption('lb/ft', !isMetric),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String label, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
      decoration: BoxDecoration(
        color: selected ? kContentHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(kRadiusMD),
      ),
      child: Text(
        label,
        style: kNoirBodyMedium.copyWith(
          color: selected ? kNoirBlack : kContentMedium,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
