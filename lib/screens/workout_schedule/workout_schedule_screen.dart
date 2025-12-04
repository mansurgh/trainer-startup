import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/workout_day.dart';
import '../../models/exercise.dart';
import '../../models/muscle_group.dart';
import '../../services/workout_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_alert.dart';
import '../workout_screen_improved.dart';
import '../ai_chat_screen.dart';
import 'customize_workout_screen.dart';
import 'widgets/day_selector.dart';
import 'widgets/exercise_card.dart';
import '../../l10n/app_localizations.dart';

class WorkoutScheduleScreen extends StatefulWidget {
  const WorkoutScheduleScreen({super.key});

  @override
  State<WorkoutScheduleScreen> createState() => _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends State<WorkoutScheduleScreen> with AutomaticKeepAliveClientMixin {
  final WorkoutRepository _repository = WorkoutRepository();
  
  List<WorkoutDay> _weekPlan = [];
  int _selectedDayIndex = 0;
  bool _isLoading = true;
  String? _error;
  List<bool> _completedDays = List.filled(7, false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = DateTime.now().weekday - 1; // Monday = 0
    _loadWeekPlan();
    _loadCompletedDays();
  }
  
  Future<void> _loadCompletedDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'anonymous';
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateKey = '${date.year}-${date.month}-${date.day}';
        _completedDays[i] = prefs.getBool('workout_completed_${userId}_$dateKey') ?? false;
      }
      
