import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../state/app_providers.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});
  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  bool work = true; int sec = 30; int rest = 15; int round = 1; int rounds = 12;
  Timer? t; bool running = false;

  void _toggle() {
    if (running) { t?.cancel(); setState(()=>running=false); return; }
    running = true;
    t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (sec>0) { setState(()=>sec--); return; }
      if (work) { work=false; sec=rest; } else { work=true; round++; sec=30; if (round>rounds){ t?.cancel(); running=false; _finish(); } }
      setState((){});
    });
  }

  void _finish() async {
    await ref.read(planProvider.notifier).markWorkoutDone();
    if (!mounted) return;
    showDialog(context: context, builder: (_) => const AlertDialog(title: Text('Готово!'), content: Text('Сессия завершена')));
  }

  @override
  void dispose() { t?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final total = work ? 30.0 : 15.0; final progress = 1 - (sec/total);
    final scheme = Theme.of(context).colorScheme;
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Сессия')),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(children: [
            Text(work ? 'РАБОТА' : 'ОТДЫХ', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w900, color: work ? scheme.primary : Colors.tealAccent)),
            const SizedBox(height: 8),
            Text('Раунд $round / $rounds', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            Expanded(child: Center(child: _Ring(progress: progress, label: _fmt(sec)))),
            Row(children: [
              Expanded(child: FilledButton.tonal(onPressed: (){ setState(()=>{ work=true, sec=30, round=1, running=false }); t?.cancel(); }, child: const Text('Сброс'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: _toggle, child: Text(running ? 'Пауза' : 'Старт'))),
            ]),
          ]),
        ),
      ),
    );
  }

  String _fmt(int s){ final m=s~/60, r=s%60; return '${m.toString().padLeft(2,'0')}:${r.toString().padLeft(2,'0')}'; }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.progress, required this.label});
  final double progress; final String label;
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(height: 260, width: 260, child: CustomPaint(painter: _RingPainter(progress))),
      Container(
        height: 210, width: 210,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04), border: Border.all(color: Colors.white24)),
        child: Center(child: Text(label, style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w900))),
      ),
    ]);
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value); final double value;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final start = -90 * 3.1415926535 / 180; final sweep = 6.28318 * value;
    final bg = Paint()..style=PaintingStyle.stroke..strokeWidth=16..color=const Color(0x22FFFFFF)..strokeCap=StrokeCap.round;
    final fg = Paint()..style=PaintingStyle.stroke..strokeWidth=16..shader=const SweepGradient(colors:[Color(0xFF7C3AED),Color(0xFF22D3EE),Color(0xFF7C3AED)],stops:[0,0.6,1]).createShader(rect)..strokeCap=StrokeCap.round;
    canvas.drawArc(rect.deflate(8), 0, 6.28318, false, bg);
    canvas.drawArc(rect.deflate(8), start, sweep, false, fg);
  }
  @override
  bool shouldRepaint(covariant _RingPainter old)=>old.value!=value;
}