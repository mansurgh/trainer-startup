// lib/screens/workout_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/noir_theme.dart';
import '../l10n/app_localizations.dart';
import '../core/translation_service.dart';
import '../services/storage_service.dart';
import '../providers/stats_provider.dart';

import '../core/theme.dart'; // GradientScaffold
import '../state/exercisedb_providers.dart';
import '../state/workout_settings_provider.dart';
import '../state/activity_state.dart' show activityDataProvider, workoutCountProvider;
import '../widgets/workout_media.dart';
import 'form_check_camera_screen.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  final String? selectedExercise;
  final List<String>? dayPlan;
  const WorkoutScreen({super.key, this.selectedExercise, this.dayPlan});
  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  Timer? _timer;
  int _seconds = 60;
  int _total = 60;
  bool _running = false;
  bool _workPhase = true;
  bool _workoutStarted = false;
  bool _gifLoaded = false; // Track GIF loading state
  
  int _workTime = 60;  // секунды на упражнение
  int _restTime = 30;  // секунды отдыха

  late List<String> _plan;
  int _currentIdx = 0;

  String? _gifUrl;
  String? _imageUrl;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    // Если выбрано конкретное упражнение, используем его, иначе план дня
    if (widget.selectedExercise != null) {
      _plan = [widget.selectedExercise!];
      _currentIdx = 0;
    } else if (widget.dayPlan != null && widget.dayPlan!.isNotEmpty) {
      _plan = widget.dayPlan!;
      _currentIdx = 0;
    } else {
      _plan = const [
        'barbell squat',
        'push up',
        'barbell bench press',
        'seated cable row',
      ];
      _currentIdx = 0;
    }

    // Загружаем сохраненные настройки
    final settings = ref.read(workoutSettingsProvider);
    _workTime = settings.workTime;
    _restTime = settings.restTime;

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
      // Сохраняем настройки глобально
      ref.read(workoutSettingsProvider.notifier).updateSettings(
        workTime: result['workTime'],
        restTime: result['restTime'],
      );

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
    final l10n = AppLocalizations.of(context)!;
    
    // Сохраняем тренировку в историю
    try {
      await StorageService.saveWorkoutSession(
        date: DateTime.now(),
        exerciseName: _plan.join(', '),
        sets: 3,
        reps: 10,
        weight: 0,
        duration: _workTime * _plan.length + _restTime * (_plan.length - 1),
        completed: true,
      );
      
      // Обновляем активность за сегодня
      await _updateTodayActivity();
      
      // Инвалидируем провайдеры для обновления статистики
      ref.invalidate(activityDataProvider);
      ref.invalidate(workoutCountProvider);
    } catch (e) {
      if (kDebugMode) print('[Workout] Error saving workout: $e');
    }
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => _NoirGlassDialog(
        title: l10n.workoutCompleted,
        content: l10n.workoutCompletedDesc,
        icon: Icons.emoji_events_rounded,
        confirmText: l10n.ok,
        onConfirm: () {
          Navigator.pop(dialogContext);
          Navigator.pop(context, true);
        },
      ),
    );
  }
  
  Future<void> _updateTodayActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? 'anonymous';
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}';
    
    // Сохраняем, что тренировка выполнена (user-specific)
    await prefs.setBool('workout_completed_${userId}_$dateKey', true);
    
    if (kDebugMode) print('[Workout] Activity updated for user $userId on $dateKey');
  }

  Future<void> _loadMediaForCurrent() async {
    // Reset GIF loaded state when loading new media
    setState(() => _gifLoaded = false);
    
    final name = _plan[_currentIdx];
    try {
      final ex = await ref.read(exerciseByNameProvider(name).future);
      if (!mounted) return;
      setState(() {
        _gifUrl   = ex?.gifUrl;
        _imageUrl = ex?.imageUrl;
        _videoUrl = ex?.videoUrl;
      });

      final shown = (_gifUrl ?? _imageUrl ?? _videoUrl ?? 'NO MEDIA');
      final safeShown = shown.toString().contains('rapidapi-key=')
          ? shown.toString().split('&rapidapi-key=').first
          : shown;
      // безопасный лог без ключа:
      // ignore: avoid_print
      if (kDebugMode) print('[Workout] media "$name" -> $safeShown');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _gifUrl = _imageUrl = _videoUrl = null;
        _gifLoaded = true; // Mark as loaded even on error so timer can start
      });
      // ignore: avoid_print
      if (kDebugMode) print('[Workout] media load error for "$name": $e');
    }
  }
  
  void _onGifLoaded() {
    if (mounted && !_gifLoaded) {
      setState(() => _gifLoaded = true);
    }
  }
  
  void _openFormCheck() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormCheckCameraScreen(
          exerciseName: TranslationService.translateExercise(_plan[_currentIdx], context),
          exerciseId: null,
        ),
      ),
    );
  }
  
  /// Show exercise details in a bottom sheet with GIF and description
  void _showExerciseDetails() async {
    HapticFeedback.lightImpact();
    
    final exerciseName = _plan[_currentIdx];
    final localizedName = _getLocalizedName(exerciseName);
    final l10n = AppLocalizations.of(context)!;
    
    // Get exercise data for description
    final exercise = await ref.read(exerciseByNameProvider(exerciseName).future);
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ExerciseDetailSheet(
        exerciseName: localizedName,
        originalName: exerciseName,
        gifUrl: _gifUrl,
        imageUrl: _imageUrl,
        targetMuscle: exercise?.target ?? '',
        equipment: exercise?.equipment ?? '',
        instructions: exercise?.instructions ?? [],
        l10n: l10n,
      ),
    );
  }
  
  /// Get localized exercise name using TranslationService
  String _getLocalizedName(String name) {
    return TranslationService.translateExercise(name, context);
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() {
      _running = true;
      if (_gifUrl == null && _imageUrl == null && _videoUrl == null) {
        _loadMediaForCurrent();
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) {
        if (_workPhase) {
          // Завершили упражнение - автоматически начинаем отдых
          setState(() {
            _workPhase = false;
            _total = _restTime;
            _seconds = _restTime;
          });
        } else {
          // Завершили отдых - переходим к следующему упражнению
          _currentIdx++;
          if (_currentIdx >= _plan.length) {
            // Все упражнения завершены
            _timer?.cancel();
            setState(() => _running = false);
            _completeWorkout();
          } else {
            // Переходим к следующему упражнению
            setState(() {
              _workPhase = true;
              _total = _workTime;
              _seconds = _workTime;
            });
            _loadMediaForCurrent();
          }
        }
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _workPhase = true;
      _total = _workTime;
      _seconds = _workTime;
      _currentIdx = 0;
      _gifUrl = _imageUrl = _videoUrl = null;
    });
    _loadMediaForCurrent();
  }

  @override
  Widget build(BuildContext context) {
    final phaseLabel = _workPhase ? 'Работа' : 'Отдых';

    return GradientScaffold( // <- гарантируем брендинг‑фон
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Тренировка'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              // стеклянная карточка под медиа
              Container(
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
              const SizedBox(height: 14),

              // подпись упражнения (кликабельная для деталей)
              GestureDetector(
                onTap: () => _showExerciseDetails(),
                child: AnimatedOpacity(
                  opacity: (_gifUrl != null || _imageUrl != null || _videoUrl != null) ? 1 : 0.6,
                  duration: const Duration(milliseconds: 250),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _getLocalizedName(_plan[_currentIdx]),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline, size: 16, color: kContentMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // таймер
              Expanded(
                child: Center(
                  child: _RectangularTimer(
                    seconds: _seconds,
                    total: _total,
                    label: phaseLabel,
                  ),
                ),
              ),

              // кнопки
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
                      child: Text(_running ? 'Пауза' : 'Старт'),
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
                      child: const Text('Сброс'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Check Form Button - NoirSecondaryButton style
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openFormCheck,
                  icon: const Icon(Icons.videocam_rounded, size: 18),
                  label: Text(AppLocalizations.of(context)?.checkForm ?? 'Check Form'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kContentHigh,
                    side: BorderSide(color: kBorderLight),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
    
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(kSpaceLG),
            decoration: BoxDecoration(
              color: kNoirGraphite.withOpacity(0.95),
              borderRadius: BorderRadius.circular(kRadiusXL),
              border: Border.all(color: kNoirSteel.withOpacity(0.5)),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Заголовок
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kContentHigh.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_rounded, color: kContentHigh, size: 24),
                      ),
                      const SizedBox(width: kSpaceMD),
                      Expanded(
                        child: Text(
                          l10n.workoutSettingsTitle,
                          style: kNoirTitleMedium.copyWith(color: kContentHigh, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpaceMD),
                  Text(
                    l10n.workoutSettingsSubtitle,
                    style: kNoirBodyMedium.copyWith(color: kContentMedium),
                  ),
                  const SizedBox(height: kSpaceLG),
                  
                  // Время упражнения
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.exerciseLabel, style: kNoirBodyMedium.copyWith(color: kContentHigh)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_workTime > 10) {
                                setState(() => _workTime -= 5);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline, color: kContentHigh),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '$_workTime ${l10n.seconds}',
                              style: kNoirTitleMedium.copyWith(color: kContentHigh, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_workTime < 300) {
                                setState(() => _workTime += 5);
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline, color: kContentHigh),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: kSpaceMD),
                  
                  // Время отдыха
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.restLabel, style: kNoirBodyMedium.copyWith(color: kContentHigh)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_restTime > 5) {
                                setState(() => _restTime -= 5);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline, color: kContentHigh),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '$_restTime ${l10n.seconds}',
                              style: kNoirTitleMedium.copyWith(color: kContentHigh, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_restTime < 180) {
                                setState(() => _restTime += 5);
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline, color: kContentHigh),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: kSpaceLG),
                  
                  // Кнопки
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: kContentMedium,
                            padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: kSpaceMD),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'workTime': _workTime,
                              'restTime': _restTime,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kContentHigh,
                            foregroundColor: kNoirBlack,
                            padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadiusMD),
                            ),
                          ),
                          child: Text(l10n.start, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Прямоугольный строгий таймер
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
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Лейбл
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Время
          Text(
            '$mm:$ss',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.w900,
              letterSpacing: -3,
              height: 1,
            ),
          ),
          const SizedBox(height: 24),
          
          // Прогресс бар
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
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
}

