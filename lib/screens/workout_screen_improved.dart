// lib/screens/workout_screen_improved.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../state/exercisedb_providers.dart';
import '../widgets/workout_media.dart';

class WorkoutScreenImproved extends ConsumerStatefulWidget {
  final String? selectedExercise;
  final List<String>? dayPlan;
  const WorkoutScreenImproved({super.key, this.selectedExercise, this.dayPlan});
  
  @override
  ConsumerState<WorkoutScreenImproved> createState() => _WorkoutScreenImprovedState();
}

class _WorkoutScreenImprovedState extends ConsumerState<WorkoutScreenImproved> {
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        _timer?.cancel();
        setState(() {
          _running = false;
          _workPhase = !_workPhase;
          _seconds = _workPhase ? 60 : 30;
          _total = _seconds;
        });
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _workPhase = true;
      _seconds = 60;
      _total = 60;
    });
  }

  void _goToPrevious() {
    if (_currentIdx > 0) {
      _timer?.cancel();
      setState(() {
        _currentIdx--;
        _running = false;
        _seconds = 60;
        _total = 60;
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
        _seconds = 60;
        _total = 60;
      });
      _loadMediaForCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phaseLabel = _workPhase ? 'Work' : 'Rest';

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Exercise ${_currentIdx + 1}/${_plan.length}'),
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
                      _plan[_currentIdx],
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
                      child: Text(_running ? 'Pause' : 'Start'),
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
                      child: const Text('Reset'),
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
