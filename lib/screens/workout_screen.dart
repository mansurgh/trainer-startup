// lib/screens/workout_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart'; // GradientScaffold
import '../state/exercisedb_providers.dart';
import '../widgets/workout_media.dart';

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
    _loadMediaForCurrent();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadMediaForCurrent() async {
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
      print('[Workout] media "$name" -> $safeShown');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _gifUrl = _imageUrl = _videoUrl = null;
      });
      // ignore: avoid_print
      print('[Workout] media load error for "$name": $e');
    }
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
        setState(() {
          _workPhase = !_workPhase;
          _total = _workPhase ? 60 : 30;
          _seconds = _total;
          if (_workPhase) {
            _currentIdx = (_currentIdx + 1) % _plan.length;
            _loadMediaForCurrent();
          }
        });
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
      _total = 60;
      _seconds = 60;
      _currentIdx = 0;
      _gifUrl = _imageUrl = _videoUrl = null;
    });
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

              // подпись упражнения
              AnimatedOpacity(
                opacity: (_gifUrl != null || _imageUrl != null || _videoUrl != null) ? 1 : 0.6,
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _plan[_currentIdx],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
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
            ],
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
