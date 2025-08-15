import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../state/app_providers.dart';
import 'video_coach_screen.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  bool work = true;
  int sec = 30;
  int rest = 15;
  int round = 1;
  int rounds = 12;
  Timer? t;
  bool running = false;

  void _toggle() {
    if (running) {
      t?.cancel();
      setState(() => running = false);
      return;
    }
    running = true;
    t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (sec > 0) {
        setState(() => sec--);
        return;
      }
      if (work) {
        work = false;
        sec = rest;
      } else {
        work = true;
        round++;
        sec = 30;
        if (round > rounds) {
          t?.cancel();
          running = false;
          _finish();
        }
      }
      setState(() {});
    });
  }

  void _finish() async {
    await ref.read(planProvider.notifier).markWorkoutDone();
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (_) =>
            const AlertDialog(title: Text('Готово!'), content: Text('Сессия завершена')));
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Сессия')),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Text(
                work ? 'РАБОТА' : 'ОТДЫХ',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(
                        fontWeight: FontWeight.w900,
                        color: work ? scheme.primary : Colors.tealAccent),
              ),
              const SizedBox(height: 8),
              Text('Раунд $round / $rounds',
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(_fmt(sec),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/gifs/squat.gif',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            alignment: Alignment.center,
                            color: Colors.white.withOpacity(0.08),
                            child: const Icon(Icons.fitness_center,
                                color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Присед со штангой',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      'Подсказка: корпус стабилен, колени по траектории носков.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () async {
                        if (!mounted) return;
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const VideoCoachScreen()));
                      },
                      child: const Icon(Icons.videocam_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: FilledButton.tonal(
                          onPressed: () {
                            setState(() => {
                                  work = true,
                                  sec = 30,
                                  round = 1,
                                  running = false
                                });
                            t?.cancel();
                          },
                          child: const Text('Сброс'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: FilledButton(
                          onPressed: _toggle,
                          child: Text(running ? 'Пауза' : 'Старт'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(int s) {
    final m = s ~/ 60, r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }
}

// Removed ring timer widget since a simple numeric timer is used.

