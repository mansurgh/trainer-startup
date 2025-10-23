// lib/screens/workout_schedule/customize_workout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_tokens.dart';
import '../../models/muscle_group.dart';
import '../../models/workout_day.dart';

class CustomizeWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutDay currentDay;

  const CustomizeWorkoutScreen({
    super.key,
    required this.currentDay,
  });

  @override
  ConsumerState<CustomizeWorkoutScreen> createState() => _CustomizeWorkoutScreenState();
}

class _CustomizeWorkoutScreenState extends ConsumerState<CustomizeWorkoutScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  MuscleGroup? _selectedMuscleFilter;
  
  // Список всех доступных упражнений по группам мышц
  final Map<MuscleGroup, List<String>> _allExercises = {
    MuscleGroup.chest: [
      'bench press',
      'push-up',
      'dip',
      'cable fly',
      'incline press',
    ],
    MuscleGroup.back: [
      'pull-up',
      'row',
      'deadlift',
      'lat pulldown',
      'face pull',
    ],
    MuscleGroup.legs: [
      'squat',
      'lunge',
      'leg press',
      'calf raise',
      'leg curl',
    ],
    MuscleGroup.shoulders: [
      'shoulder press',
      'lateral raise',
      'front raise',
      'rear delt fly',
    ],
    MuscleGroup.arms: [
      'curl',
      'tricep extension',
      'hammer curl',
      'skull crusher',
    ],
    MuscleGroup.core: [
      'plank',
      'crunch',
      'russian twist',
      'leg raise',
      'mountain climber',
    ],
  };

  // Текущие выбранные упражнения (из currentDay)
  late Set<String> _selectedExercises;

  @override
  void initState() {
    super.initState();
    _selectedExercises = widget.currentDay.exercises.map((e) => e.name).toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<MuscleGroup, String>> get _filteredExercises {
    List<MapEntry<MuscleGroup, String>> allExercisesList = [];
    
    // Преобразуем Map в List для фильтрации
    _allExercises.forEach((group, exercises) {
      for (var exercise in exercises) {
        allExercisesList.add(MapEntry(group, exercise));
      }
    });

    // Фильтр по группе мышц
    if (_selectedMuscleFilter != null) {
      allExercisesList = allExercisesList
          .where((e) => e.key == _selectedMuscleFilter)
          .toList();
    }

    // Фильтр по поиску
    if (_searchQuery.isNotEmpty) {
      allExercisesList = allExercisesList
          .where((e) => e.value.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return allExercisesList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.bgBase,
      appBar: AppBar(
        backgroundColor: DesignTokens.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: DesignTokens.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customize Workout',
          style: DesignTokens.h2.copyWith(
            color: DesignTokens.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Сохранить изменения
              Navigator.pop(context, _selectedExercises.toList());
            },
            child: Text(
              'Save',
              style: DesignTokens.bodyLarge.copyWith(
                color: DesignTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: DesignTokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: TextStyle(color: DesignTokens.textSecondary),
                prefixIcon: const Icon(Icons.search, color: DesignTokens.textSecondary),
                filled: true,
                fillColor: DesignTokens.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: DesignTokens.textSecondary),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Фильтр по группам мышц
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMuscleFilterChip('All', null),
                const SizedBox(width: 8),
                ...MuscleGroup.values.map((group) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildMuscleFilterChip(group.displayName, group),
                )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Секция: Выбранные упражнения
          if (_selectedExercises.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected (${_selectedExercises.length})',
                    style: DesignTokens.h3.copyWith(
                      color: DesignTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedExercises.clear();
                      });
                    },
                    child: Text(
                      'Clear All',
                      style: DesignTokens.bodyMedium.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Список упражнений
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final entry = _filteredExercises[index];
                final isSelected = _selectedExercises.contains(entry.value);
                final isCurrentDayExercise = widget.currentDay.exercises
                    .any((e) => e.name == entry.value);

                return _buildExerciseItem(
                  exercise: entry.value,
                  muscleGroup: entry.key,
                  isSelected: isSelected,
                  isOriginal: isCurrentDayExercise,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleFilterChip(String label, MuscleGroup? group) {
    final isSelected = _selectedMuscleFilter == group;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMuscleFilter = group;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? DesignTokens.textPrimary : DesignTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? DesignTokens.textPrimary 
                : DesignTokens.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: DesignTokens.bodyMedium.copyWith(
            color: isSelected ? DesignTokens.bgBase : DesignTokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseItem({
    required String exercise,
    required MuscleGroup muscleGroup,
    required bool isSelected,
    required bool isOriginal,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isOriginal 
            ? DesignTokens.surface.withOpacity(0.8)
            : DesignTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: isOriginal
            ? Border.all(color: DesignTokens.textPrimary.withOpacity(0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedExercises.remove(exercise);
              } else {
                _selectedExercises.add(exercise);
              }
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSelected ? DesignTokens.textPrimary : Colors.transparent,
              border: Border.all(
                color: isSelected 
                    ? DesignTokens.textPrimary 
                    : DesignTokens.textSecondary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: DesignTokens.bgBase,
                  )
                : null,
          ),
        ),
        title: Text(
          exercise,
          style: DesignTokens.bodyLarge.copyWith(
            color: DesignTokens.textPrimary,
            fontWeight: isOriginal ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          muscleGroup.displayName,
          style: DesignTokens.bodySmall.copyWith(
            color: DesignTokens.textSecondary,
          ),
        ),
        trailing: isOriginal
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignTokens.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Current',
                  style: DesignTokens.bodySmall.copyWith(
                    color: DesignTokens.textPrimary,
                    fontSize: 10,
                  ),
                ),
              )
            : null,
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedExercises.remove(exercise);
            } else {
              _selectedExercises.add(exercise);
            }
          });
        },
      ),
    );
  }
}
