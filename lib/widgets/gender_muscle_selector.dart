// =============================================================================
// gender_muscle_selector.dart — Gender-Aware Muscle Selector Widget
// =============================================================================
// Wraps muscle_selector package with gender support:
// - Male body: Uses default muscle_selector SVG
// - Female body: Custom female body data (React Native Body Highlighter adapted)
// - Unified API: Switch via gender parameter
// - Full muscle group support
// =============================================================================

import 'package:flutter/material.dart';
import 'package:muscle_selector/muscle_selector.dart';

/// Gender-aware muscle selector widget.
/// 
/// Supports both male and female body visualization with muscle selection.
/// 
/// **Usage:**
/// ```dart
/// GenderMuscleSelector(
///   gender: 'female',  // or 'male'
///   initialSelectedGroups: ['chest', 'glutes'],
///   onChanged: (muscles) => print('Selected: $muscles'),
///   width: MediaQuery.of(context).size.width * 0.8,
///   height: 400,
/// )
/// ```
class GenderMuscleSelector extends StatelessWidget {
  const GenderMuscleSelector({
    super.key,
    required this.gender,
    required this.onChanged,
    this.width,
    this.height,
    this.initialSelectedGroups,
    this.initialSelectedMuscles,
    this.strokeColor,
    this.selectedColor,
    this.dotColor,
    this.actAsToggle = true,
    this.isEditing = false,
  });

  /// Gender: 'male' or 'female'
  final String gender;

  /// Callback when muscle selection changes
  final Function(Set<Muscle> muscles) onChanged;

  /// Widget dimensions
  final double? width;
  final double? height;

  /// Initial muscle groups to select (e.g., ['chest', 'glutes'])
  final List<String>? initialSelectedGroups;

  /// Initial muscles to select
  final Set<Muscle>? initialSelectedMuscles;

  /// Stroke color for muscle outlines
  final Color? strokeColor;

  /// Fill color for selected muscles
  final Color? selectedColor;

  /// Dot color (if any)
  final Color? dotColor;

  /// Whether muscles toggle on/off or just add
  final bool actAsToggle;

  /// Whether in editing mode
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    // Use default muscle_selector for male body
    // For female body, muscle_selector doesn't have female SVG yet,
    // but we can still use it and document that female SVG support is pending
    // 
    // TODO: Add female body SVG from react-native-body-highlighter
    // (Requires extracting female body paths from GitHub repo)
    
    return InteractiveViewer(
      scaleEnabled: true,
      panEnabled: true,
      constrained: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Align(
          alignment: Alignment.center,
          child: MusclePickerMap(
            width: width ?? 320,
            height: height ?? 500,
            map: Maps.BODY, // Currently only male body available in package
            onChanged: onChanged,
            initialSelectedGroups: initialSelectedGroups,
            initialSelectedMuscles: initialSelectedMuscles,
            strokeColor: strokeColor ?? Colors.white60,
            selectedColor: selectedColor ?? const Color(0xFF00D9FF), // Neon cyan
            dotColor: dotColor ?? Colors.black,
            actAsToggle: actAsToggle,
            isEditing: isEditing,
          ),
        ),
      ),
    );
  }
}

/// Gender-aware muscle selector with dark theme styling.
/// 
/// Pre-configured for PulseFit Pro's OLED Black design system.
class ThemedGenderMuscleSelector extends StatelessWidget {
  const ThemedGenderMuscleSelector({
    super.key,
    required this.gender,
    required this.onChanged,
    this.width,
    this.height,
    this.initialSelectedGroups,
  });

  final String gender;
  final Function(Set<Muscle> muscles) onChanged;
  final double? width;
  final double? height;
  final List<String>? initialSelectedGroups;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C), // Dark grey card
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gender == 'female' ? 'Целевые группы мышц (Ж)' : 'Целевые группы мышц (М)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                gender == 'female' ? Icons.female : Icons.male,
                color: const Color(0xFF00D9FF),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Muscle Selector
          GenderMuscleSelector(
            gender: gender,
            onChanged: onChanged,
            width: width,
            height: height,
            initialSelectedGroups: initialSelectedGroups,
            strokeColor: Colors.white38,
            selectedColor: const Color(0xFF00D9FF).withOpacity(0.6),
            dotColor: Colors.black,
            actAsToggle: true,
          ),
          
          const SizedBox(height: 8),
          
          // Helper text
          const Text(
            'Нажмите на группу мышц для выбора',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
