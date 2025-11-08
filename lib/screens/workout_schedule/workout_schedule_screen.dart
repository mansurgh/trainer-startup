import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/workout_day.dart';
import '../../models/exercise.dart';
import '../../models/muscle_group.dart';
import '../../services/workout_repository.dart';
import '../../theme/tokens.dart';
import '../workout_screen_improved.dart';
import '../ai_chat_screen.dart';
import 'customize_workout_screen.dart';
import 'widgets/day_selector.dart';
import 'widgets/exercise_card.dart';

class WorkoutScheduleScreen extends StatefulWidget {
  const WorkoutScheduleScreen({super.key});

  @override
  State<WorkoutScheduleScreen> createState() => _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends State<WorkoutScheduleScreen> {
  final WorkoutRepository _repository = WorkoutRepository();
  
  List<WorkoutDay> _weekPlan = [];
  int _selectedDayIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = DateTime.now().weekday - 1; // Monday = 0
    _loadWeekPlan();
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
    return SingleChildScrollView(
      child: Padding(
        padding: T.p16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Header
            const Text(
              'Workout Schedule',
              style: TextStyle(
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: T.text, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'AI Trainer Chat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
                onTap: _currentDay.exercises.isEmpty ? null : () {
                  // Navigate to improved workout screen with today's exercises
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WorkoutScreenImproved(
                        dayPlan: _currentDay.exercises.map((e) => e.name).toList(),
                      ),
                    ),
                  );
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
                            ? 'Rest Day - No Workout' 
                            : 'Start Workout',
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
                  child: const Text(
                    'Customize Workout',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
          Icon(
            Icons.spa_outlined,
            color: T.textSec,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Rest Day',
            style: TextStyle(
              color: T.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recovery is just as important as training',
            style: TextStyle(
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
      }
    });
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
          content: const Text('Workout updated successfully'),
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
          content: const Text('Failed to update workout'),
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