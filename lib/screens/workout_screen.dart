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
                  child: _Ring(
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

class _Ring extends StatelessWidget {
  final int seconds;
  final int total;
  final String label;
  const _Ring({required this.seconds, required this.total, required this.label});

  @override
  Widget build(BuildContext context) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    final progress = seconds / total.clamp(1, 600);

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size.square(260), painter: _RingPainter(progress)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$mm:$ss',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, letterSpacing: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 1.0..0.0
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rOuter = size.width / 2;
    final rInner = rOuter - 18;

    final bg = Paint()..color = const Color(0xFF2B2E38);
    final fgColor = const Color(0xFFB7A6FF);

    final rectOuter = Rect.fromCircle(center: center, radius: rOuter);
    final rectInner = Rect.fromCircle(center: center, radius: rInner);

    final sweep = 3.14159 * progress;
    final pathBottom = Path()
      ..addArc(rectOuter, 0.0, sweep)
      ..arcTo(rectInner, sweep, -sweep, false)
      ..close();
    final fgFront = Paint()..color = fgColor.withOpacity(0.70);
    canvas.drawPath(pathBottom, fgFront);

    canvas.drawCircle(center, rInner, bg);

    final sweepTop = 3.14159 * progress;
    final pathTop = Path()
      ..addArc(rectOuter, -3.14159, sweepTop)
      ..arcTo(rectInner, -3.14159 + sweepTop, -sweepTop, false)
      ..close();
    final fgBack = Paint()..color = fgColor.withOpacity(0.25);

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawPath(pathTop, fgBack);
    final eraser = Paint()..blendMode = BlendMode.clear;
    canvas.drawCircle(center, rInner, eraser);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