// Noir Glass Dialog для workout_screen
class _NoirGlassDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final String confirmText;
  final VoidCallback onConfirm;
  final String? cancelText;
  final VoidCallback? onCancel;

  const _NoirGlassDialog({
    required this.title,
    required this.content,
    required this.icon,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(kSpaceLG),
            decoration: BoxDecoration(
              color: kNoirGraphite.withOpacity(0.95),
              borderRadius: BorderRadius.circular(kRadiusXL),
              border: Border.all(color: kNoirSteel.withOpacity(0.5)),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kContentHigh.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: kContentHigh, size: 32),
                  ),
                  const SizedBox(height: kSpaceMD),
                  Text(
                    title,
                    style: kNoirTitleMedium.copyWith(
                      color: kContentHigh,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpaceSM),
                  Text(
                    content,
                    style: kNoirBodyMedium.copyWith(color: kContentMedium),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpaceLG),
                  Row(
                    children: [
                      if (cancelText != null) ...[
                        Expanded(
                          child: TextButton(
                            onPressed: onCancel ?? () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: kContentMedium,
                              padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                            ),
                            child: Text(cancelText!),
                          ),
                        ),
                        const SizedBox(width: kSpaceMD),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kContentHigh,
                            foregroundColor: kNoirBlack,
                            padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadiusMD),
                            ),
                          ),
                          child: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Exercise Detail Sheet — Shows GIF and instructions
// =============================================================================

class _ExerciseDetailSheet extends StatelessWidget {
  const _ExerciseDetailSheet({
    required this.exerciseName,
    required this.originalName,
    required this.gifUrl,
    required this.imageUrl,
    required this.targetMuscle,
    required this.equipment,
    required this.instructions,
    required this.l10n,
  });
  
  final String exerciseName;
  final String originalName;
  final String? gifUrl;
  final String? imageUrl;
  final String targetMuscle;
  final String equipment;
  final List<String> instructions;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: kNoirCarbon.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
              border: Border.all(color: kNoirSteel.withOpacity(0.3)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(kSpaceLG),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kContentLow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: kSpaceLG),
                
                // Exercise name
                Text(
                  exerciseName,
                  style: kNoirTitleLarge.copyWith(
                    color: kContentHigh,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpaceMD),
                
                // GIF/Image preview
                if (gifUrl != null || imageUrl != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kNoirGraphite,
                      borderRadius: BorderRadius.circular(kRadiusMD),
                      border: Border.all(color: kBorderLight),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      gifUrl ?? imageUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation(kContentMedium),
                          ),
                        );
                      },
                      errorBuilder: (ctx, error, stack) => Center(
                        child: Icon(Icons.fitness_center, color: kContentLow, size: 48),
                      ),
                    ),
                  ),
                
                const SizedBox(height: kSpaceLG),
                
                // Target muscle and equipment
                Row(
                  children: [
                    if (targetMuscle.isNotEmpty) ...[
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.adjust,
                          label: l10n.targetMuscle,
                          value: TranslationService.translateMuscle(targetMuscle, context),
                        ),
                      ),
                      const SizedBox(width: kSpaceMD),
                    ],
                    if (equipment.isNotEmpty)
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.fitness_center,
                          label: l10n.equipment,
                          value: _translateEquipment(equipment),
                        ),
                      ),
                  ],
                ),
                
                // Instructions
                if (instructions.isNotEmpty) ...[
                  const SizedBox(height: kSpaceLG),
                  Text(
                    l10n.instructions,
                    style: kNoirTitleMedium.copyWith(color: kContentHigh),
                  ),
                  const SizedBox(height: kSpaceSM),
                  ...instructions.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: kSpaceSM),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: kContentHigh.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: kNoirBodySmall.copyWith(
                                color: kContentHigh,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: kSpaceSM),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: kNoirBodyMedium.copyWith(color: kContentMedium),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                // Bottom padding for safe area
                SizedBox(height: MediaQuery.of(context).padding.bottom + kSpaceLG),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _translateEquipment(String equipment) {
    const translations = {
      'barbell': 'Штанга',
      'dumbbell': 'Гантели',
      'cable': 'Тросы',
      'machine': 'Тренажёр',
      'body weight': 'Собственный вес',
      'bodyweight': 'Собственный вес',
      'kettlebell': 'Гиря',
      'band': 'Резинка',
      'medicine ball': 'Медбол',
      'stability ball': 'Фитбол',
      'ez barbell': 'EZ-штанга',
      'smith machine': 'Смит',
      'assisted': 'С помощью',
      'leverage machine': 'Рычажный тренажёр',
      'sled machine': 'Сани',
      'roller': 'Ролик',
      'rope': 'Канат',
      'weighted': 'С отягощением',
      'olympic barbell': 'Олимпийская штанга',
      'trap bar': 'Трэп-гриф',
      'tire': 'Покрышка',
      'suspension': 'Петли TRX',
      'bosu ball': 'Bosu',
      'wheel roller': 'Ролик для пресса',
      'upper body ergometer': 'Эргометр',
      'elliptical machine': 'Эллипсоид',
      'stationary bike': 'Велотренажёр',
      'skierg machine': 'Лыжный тренажёр',
    };
    return translations[equipment.toLowerCase()] ?? equipment;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kSpaceSM),
      decoration: BoxDecoration(
        color: kNoirGraphite.withOpacity(0.5),
        borderRadius: BorderRadius.circular(kRadiusSM),
        border: Border.all(color: kBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: kContentMedium),
              const SizedBox(width: 4),
              Text(
                label,
                style: kNoirBodySmall.copyWith(color: kContentMedium),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: kNoirBodyMedium.copyWith(
              color: kContentHigh,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
