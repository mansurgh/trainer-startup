import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../state/exercisedb_providers.dart';
import 'video_coach_screen.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});
  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  Timer? _timer;
  int _seconds = 60;
  int _total = 60;
  bool _running = false;
  bool _workPhase = true;

  final List<String> _plan = const [
    'barbell squat',
    'push up',
    'barbell bench press',
    'seated cable row',
  ];
  int _currentIdx = 0;

  String? _exerciseImageUrl;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadImageForCurrent() async {
    final name = _plan[_currentIdx];
    try {
      final url = await ref.read(exerciseImageByNameProvider(name).future);
      if (!mounted) return;
      setState(() => _exerciseImageUrl = url);
    } catch (_) {
      if (!mounted) return;
      setState(() => _exerciseImageUrl = null);
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
      // при первом старте подгружаем медиа
      if (_exerciseImageUrl == null) _loadImageForCurrent();
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
            _loadImageForCurrent();
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
      _exerciseImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phaseLabel = _workPhase ? 'Работа' : 'Отдых';

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Тренировка')),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              SizedBox(
                height: 230,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _exerciseImageUrl == null
                      ? Image.asset('assets/gifs/motivation/m1.gif', fit: BoxFit.cover)
                      : Image.network(
                          _exerciseImageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (c, w, p) {
                            if (p == null) return w;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (c, e, st) => const Center(child: Text('Медиа недоступно')),
                        ),
                ),
              ),
              const SizedBox(height: 8),

              // название упражнения (появляется только после старта)
              if (_exerciseImageUrl != null)
                Text(_plan[_currentIdx], style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              Expanded(
                child: Center(
                  child: _Ring(
                    seconds: _seconds,
                    total: _total,
                    label: phaseLabel,
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _toggle,
                      child: Text(_running ? 'Пауза' : 'Старт'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _reset,
                      child: const Text('Сброс'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VideoCoachScreen()),
                ),
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('Корректировка техники'),
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
              Text('$mm:$ss', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white70)),
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

    // Нижняя дуга — «перед» диском — рисуем частично по progress
    final sweep = 3.14159 * progress; // 0..π
    final pathBottom = Path()
      ..addArc(rectOuter, 0.0, sweep)
      ..arcTo(rectInner, sweep, -sweep, false)
      ..close();
    final fgFront = Paint()..color = fgColor.withOpacity(0.70);
    canvas.drawPath(pathBottom, fgFront);

    // Диск
    canvas.drawCircle(center, rInner, bg);

    // Верхняя дуга — «за» диском — оставшаяся часть
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
