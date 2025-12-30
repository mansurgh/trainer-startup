// =============================================================================
// weight_input_sheet.dart — Premium Haptic Weight Picker
// =============================================================================
// Luxury weight input experience with:
// - ListWheelScrollView for wheel-style selection
// - HapticFeedback.lightImpact on every tick
// - Glassmorphic design
// - Animated value display
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// =============================================================================
// WEIGHT INPUT SHEET — Bottom Sheet Component
// =============================================================================

/// Shows a premium weight input bottom sheet.
/// Returns the selected weight or null if dismissed.
Future<double?> showWeightInputSheet(
  BuildContext context, {
  double initialWeight = 70.0,
  double minWeight = 30.0,
  double maxWeight = 200.0,
  double step = 0.1,
  String title = 'Ваш вес',
  String unit = 'кг',
}) async {
  return showModalBottomSheet<double>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => WeightInputSheet(
      initialWeight: initialWeight,
      minWeight: minWeight,
      maxWeight: maxWeight,
      step: step,
      title: title,
      unit: unit,
    ),
  );
}

/// Premium weight picker widget with haptic feedback.
class WeightInputSheet extends StatefulWidget {
  const WeightInputSheet({
    super.key,
    this.initialWeight = 70.0,
    this.minWeight = 30.0,
    this.maxWeight = 200.0,
    this.step = 0.1,
    this.title = 'Ваш вес',
    this.unit = 'кг',
    this.onChanged,
    this.onConfirm,
  });

  /// Initial weight value
  final double initialWeight;
  
  /// Minimum selectable weight
  final double minWeight;
  
  /// Maximum selectable weight
  final double maxWeight;
  
  /// Increment step (0.1 for decimal, 1.0 for integer)
  final double step;
  
  /// Sheet title
  final String title;
  
  /// Unit label (kg, lbs)
  final String unit;
  
  /// Called when value changes during scrolling
  final void Function(double value)? onChanged;
  
  /// Called when user confirms selection
  final void Function(double value)? onConfirm;

  @override
  State<WeightInputSheet> createState() => _WeightInputSheetState();
}

