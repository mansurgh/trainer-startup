// lib/screens/workout_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/exercisedb_providers.dart';
import '../widgets/workout_media.dart';

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

  String? _gifUrl;
  String? _imageUrl;
  String? _videoUrl;

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
      final chosen = _gifUrl ?? _imageUrl ?? _videoUrl ?? 'NO MEDIA';
      // ignore: avoid_print
      print('[Workout] media "$name" -> $chosen');
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

    return Scaffold(
      appBar: AppBar(title: const Text('Тренировка')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: WorkoutMedia(
                gifUrl: _gifUrl,
                imageUrl: _imageUrl,
                videoUrl: _videoUrl,
              ),
            ),
            const SizedBox(height: 8),

            if (_gifUrl != null || _imageUrl != null || _videoUrl != null)
              Text(_plan[_currentIdx], style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            Expanded(
              child: Center(
                child: Text(
                  '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.headlineMedium,
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
          ],
        ),
      ),
    );
  }
}
