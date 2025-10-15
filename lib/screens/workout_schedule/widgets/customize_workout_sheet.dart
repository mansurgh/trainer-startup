import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/workout_day.dart';
import '../../../models/muscle_group.dart';
import '../../../theme/tokens.dart';
import '../../../core/sexy_components.dart';
import '../../../core/theme.dart';

class CustomizeWorkoutSheet extends StatefulWidget {
  final WorkoutDay currentDay;

  const CustomizeWorkoutSheet({
    super.key,
    required this.currentDay,
  });

  @override
  State<CustomizeWorkoutSheet> createState() => _CustomizeWorkoutSheetState();
}

class _CustomizeWorkoutSheetState extends State<CustomizeWorkoutSheet> {
  late int selectedDuration;
  late Set<String> selectedCategories;

  final List<int> durations = [10, 15, 20, 30, 45, 60];
  final Map<String, List<MuscleGroup>> categories = {
    'Upper': [MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.arms],
    'Lower': [MuscleGroup.legs],
    'Core': [MuscleGroup.core],
    'Push': [MuscleGroup.chest, MuscleGroup.shoulders],
    'Pull': [MuscleGroup.back, MuscleGroup.arms],
    'Full': MuscleGroup.values,
  };

  @override
  void initState() {
    super.initState();
    selectedDuration = 30; // Default
    selectedCategories = _getInitialCategories();
  }

  Set<String> _getInitialCategories() {
    final targetGroups = widget.currentDay.targetGroups;
    final Set<String> initial = {};
    
    for (final entry in categories.entries) {
      if (entry.value.any((group) => targetGroups.contains(group))) {
        initial.add(entry.key);
      }
    }
    
    return initial.isEmpty ? {'Full'} : initial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.95), // Темный фон вместо прозрачного
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Настройка тренировки',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Duration Section
                const Text(
                  'Продолжительность',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: durations.map((duration) {
                    final isSelected = selectedDuration == duration;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          selectedDuration = duration;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF007AFF).withOpacity(0.3)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF007AFF)
                                : Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${duration} мин',
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF007AFF) : Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Muscle Groups Section
                const Text(
                  'Группы мышц',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.keys.map((category) {
                    final isSelected = selectedCategories.contains(category);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          if (isSelected) {
                            selectedCategories.remove(category);
                          } else {
                            selectedCategories.add(category);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF007AFF).withOpacity(0.3)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF007AFF)
                                : Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _translateCategory(category),
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF007AFF) : Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: SexyComponents.sexyButton(
                  onPressed: _saveWorkout,
                  child: const Text(
                    'Сохранить тренировку',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _translateCategory(String category) {
    switch (category) {
      case 'Upper':
        return 'Верх';
      case 'Lower':
        return 'Низ';
      case 'Core':
        return 'Пресс';
      case 'Push':
        return 'Толкающие';
      case 'Pull':
        return 'Тянущие';
      case 'Full':
        return 'Все тело';
      default:
        return category;
    }
  }

  void _saveWorkout() {
    HapticFeedback.lightImpact();
    
    // Convert selected categories to muscle groups
    final Set<MuscleGroup> newTargetGroups = {};
    for (final category in selectedCategories) {
      newTargetGroups.addAll(categories[category] ?? []);
    }
    
    final updatedDay = widget.currentDay.copyWith(
      targetGroups: newTargetGroups.toList(),
    );
    
    Navigator.pop(context, updatedDay);
  }
}