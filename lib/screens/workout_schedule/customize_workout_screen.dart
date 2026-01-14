// lib/screens/workout_schedule/customize_workout_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/noir_theme.dart';
import '../../models/muscle_group.dart';
import '../../models/workout_day.dart';
import '../../l10n/app_localizations.dart';
import '../../services/translation_service.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: kNoirBlack,
      appBar: AppBar(
        backgroundColor: kNoirCarbon,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kContentHigh),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.customizeWorkout,
          style: kNoirTitleMedium.copyWith(color: kContentHigh),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, _selectedExercises.toList());
            },
            child: Text(
              l10n.save,
              style: kNoirBodyLarge.copyWith(
                color: kContentHigh,
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
            padding: const EdgeInsets.all(kSpaceMD),
            child: _NoirSearchField(
              controller: _searchController,
              hintText: l10n.searchExercises,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              showClear: _searchQuery.isNotEmpty,
            ),
          ),

          // Фильтр по группам мышц
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
              children: [
                _buildMuscleFilterChip(l10n.all, null),
                const SizedBox(width: kSpaceXS),
                ...MuscleGroup.values.map((group) => Padding(
                  padding: const EdgeInsets.only(right: kSpaceXS),
                  child: _buildMuscleFilterChip(_getLocalizedMuscleGroup(context, group), group),
                )),
              ],
            ),
          ),

          const SizedBox(height: kSpaceMD),

          // Секция: Выбранные упражнения
          if (_selectedExercises.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.selected} (${_selectedExercises.length})',
                    style: kNoirTitleSmall.copyWith(
                      color: kContentHigh,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedExercises.clear();
                      });
                    },
                    child: Text(
                      l10n.clearAll,
                      style: kNoirBodyMedium.copyWith(
                        color: kContentMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kSpaceSM),
          ],

          // Список упражнений
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final entry = _filteredExercises[index];
                final isSelected = _selectedExercises.contains(entry.value);
                final isCurrentDayExercise = widget.currentDay.exercises
                    .any((e) => e.name == entry.value);

                return _buildExerciseItem(
                  context: context,
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

  String _getLocalizedMuscleGroup(BuildContext context, MuscleGroup group) {
    final l10n = AppLocalizations.of(context)!;
    switch (group) {
      case MuscleGroup.chest: return l10n.chest;
      case MuscleGroup.back: return l10n.back;
      case MuscleGroup.legs: return l10n.legs;
      case MuscleGroup.shoulders: return l10n.shoulders;
      case MuscleGroup.arms: return l10n.arms;
      case MuscleGroup.core: return l10n.core;
    }
  }

  Widget _buildMuscleFilterChip(String label, MuscleGroup? group) {
    final isSelected = _selectedMuscleFilter == group;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedMuscleFilter = group;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusLG),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
            decoration: BoxDecoration(
              color: isSelected 
                  ? kContentHigh 
                  : kNoirGraphite.withOpacity(0.5),
              borderRadius: BorderRadius.circular(kRadiusLG),
              border: Border.all(
                color: isSelected 
                    ? kContentHigh 
                    : kNoirSteel.withOpacity(0.3),
              ),
            ),
            child: Text(
              label,
              style: kNoirBodyMedium.copyWith(
                color: isSelected ? kNoirBlack : kContentHigh,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseItem({
    required BuildContext context,
    required String exercise,
    required MuscleGroup muscleGroup,
    required bool isSelected,
    required bool isOriginal,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: kSpaceSM),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusMD),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isOriginal 
                  ? kNoirGraphite.withOpacity(0.6)
                  : kNoirGraphite.withOpacity(0.4),
              borderRadius: BorderRadius.circular(kRadiusMD),
              border: isOriginal
                  ? Border.all(color: kContentHigh.withOpacity(0.3), width: 1)
                  : Border.all(color: kNoirSteel.withOpacity(0.2)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceXS),
              leading: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
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
                    color: isSelected ? kContentHigh : Colors.transparent,
                    border: Border.all(
                      color: isSelected 
                          ? kContentHigh 
                          : kContentMedium,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: kNoirBlack,
                        )
                      : null,
                ),
              ),
              title: Text(
                TranslationService.translateExercise(exercise, context),
                style: kNoirBodyLarge.copyWith(
                  color: kContentHigh,
                  fontWeight: isOriginal ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              subtitle: Text(
                _getLocalizedMuscleGroup(context, muscleGroup),
                style: kNoirBodySmall.copyWith(
                  color: kContentMedium,
                ),
              ),
              trailing: isOriginal
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kContentHigh.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.current,
                        style: kNoirBodySmall.copyWith(
                          color: kContentHigh,
                          fontSize: 10,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedExercises.remove(exercise);
                  } else {
                    _selectedExercises.add(exercise);
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Noir Glass Search Field
// =============================================================================

class _NoirSearchField extends StatelessWidget {
  const _NoirSearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.showClear = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusMD),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: kNoirGraphite.withOpacity(0.5),
            borderRadius: BorderRadius.circular(kRadiusMD),
            border: Border.all(color: kNoirSteel.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            style: kNoirBodyMedium.copyWith(color: kContentHigh),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: kNoirBodyMedium.copyWith(color: kContentLow),
              prefixIcon: const Icon(Icons.search, color: kContentMedium),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: kSpaceMD,
                vertical: kSpaceSM,
              ),
              suffixIcon: showClear
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: kContentMedium),
                      onPressed: onClear,
                    )
                  : null,
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