class _WeightInputSheetState extends State<WeightInputSheet>
    with SingleTickerProviderStateMixin {
  late FixedExtentScrollController _integerController;
  late FixedExtentScrollController _decimalController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  late int _selectedInteger;
  late int _selectedDecimal;
  double? _lastHapticValue;

  @override
  void initState() {
    super.initState();
    
    // Parse initial weight into integer and decimal parts
    _selectedInteger = widget.initialWeight.floor();
    _selectedDecimal = ((widget.initialWeight - _selectedInteger) * 10).round();
    
    // Initialize scroll controllers
    _integerController = FixedExtentScrollController(
      initialItem: _selectedInteger - widget.minWeight.floor(),
    );
    _decimalController = FixedExtentScrollController(
      initialItem: _selectedDecimal,
    );
    
    // Glow animation for selected value
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _integerController.dispose();
    _decimalController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  double get _currentWeight => _selectedInteger + (_selectedDecimal / 10);

  void _triggerHaptic() {
    // Trigger haptic only when value actually changes
    if (_lastHapticValue != _currentWeight) {
      HapticFeedback.lightImpact();
      _lastHapticValue = _currentWeight;
    }
  }

  void _onIntegerChanged(int index) {
    setState(() {
      _selectedInteger = widget.minWeight.floor() + index;
    });
    _triggerHaptic();
    widget.onChanged?.call(_currentWeight);
  }

  void _onDecimalChanged(int index) {
    setState(() {
      _selectedDecimal = index;
    });
    _triggerHaptic();
    widget.onChanged?.call(_currentWeight);
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    widget.onConfirm?.call(_currentWeight);
    Navigator.of(context).pop(_currentWeight);
  }

  @override
  Widget build(BuildContext context) {
    final integerCount = widget.maxWeight.floor() - widget.minWeight.floor() + 1;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: kObsidianSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
        border: Border.all(color: kObsidianBorder),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: kGlassBlurSigma, sigmaY: kGlassBlurSigma),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: kSpaceMD),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: kSpaceLG),
              
              // Title
              Text(
                widget.title,
                style: kDenseHeading.copyWith(fontSize: 20),
              ),
              const SizedBox(height: kSpaceXL),
              
              // Weight display with glow
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpaceXL,
                      vertical: kSpaceMD,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kRadiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: kElectricAmberStart.withOpacity(_glowAnimation.value),
                          blurRadius: 24,
                          spreadRadius: -8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // Integer part
                        Text(
                          _selectedInteger.toString(),
                          style: kGiantNumber.copyWith(
                            fontSize: 64,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        // Decimal point
                        Text(
                          '.',
                          style: kGiantNumber.copyWith(
                            fontSize: 64,
                            fontWeight: FontWeight.w200,
                            color: kTextTertiary,
                          ),
                        ),
                        // Decimal part
                        Text(
                          _selectedDecimal.toString(),
                          style: kGiantNumber.copyWith(
                            fontSize: 64,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        const SizedBox(width: kSpaceSM),
                        // Unit
                        Text(
                          widget.unit,
                          style: kBodyText.copyWith(
                            color: kTextTertiary,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: kSpaceLG),
              
              // Wheel pickers
              Expanded(
                child: Stack(
                  children: [
                    // Selection highlight
                    Center(
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: kSpaceXL),
                        decoration: BoxDecoration(
                          color: kElectricAmberStart.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(kRadiusMD),
                          border: Border.all(
                            color: kElectricAmberStart.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    
                    // Pickers row
                    Row(
                      children: [
                        // Integer wheel
                        Expanded(
                          flex: 2,
                          child: _HapticWheel(
                            controller: _integerController,
                            itemCount: integerCount,
                            onSelectedItemChanged: _onIntegerChanged,
                            itemBuilder: (context, index) {
                              final value = widget.minWeight.floor() + index;
                              final isSelected = value == _selectedInteger;
                              return Center(
                                child: Text(
                                  value.toString(),
                                  style: kLargeNumber.copyWith(
                                    fontSize: isSelected ? 32 : 24,
                                    color: isSelected ? kTextPrimary : kTextTertiary,
                                    fontWeight: isSelected ? FontWeight.w300 : FontWeight.w200,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Decimal separator
                        Text(
                          '.',
                          style: kLargeNumber.copyWith(
                            fontSize: 32,
                            color: kTextTertiary,
                          ),
                        ),
                        
                        // Decimal wheel
                        Expanded(
                          child: _HapticWheel(
                            controller: _decimalController,
                            itemCount: 10,
                            onSelectedItemChanged: _onDecimalChanged,
                            itemBuilder: (context, index) {
                              final isSelected = index == _selectedDecimal;
                              return Center(
                                child: Text(
                                  index.toString(),
                                  style: kLargeNumber.copyWith(
                                    fontSize: isSelected ? 32 : 24,
                                    color: isSelected ? kTextPrimary : kTextTertiary,
                                    fontWeight: isSelected ? FontWeight.w300 : FontWeight.w200,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Unit label
                        Padding(
                          padding: const EdgeInsets.only(right: kSpaceLG),
                          child: Text(
                            widget.unit,
                            style: kBodyText.copyWith(
                              color: kTextTertiary,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Top fade gradient
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              kObsidianSurface,
                              kObsidianSurface.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Bottom fade gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              kObsidianSurface,
                              kObsidianSurface.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Confirm button
              Padding(
                padding: const EdgeInsets.all(kSpaceLG),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _confirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: kElectricAmberStart,
                      foregroundColor: kOledBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadiusMD),
                      ),
                    ),
                    child: Text(
                      'Подтвердить',
                      style: kBodyText.copyWith(
                        fontWeight: FontWeight.w700,
                        color: kOledBlack,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Safe area padding
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HAPTIC WHEEL — ListWheelScrollView with Haptic Feedback
// =============================================================================

class _HapticWheel extends StatelessWidget {
  const _HapticWheel({
    required this.controller,
    required this.itemCount,
    required this.onSelectedItemChanged,
    required this.itemBuilder,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final void Function(int) onSelectedItemChanged;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 50,
      perspective: 0.005,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: itemBuilder,
        childCount: itemCount,
      ),
    );
  }
}

// =============================================================================
// HEIGHT INPUT SHEET — Similar component for height
// =============================================================================

/// Shows a height input bottom sheet.
Future<int?> showHeightInputSheet(
  BuildContext context, {
  int initialHeight = 170,
  int minHeight = 120,
  int maxHeight = 220,
  String title = 'Ваш рост',
  String unit = 'см',
}) async {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => HeightInputSheet(
      initialHeight: initialHeight,
      minHeight: minHeight,
      maxHeight: maxHeight,
      title: title,
      unit: unit,
    ),
  );
}

class HeightInputSheet extends StatefulWidget {
  const HeightInputSheet({
    super.key,
    this.initialHeight = 170,
    this.minHeight = 120,
    this.maxHeight = 220,
    this.title = 'Ваш рост',
    this.unit = 'см',
    this.onChanged,
    this.onConfirm,
  });

  final int initialHeight;
  final int minHeight;
  final int maxHeight;
  final String title;
  final String unit;
  final void Function(int value)? onChanged;
  final void Function(int value)? onConfirm;

  @override
  State<HeightInputSheet> createState() => _HeightInputSheetState();
}

class _HeightInputSheetState extends State<HeightInputSheet>
    with SingleTickerProviderStateMixin {
  late FixedExtentScrollController _controller;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  late int _selectedHeight;
  int? _lastHapticValue;

  @override
  void initState() {
    super.initState();
    _selectedHeight = widget.initialHeight;
    _controller = FixedExtentScrollController(
      initialItem: _selectedHeight - widget.minHeight,
    );
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onChanged(int index) {
    final newValue = widget.minHeight + index;
    if (_lastHapticValue != newValue) {
      HapticFeedback.lightImpact();
      _lastHapticValue = newValue;
    }
    setState(() {
      _selectedHeight = newValue;
    });
    widget.onChanged?.call(_selectedHeight);
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    widget.onConfirm?.call(_selectedHeight);
    Navigator.of(context).pop(_selectedHeight);
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.maxHeight - widget.minHeight + 1;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: kObsidianSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
        border: Border.all(color: kObsidianBorder),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: kGlassBlurSigma, sigmaY: kGlassBlurSigma),
          child: Column(
            children: [
              const SizedBox(height: kSpaceMD),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: kSpaceLG),
              
              Text(
                widget.title,
                style: kDenseHeading.copyWith(fontSize: 20),
              ),
              const SizedBox(height: kSpaceXL),
              
              // Height display
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpaceXL,
                      vertical: kSpaceMD,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kRadiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: kElectricAmberStart.withOpacity(_glowAnimation.value),
                          blurRadius: 24,
                          spreadRadius: -8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _selectedHeight.toString(),
                          style: kGiantNumber.copyWith(
                            fontSize: 72,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        const SizedBox(width: kSpaceSM),
                        Text(
                          widget.unit,
                          style: kBodyText.copyWith(
                            color: kTextTertiary,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: kSpaceLG),
              
              // Wheel picker
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: kSpaceXL),
                        decoration: BoxDecoration(
                          color: kElectricAmberStart.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(kRadiusMD),
                          border: Border.all(
                            color: kElectricAmberStart.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    
                    _HapticWheel(
                      controller: _controller,
                      itemCount: itemCount,
                      onSelectedItemChanged: _onChanged,
                      itemBuilder: (context, index) {
                        final value = widget.minHeight + index;
                        final isSelected = value == _selectedHeight;
                        return Center(
                          child: Text(
                            '$value ${widget.unit}',
                            style: kLargeNumber.copyWith(
                              fontSize: isSelected ? 28 : 20,
                              color: isSelected ? kTextPrimary : kTextTertiary,
                              fontWeight: isSelected ? FontWeight.w300 : FontWeight.w200,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Gradients
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              kObsidianSurface,
                              kObsidianSurface.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              kObsidianSurface,
                              kObsidianSurface.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(kSpaceLG),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _confirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: kElectricAmberStart,
                      foregroundColor: kOledBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadiusMD),
                      ),
                    ),
                    child: Text(
                      'Подтвердить',
                      style: kBodyText.copyWith(
                        fontWeight: FontWeight.w700,
                        color: kOledBlack,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// AGE INPUT SHEET — For age selection
// =============================================================================

/// Shows an age input bottom sheet.
Future<int?> showAgeInputSheet(
  BuildContext context, {
  int initialAge = 25,
  int minAge = 14,
  int maxAge = 100,
  String title = 'Ваш возраст',
}) async {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => HeightInputSheet(
      initialHeight: initialAge,
      minHeight: minAge,
      maxHeight: maxAge,
      title: title,
      unit: 'лет',
    ),
  );
}
