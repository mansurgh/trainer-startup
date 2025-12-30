// lib/screens/workout_screen_improved.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

import '../core/theme.dart';
import '../core/design_tokens.dart';
import '../state/exercisedb_providers.dart';
import '../widgets/workout_media.dart';
import '../services/storage_service.dart';
import '../state/activity_state.dart';

class WorkoutScreenImproved extends ConsumerStatefulWidget {
  final String? selectedExercise;
  final List<String>? dayPlan;
  final DateTime? workoutDate; // Дата тренировки из расписания
  
  const WorkoutScreenImproved({
    super.key,
    this.selectedExercise,
    this.dayPlan,
    this.workoutDate,
  });
  
  @override
  ConsumerState<WorkoutScreenImproved> createState() => _WorkoutScreenImprovedState();
}

class _WorkoutScreenImprovedState extends ConsumerState<WorkoutScreenImproved> {
  Timer? _timer;
  int _seconds = 60;
  int _total = 60;
  bool _running = false;
  bool _workPhase = true;
  bool _workoutStarted = false;
  
  int _workTime = 60;  // секунды на упражнение
  int _restTime = 30;  // секунды отдыха

  late List<String> _plan;
  int _currentIdx = 0;

  String? _gifUrl;
  String? _imageUrl;
  String? _videoUrl;
  bool _mediaLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedExercise != null) {
      _plan = [widget.selectedExercise!];
    } else if (widget.dayPlan != null && widget.dayPlan!.isNotEmpty) {
      _plan = widget.dayPlan!;
    } else {
      _plan = const ['barbell squat', 'push up', 'barbell bench press'];
    }
    _loadMediaForCurrent();
    
    // Показываем диалог настройки перед началом тренировки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWorkoutSetupDialog();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Диалог настройки времени перед началом тренировки
  Future<void> _showWorkoutSetupDialog() async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _WorkoutSetupDialog(
        initialWorkTime: _workTime,
        initialRestTime: _restTime,
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        _workTime = result['workTime']!;
        _restTime = result['restTime']!;
        _total = _workTime;
        _seconds = _workTime;
        _workoutStarted = true;
      });
    } else if (mounted) {
      // Пользователь отменил - возвращаемся назад
      Navigator.pop(context);
    }
  }

  // Завершение тренировки
  Future<void> _completeWorkout() async {
    _timer?.cancel();
    
    // Используем переданную дату или текущую
    final workoutDay = widget.workoutDate ?? DateTime.now();
    
    // Сохраняем тренировку в историю
    try {
      await StorageService.saveWorkoutSession(
        date: workoutDay,
        exerciseName: _plan.join(', '),
        sets: 3,
        reps: 10,
        weight: 0,
        duration: _workTime * _plan.length + _restTime * (_plan.length - 1),
        completed: true,
      );
      
      // Обновляем активность за выбранный день
      await _updateTodayActivity();
      
      // Инвалидируем провайдеры для обновления статистики
      ref.invalidate(activityDataProvider);
      ref.invalidate(workoutCountProvider);
    } catch (e) {
      if (kDebugMode) print('[Workout] Error saving workout: $e');
    }
    
    if (!mounted) return;
    
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignTokens.cardSurface,
        title: Text(l10n.workoutCompleted, style: DesignTokens.h3),
        content: Text(l10n.workoutCompletedDesc, style: DesignTokens.bodyMedium),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрываем диалог
              Navigator.pop(context, true); // Возвращаемся с результатом
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
  
  Future<void> _updateTodayActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? 'anonymous';
    
    // Используем переданную дату или текущую
    final workoutDay = widget.workoutDate ?? DateTime.now();
    final dateKey = '${workoutDay.year}-${workoutDay.month}-${workoutDay.day}';
    
    // Сохраняем, что тренировка выполнена (user-specific)
    await prefs.setBool('workout_completed_${userId}_$dateKey', true);
    
    if (kDebugMode) print('[Workout] Activity updated for user $userId on $dateKey (${_getDayName(workoutDay)})');
  }
  
  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  Future<void> _loadMediaForCurrent() async {
    setState(() {
      _mediaLoaded = false;
      _gifUrl = _imageUrl = _videoUrl = null;
    });

    final name = _plan[_currentIdx];
    try {
      final ex = await ref.read(exerciseByNameProvider(name).future);
      if (!mounted) return;
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      setState(() {
        _gifUrl = ex?.gifUrl;
        _imageUrl = ex?.imageUrl;
        _videoUrl = ex?.videoUrl;
        _mediaLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mediaLoaded = true;
      });
    }
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        if (_workPhase) {
          // Завершили упражнение - автоматически начинаем отдых
          setState(() {
            _workPhase = false;
            _seconds = _restTime;
            _total = _restTime;
          });
        } else {
          // Завершили отдых - переходим к следующему упражнению
          _timer?.cancel();
          setState(() => _running = false);
          
          if (_currentIdx < _plan.length - 1) {
            // Переходим к следующему упражнению
            setState(() {
              _currentIdx++;
              _workPhase = true;
              _seconds = _workTime;
              _total = _workTime;
            });
            _loadMediaForCurrent();
            // Автоматически запускаем следующее упражнение
            _toggle();
          } else {
            // Все упражнения завершены
            _completeWorkout();
          }
        }
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _workPhase = true;
      _seconds = _workTime;
      _total = _workTime;
    });
  }

  void _goToPrevious() {
    if (_currentIdx > 0) {
      _timer?.cancel();
      setState(() {
        _currentIdx--;
        _running = false;
        _workPhase = true;
        _seconds = _workTime;
        _total = _workTime;
      });
      _loadMediaForCurrent();
    }
  }

  void _goToNext() {
    if (_currentIdx < _plan.length - 1) {
      _timer?.cancel();
      setState(() {
        _currentIdx++;
        _running = false;
        _workPhase = true;
        _seconds = _workTime;
        _total = _workTime;
      });
      _loadMediaForCurrent();
    }
  }

  String _getLocalizedExerciseName(String name) {
    // Simple map for common exercises
    final map = {
      'barbell squat': 'Приседания со штангой',
      'push up': 'Отжимания',
      'barbell bench press': 'Жим лежа',
      'lateral raise': 'Махи гантелями в стороны',
      'cable lateral raise': 'Махи в кроссовере',
      'pull up': 'Подтягивания',
      'dumbbell shoulder press': 'Жим гантелей сидя',
      'dumbbell bicep curl': 'Сгибание на бицепс',
      'tricep pushdown': 'Разгибание на трицепс',
      'leg press': 'Жим ногами',
      'leg extension': 'Разгибание ног',
      'leg curl': 'Сгибание ног',
      'crunch': 'Скручивания',
      'plank': 'Планка',
    };
    
    // If localized name exists and locale is Russian, return it
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ru' && map.containsKey(name.toLowerCase())) {
      return map[name.toLowerCase()]!;
    }
    
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phaseLabel = _workPhase ? l10n.work : l10n.rest;

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('${_currentIdx + 1}/${_plan.length}'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              // Instagram-style progress bar
              Row(
                children: List.generate(_plan.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: index < _plan.length - 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentIdx
                            ? Colors.white
                            : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              
              // Navigation buttons + exercise name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 32),
                    onPressed: _currentIdx > 0 ? _goToPrevious : null,
                    color: _currentIdx > 0 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: Text(
                      _getLocalizedExerciseName(_plan[_currentIdx]),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 32),
                    onPressed: _currentIdx < _plan.length - 1 ? _goToNext : null,
                    color: _currentIdx < _plan.length - 1
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Media with smooth fade-in
              AnimatedOpacity(
                opacity: _mediaLoaded && (_gifUrl != null || _imageUrl != null || _videoUrl != null) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: WorkoutMedia(
                    gifUrl: _gifUrl,
                    imageUrl: _imageUrl,
                    videoUrl: _videoUrl,
                  ),
                ),
              ),
              
              const SizedBox(height: 14),

              // Timer
              Expanded(
                child: Center(
                  child: _RectangularTimer(
                    seconds: _seconds,
                    total: _total,
                    label: phaseLabel,
                  ),
                ),
              ),
              // Control buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _toggle,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(_running ? l10n.pause : l10n.start),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _reset,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(l10n.reset),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Диалог настройки времени тренировки
class _WorkoutSetupDialog extends StatefulWidget {
  final int initialWorkTime;
  final int initialRestTime;

  const _WorkoutSetupDialog({
    required this.initialWorkTime,
    required this.initialRestTime,
  });

  @override
  State<_WorkoutSetupDialog> createState() => _WorkoutSetupDialogState();
}

class _WorkoutSetupDialogState extends State<_WorkoutSetupDialog> {
  late int _workTime;
  late int _restTime;

  @override
  void initState() {
    super.initState();
    _workTime = widget.initialWorkTime;
    _restTime = widget.initialRestTime;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: DesignTokens.cardSurface,
      title: Text('⚙️ ${l10n.workoutSettingsTitle}', style: DesignTokens.h3),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.workoutSettingsSubtitle,
            style: const TextStyle(fontSize: 14, color: DesignTokens.textSecondary),
          ),
          const SizedBox(height: 24),
          
          // Время упражнения
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.exerciseLabel, style: DesignTokens.bodyMedium),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_workTime > 10) {
                        setState(() => _workTime -= 5);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: DesignTokens.textPrimary),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '$_workTime ${l10n.seconds}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_workTime < 300) {
                        setState(() => _workTime += 5);
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline, color: DesignTokens.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Время отдыха
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.restLabel, style: DesignTokens.bodyMedium),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_restTime > 5) {
                        setState(() => _restTime -= 5);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: DesignTokens.textPrimary),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '$_restTime ${l10n.seconds}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_restTime < 180) {
                        setState(() => _restTime += 5);
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline, color: DesignTokens.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'workTime': _workTime,
              'restTime': _restTime,
            });
          },
          child: Text(l10n.start),
        ),
      ],
    );
  }
}

class _RectangularTimer extends StatelessWidget {
  final int seconds;
  final int total;
  final String label;
  const _RectangularTimer({required this.seconds, required this.total, required this.label});

  @override
  Widget build(BuildContext context) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    final progress = (total - seconds) / total.clamp(1, 600);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            '$mm:$ss',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 64,
                  letterSpacing: -2,
                ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
