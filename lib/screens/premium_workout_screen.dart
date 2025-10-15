import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

import '../core/design_tokens.dart';
import '../core/premium_components.dart';
import '../core/theme.dart';
import '../services/workout_media_service.dart';
import '../widgets/workout_media.dart';

/// Premium Workout Screen с muscle map и таймером
class PremiumWorkoutScreen extends ConsumerStatefulWidget {
  final String? selectedExercise;
  final List<String>? dayPlan;
  
  const PremiumWorkoutScreen({
    super.key, 
    this.selectedExercise, 
    this.dayPlan,
  });
  
  @override
  ConsumerState<PremiumWorkoutScreen> createState() => _PremiumWorkoutScreenState();
}

class _PremiumWorkoutScreenState extends ConsumerState<PremiumWorkoutScreen>
    with TickerProviderStateMixin {
  
  // Timer state
  Timer? _timer;
  int _seconds = 45;
  int _totalSeconds = 45;
  bool _isRunning = false;
  bool _isWorkPhase = true;
  
  // Workout state
  late List<String> _exercises;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _totalSets = 3;
  
  // Exercise data
  String? _gifUrl;
  String? _imageUrl;
  String? _videoUrl;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _progressController;
  
  @override
  void initState() {
    super.initState();
    
    _exercises = widget.dayPlan ?? [
      widget.selectedExercise ?? 'push up',
      'plank',
      'squat',
    ];
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _loadExerciseMedia();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  void _loadExerciseMedia() {
    final currentExercise = _exercises[_currentExerciseIndex];
    // В реальном приложении здесь была бы загрузка из API
    setState(() {
      _gifUrl = 'https://example.com/${currentExercise}.gif';
      _imageUrl = 'https://example.com/${currentExercise}.jpg';
      _videoUrl = null;
    });
  }
  
  void _startTimer() {
    if (_isRunning) return;
    
    setState(() => _isRunning = true);
    _pulseController.repeat();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
          _progressController.animateTo(
            (_totalSeconds - _seconds) / _totalSeconds,
            duration: const Duration(milliseconds: 100),
          );
        } else {
          _completeCurrentPhase();
        }
      });
    });
  }
  
  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() => _isRunning = false);
  }
  
  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _seconds = _totalSeconds;
    });
    _progressController.reset();
  }
  
  void _completeCurrentPhase() {
    HapticFeedback.mediumImpact();
    
    if (_isWorkPhase) {
      // Завершили подход
      if (_currentSet < _totalSets) {
        // Переход к отдыху
        setState(() {
          _isWorkPhase = false;
          _totalSeconds = 15; // 15 секунд отдыха
          _seconds = _totalSeconds;
        });
        _resetTimer();
        _startTimer();
      } else {
        // Переход к следующему упражнению
        _nextExercise();
      }
    } else {
      // Завершили отдых
      setState(() {
        _isWorkPhase = true;
        _currentSet++;
        _totalSeconds = 45; // 45 секунд работы
        _seconds = _totalSeconds;
      });
      _resetTimer();
      _startTimer();
    }
  }
  
  void _nextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _isWorkPhase = true;
        _totalSeconds = 45;
        _seconds = _totalSeconds;
      });
      _resetTimer();
      _loadExerciseMedia();
    } else {
      _finishWorkout();
    }
  }
  
  void _finishWorkout() {
    _resetTimer();
    showDialog(
      context: context,
      builder: (context) => _WorkoutCompleteDialog(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final currentExercise = _exercises[_currentExerciseIndex];
    
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  child: Column(
                    children: [
                      // Progress Bar
                      _buildWorkoutProgress(),
                      const SizedBox(height: DesignTokens.space24),
                      
                      // Exercise Media
                      _buildExerciseMedia(),
                      const SizedBox(height: DesignTokens.space24),
                      
                      // Exercise Info
                      _buildExerciseInfo(currentExercise),
                      const SizedBox(height: DesignTokens.space24),
                      
                      // Muscle Map
                      _buildMuscleMap(currentExercise),
                      const SizedBox(height: DesignTokens.space24),
                      
                      // Timer
                      _buildTimer(),
                      const SizedBox(height: DesignTokens.space24),
                      
                      // Controls
                      _buildControls(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopBar() {
    return PremiumComponents.glassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space16,
        vertical: DesignTokens.space12,
      ),
      child: Row(
        children: [
          PremiumComponents.glassButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              size: DesignTokens.iconMedium,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Тренировка',
                  style: DesignTokens.h3,
                ),
                Text(
                  '${_currentExerciseIndex + 1} из ${_exercises.length} упражнений',
                  style: DesignTokens.caption,
                ),
              ],
            ),
          ),
          PremiumComponents.progressChip(
            text: 'Подход $_currentSet/$_totalSets',
            color: DesignTokens.primaryAccent,
            icon: Icons.fitness_center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutProgress() {
    final progress = (_currentExerciseIndex + 1) / _exercises.length;
    
    return PremiumComponents.glassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Прогресс тренировки', style: DesignTokens.bodyLarge),
              Text(
                '${(progress * 100).round()}%',
                style: DesignTokens.bodyLarge.copyWith(
                  color: DesignTokens.primaryAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: DesignTokens.glassOverlay,
            valueColor: const AlwaysStoppedAnimation(DesignTokens.primaryAccent),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
  
  Widget _buildExerciseMedia() {
    return PremiumComponents.glassCard(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          color: Colors.black26,
        ),
        child: WorkoutMedia(
          imageUrl: _imageUrl,
          gifUrl: _gifUrl,
          videoUrl: _videoUrl,
        ),
      ),
    );
  }
  
  Widget _buildExerciseInfo(String exercise) {
    final formattedName = exercise.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
    
    return PremiumComponents.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formattedName,
                  style: DesignTokens.h2,
                ),
              ),
              PremiumComponents.progressChip(
                text: _isWorkPhase ? 'Работа' : 'Отдых',
                color: _isWorkPhase ? DesignTokens.success : DesignTokens.warning,
                icon: _isWorkPhase ? Icons.fitness_center : Icons.pause,
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            _getExerciseDescription(exercise),
            style: DesignTokens.bodyMedium,
          ),
          const SizedBox(height: DesignTokens.space16),
          
          // Technique tips
          Container(
            padding: const EdgeInsets.all(DesignTokens.space12),
            decoration: BoxDecoration(
              color: DesignTokens.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              border: Border.all(
                color: DesignTokens.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: DesignTokens.info,
                  size: DesignTokens.iconMedium,
                ),
                const SizedBox(width: DesignTokens.space8),
                Expanded(
                  child: Text(
                    _getExerciseTip(exercise),
                    style: DesignTokens.bodySmall.copyWith(
                      color: DesignTokens.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMuscleMap(String exercise) {
    final activeMuscles = _getActiveMuscles(exercise);
    
    return PremiumComponents.muscleMap(
      activeMuscleGroups: activeMuscles,
      onToggleView: () {
        // Toggle front/back view
      },
    );
  }
  
  Widget _buildTimer() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return PremiumComponents.glassCard(
          child: Column(
            children: [
              // Timer Circle
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: DesignTokens.glassOverlay,
                        valueColor: const AlwaysStoppedAnimation(Colors.transparent),
                      ),
                    ),
                    
                    // Progress circle
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: _progressController.value,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          _isWorkPhase ? DesignTokens.success : DesignTokens.warning,
                        ),
                      ),
                    ),
                    
                    // Timer text
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = _isRunning 
                          ? 1.0 + (_pulseController.value * 0.05)
                          : 1.0;
                        
                        return Transform.scale(
                          scale: scale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(_seconds),
                                style: DesignTokens.h1.copyWith(
                                  fontSize: 48,
                                  color: _isWorkPhase 
                                    ? DesignTokens.success 
                                    : DesignTokens.warning,
                                ),
                              ),
                              Text(
                                _isWorkPhase ? 'РАБОТА' : 'ОТДЫХ',
                                style: DesignTokens.overline.copyWith(
                                  color: _isWorkPhase 
                                    ? DesignTokens.success 
                                    : DesignTokens.warning,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: PremiumComponents.glassButton(
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            isPrimary: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: DesignTokens.iconMedium,
                ),
                const SizedBox(width: DesignTokens.space8),
                Text(
                  _isRunning ? 'Пауза' : 'Старт',
                  style: DesignTokens.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.space12),
        PremiumComponents.glassButton(
          onPressed: _resetTimer,
          child: const Icon(
            Icons.refresh,
            color: Colors.white,
            size: DesignTokens.iconMedium,
          ),
        ),
        const SizedBox(width: DesignTokens.space12),
        PremiumComponents.glassButton(
          onPressed: _nextExercise,
          child: const Icon(
            Icons.skip_next,
            color: Colors.white,
            size: DesignTokens.iconMedium,
          ),
        ),
      ],
    );
  }
  
  // Helper methods
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  String _getExerciseDescription(String exercise) {
    switch (exercise.toLowerCase()) {
      case 'push up':
        return 'Классическое отжимание для развития груди, плеч и трицепса';
      case 'plank':
        return 'Статическое упражнение для укрепления мышц кора';
      case 'squat':
        return 'Приседание для развития ног и ягодиц';
      default:
        return 'Отличное упражнение для всего тела';
    }
  }
  
  String _getExerciseTip(String exercise) {
    switch (exercise.toLowerCase()) {
      case 'push up':
        return 'Держите тело прямо, опускайтесь до касания грудью пола';
      case 'plank':
        return 'Напрягите пресс и держите тело в одной линии';
      case 'squat':
        return 'Отводите таз назад, колени не выходят за носки';
      default:
        return 'Следите за техникой и дыханием';
    }
  }
  
  Set<String> _getActiveMuscles(String exercise) {
    switch (exercise.toLowerCase()) {
      case 'push up':
        return {'Грудь', 'Плечи', 'Руки'};
      case 'plank':
        return {'Пресс', 'Спина'};
      case 'squat':
        return {'Ноги', 'Ягодицы'};
      default:
        return {'Грудь'};
    }
  }
}

class _WorkoutCompleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PremiumComponents.glassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: DesignTokens.success,
              size: 64,
            ).animate().scale(
              duration: DesignTokens.durationMedium,
              curve: DesignTokens.easeOutQuart,
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'Тренировка завершена!',
              style: DesignTokens.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              'Отличная работа! Продолжайте в том же духе.',
              style: DesignTokens.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space24),
            Row(
              children: [
                Expanded(
                  child: PremiumComponents.glassButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Завершить'),
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: PremiumComponents.glassButton(
                    onPressed: () {
                      // TODO: Share workout
                      Navigator.of(context).pop();
                    },
                    isPrimary: true,
                    child: const Text('Поделиться'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}