      if (mounted) setState(() {});
    } catch (e) {
      print('[WorkoutSchedule] Error loading completed days: $e');
    }
  }

  Future<void> _loadWeekPlan() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      
      final weekPlan = await _repository.getWeekPlan(startOfWeek);
      
      // Загружаем кастомные тренировки из SharedPreferences
      await _loadCustomWorkouts(weekPlan);
      
      setState(() {
        _weekPlan = weekPlan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load workout plan';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadCustomWorkouts(List<WorkoutDay> weekPlan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'anonymous';
      
      for (int i = 0; i < weekPlan.length; i++) {
        final day = weekPlan[i];
        final dateKey = '${day.date.year}-${day.date.month}-${day.date.day}';
        final savedExercises = prefs.getStringList('custom_workout_${userId}_$dateKey');
        
        if (savedExercises != null && savedExercises.isNotEmpty) {
          print('[Workout] Loading custom workout for $dateKey: $savedExercises');
          
          // Создаём упражнения из сохранённых названий
          final customExercises = savedExercises.map<Exercise>((name) {
            return Exercise(
              id: '${DateTime.now().millisecondsSinceEpoch}_${name.hashCode}',
              name: name,
              group: _getMuscleGroupFromName(name),
              sets: 3,
              reps: 12,
              completedSets: 0,
            );
          }).toList();
          
          // Заменяем упражнения в дне
          weekPlan[i] = WorkoutDay(
            date: day.date,
            targetGroups: day.targetGroups,
            exercises: customExercises,
          );
        }
      }
    } catch (e) {
      print('[Workout] Error loading custom workouts: $e');
    }
  }

  WorkoutDay get _currentDay {
    if (_weekPlan.isEmpty) {
      return WorkoutDay(
        date: DateTime.now(),
        targetGroups: [],
        exercises: [],
      );
    }
    return _weekPlan[_selectedDayIndex];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        child: _isLoading 
          ? _buildLoadingState()
          : _error != null
            ? _buildErrorState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: T.accent,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: T.textSec,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Something went wrong',
            style: const TextStyle(
              color: T.textSec,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _loadWeekPlan,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: T.accent,
                borderRadius: BorderRadius.all(T.r10),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: T.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: T.p16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Header
            Text(
              l10n.workoutScheduleTitle,
              style: const TextStyle(
                color: T.text,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Day Selector
            DaySelector(
              selectedIndex: _selectedDayIndex,
              completedDays: _completedDays,
              onDaySelected: (index) {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            // Current Day Title
            Text(
              _currentDay.title,
              style: const TextStyle(
                color: T.text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Exercise List
            if (_currentDay.exercises.isEmpty)
              _buildRestDay()
            else
              ..._currentDay.exercises.map((exercise) => ExerciseCard(
                exercise: exercise,
                onTap: () => _onExerciseTapped(exercise),
              )),
            
            const SizedBox(height: 24),
            
            // AI Trainer Chat Button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AIChatScreen(chatType: 'workout'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    color: T.cardElevated,
                    borderRadius: BorderRadius.all(T.r16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: T.text, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.aiTrainerChat,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: T.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Start Workout Button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _currentDay.exercises.isEmpty ? null : () async {
                  // Проверяем что выбран сегодняшний день
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final selectedDate = DateTime(_currentDay.date.year, _currentDay.date.month, _currentDay.date.day);
                  
                  if (!selectedDate.isAtSameMomentAs(today)) {
                    AppAlert.show(
                      context,
                      title: l10n.workoutAvailableTodayOnly,
                      description: l10n.workoutAvailableTodayOnlyDesc,
                      type: AlertType.warning,
                      duration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  
                  // Navigate to improved workout screen with today's exercises
                  final completed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (context) => WorkoutScreenImproved(
                        dayPlan: _currentDay.exercises.map((e) => e.name).toList(),
                        workoutDate: _currentDay.date,
                      ),
                    ),
                  );
                  
                  // Если тренировка завершена, обновляем статистику
                  if (completed == true && mounted) {
                    await _loadCompletedDays();
                    
                    AppAlert.show(
                      context,
                      title: l10n.workoutCompleted,
                      description: l10n.workoutCompletedDesc,
                      type: AlertType.success,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _currentDay.exercises.isEmpty 
                        ? T.cardElevated.withOpacity(0.3)
                        : T.cardElevated,
                    borderRadius: const BorderRadius.all(T.r16),
                    border: Border.all(
                      color: T.text.withOpacity(_currentDay.exercises.isEmpty ? 0.1 : 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentDay.exercises.isEmpty 
                            ? Icons.block 
                            : Icons.play_circle_outline, 
                        color: T.text.withOpacity(_currentDay.exercises.isEmpty ? 0.3 : 1.0), 
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentDay.exercises.isEmpty 
                            ? '${l10n.restDayTitle} - ${l10n.noActivity}' 
                            : _completedDays[_selectedDayIndex] ? l10n.startAgain : l10n.startWorkout,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: T.text.withOpacity(_currentDay.exercises.isEmpty ? 0.3 : 1.0),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Customize Button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _showCustomizeSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    color: T.cardElevated,
                    borderRadius: BorderRadius.all(T.r16),
                  ),
                  child: Text(
                    l10n.customizeWorkout,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: T.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRestDay() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: const BorderRadius.all(T.r16),
        border: Border.all(color: T.border, width: 0.5),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.spa_outlined,
            color: T.textSec,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.restDayTitle,
            style: const TextStyle(
              color: T.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.restDayDesc,
            style: const TextStyle(
              color: T.textSec,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onMuscleGroupTapped(MuscleGroup group) {
    HapticFeedback.lightImpact();
    // В будущем можно добавить фильтрацию упражнений по группе мышц
  }

  void _onExerciseTapped(exercise) {
    HapticFeedback.lightImpact();
    // В будущем можно открыть детали упражнения или обновить прогресс
  }

  void _showCustomizeSheet() {
    HapticFeedback.lightImpact();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomizeWorkoutScreen(
          currentDay: _currentDay,
        ),
      ),
    ).then((selectedExercises) {
      if (selectedExercises != null && selectedExercises is List<String>) {
        print('Selected exercises: $selectedExercises');
        
        // Создаем новые упражнения из выбранных
        final newExercises = selectedExercises.map<Exercise>((name) {
          return Exercise(
            id: '${DateTime.now().millisecondsSinceEpoch}_${name.hashCode}',
            name: name,
            group: _getMuscleGroupFromName(name),
            sets: 3,
            reps: 12,
            completedSets: 0,
          );
        }).toList();
        
        // Обновляем день с новыми упражнениями
        final updatedDay = WorkoutDay(
          date: _currentDay.date,
          targetGroups: _currentDay.targetGroups,
          exercises: newExercises,
        );
        
        _updateWorkoutDay(updatedDay);
        _saveCustomWorkout(updatedDay); // Сохраняем кастомизацию
      }
    });
  }
  
  Future<void> _saveCustomWorkout(WorkoutDay day) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'anonymous';
      final dateKey = '${day.date.year}-${day.date.month}-${day.date.day}';
      
      // Сохраняем список упражнений
      final exerciseNames = day.exercises.map((e) => e.name).toList();
      await prefs.setStringList('custom_workout_${userId}_$dateKey', exerciseNames);
      
      print('[Workout] Saved custom workout for $dateKey: $exerciseNames');
    } catch (e) {
      print('[Workout] Error saving custom workout: $e');
    }
  }
  
  MuscleGroup _getMuscleGroupFromName(String exerciseName) {
    final lowerName = exerciseName.toLowerCase();
    
    if (lowerName.contains('bench') || lowerName.contains('press') && lowerName.contains('chest') || 
        lowerName.contains('fly') || lowerName.contains('dip')) {
      return MuscleGroup.chest;
    } else if (lowerName.contains('pull') || lowerName.contains('row') || 
               lowerName.contains('deadlift') || lowerName.contains('back')) {
      return MuscleGroup.back;
    } else if (lowerName.contains('squat') || lowerName.contains('lunge') || 
               lowerName.contains('leg') || lowerName.contains('calf')) {
      return MuscleGroup.legs;
    } else if (lowerName.contains('shoulder') || lowerName.contains('lateral') || 
               lowerName.contains('front raise')) {
      return MuscleGroup.shoulders;
    } else if (lowerName.contains('curl') || lowerName.contains('tricep') || 
               lowerName.contains('bicep') || lowerName.contains('arm')) {
      return MuscleGroup.arms;
    } else if (lowerName.contains('plank') || lowerName.contains('crunch') || 
               lowerName.contains('ab') || lowerName.contains('core')) {
      return MuscleGroup.core;
    }
    
    return MuscleGroup.chest; // Default
  }

  Future<void> _updateWorkoutDay(WorkoutDay updatedDay) async {
    try {
      setState(() {
        _weekPlan[_selectedDayIndex] = updatedDay;
      });
      
      await _repository.updateDay(updatedDay);
      
      // Показываем успешное сохранение
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.workoutUpdated),
          backgroundColor: T.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToUpdateWorkout),
          backgroundColor: T.muscle,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}