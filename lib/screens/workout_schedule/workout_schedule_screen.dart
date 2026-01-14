import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/workout_day.dart';
import '../../models/exercise.dart';
import '../../models/muscle_group.dart';
import '../../services/workout_repository.dart';
import '../../services/noir_toast_service.dart';
import '../../services/storage_service.dart';
import '../../services/translation_service.dart';
import '../../theme/tokens.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/navigation/navigation.dart';
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
      
      // Сначала проверяем локальные флаги
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateKey = '${date.year}-${date.month}-${date.day}';
        _completedDays[i] = prefs.getBool('workout_completed_${userId}_$dateKey') ?? false;
      }
      
      // Дополнительно проверяем сохранённые workout sessions
      final sessions = await StorageService.getWorkoutSessions();
      for (final session in sessions) {
        final sessionDateStr = session['date'] as String?;
        if (sessionDateStr != null && session['completed'] == 1) {
          final sessionDate = DateTime.tryParse(sessionDateStr);
          if (sessionDate != null) {
            // Проверяем, попадает ли сессия в текущую неделю
            for (int i = 0; i < 7; i++) {
              final weekDate = startOfWeek.add(Duration(days: i));
              if (sessionDate.year == weekDate.year &&
                  sessionDate.month == weekDate.month &&
                  sessionDate.day == weekDate.day) {
                _completedDays[i] = true;
                break;
              }
            }
          }
        }
      }
      
      if (mounted) setState(() {});
    } catch (e) {
      if (kDebugMode) print('[WorkoutSchedule] Error loading completed days: $e');
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
          if (kDebugMode) print('[Workout] Loading custom workout for $dateKey: $savedExercises');
          
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
      if (kDebugMode) print('[Workout] Error loading custom workouts: $e');
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
      backgroundColor: kOledBlack,
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
    return Center(
      child: CircularProgressIndicator(
        color: kElectricAmberStart,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: kTextSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Something went wrong',
            style: TextStyle(
              color: kTextSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _loadWeekPlan,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kElectricAmberStart, kElectricAmberEnd],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: kOledBlack,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Header with gradient text
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [kElectricAmberStart, kElectricAmberEnd],
              ).createShader(bounds),
              child: Text(
                l10n.workoutScheduleTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
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
              TranslationService.translateWorkoutType(_currentDay.title, context),
              style: TextStyle(
                color: kTextPrimary,
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
                  decoration: BoxDecoration(
                    color: kObsidianSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kObsidianBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: kElectricAmberStart, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.aiTrainerChat,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kTextPrimary,
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
                    gradient: _currentDay.exercises.isEmpty 
                        ? null
                        : const LinearGradient(
                            colors: [kElectricAmberStart, kElectricAmberEnd],
                          ),
                    color: _currentDay.exercises.isEmpty 
                        ? kObsidianSurface.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _currentDay.exercises.isEmpty ? null : [
                      BoxShadow(
                        color: kElectricAmberStart.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentDay.exercises.isEmpty 
                            ? Icons.block 
                            : Icons.play_circle_outline, 
                        color: _currentDay.exercises.isEmpty 
                            ? kTextTertiary 
                            : kOledBlack, 
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentDay.exercises.isEmpty 
                            ? '${l10n.restDayTitle} - ${l10n.noActivity}' 
                            : _completedDays[_selectedDayIndex] ? l10n.startAgain : l10n.startWorkout,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _currentDay.exercises.isEmpty 
                              ? kTextTertiary 
                              : kOledBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                  decoration: BoxDecoration(
                    color: kObsidianSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kObsidianBorder),
                  ),
                  child: Text(
                    l10n.customizeWorkout,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Spacer for floating nav bar clearance
            SizedBox(height: NoirGlassScrollPadding.navBarPadding(context).bottom),
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
        color: kObsidianSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kObsidianBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(
            Icons.spa_outlined,
            color: kSuccessGreen.withOpacity(0.7),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.restDayTitle,
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.restDayDesc,
            style: TextStyle(
              color: kTextSecondary,
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
        if (kDebugMode) print('Selected exercises: $selectedExercises');
        
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
      
      if (kDebugMode) print('[Workout] Saved custom workout for $dateKey: $exerciseNames');
    } catch (e) {
      if (kDebugMode) print('[Workout] Error saving custom workout: $e');
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
      if (mounted) {
        NoirToast.success(context, AppLocalizations.of(context)!.workoutUpdated);
      }
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, AppLocalizations.of(context)!.failedToUpdateWorkout);
      }
    }
  }
}