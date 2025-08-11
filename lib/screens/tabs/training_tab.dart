import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/app_providers.dart';
import '../workout_screen.dart';

class TrainingTab extends ConsumerWidget {
  const TrainingTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planProvider);
    final program = ref.watch(programProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Твоя программа', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w900)),
          if (plan != null && plan.workoutDone)
            const Chip(label: Text('Сегодня выполнено')),
        ]),
        const SizedBox(height: 12),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('28 дней под твою цель', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: PrimaryButton(label: 'Сгенерировать', icon: Icons.auto_awesome_rounded, onPressed: () async {
              final user = ref.read(userProvider);
              if (user == null) return;
              final ai = ref.read(aiServiceProvider);
              final resp = await ai.generateProgram(user);
              final lines = resp.advice.split('\n');
              ref.read(programProvider.notifier).state = lines;
            })),
            const SizedBox(width: 12),
            Expanded(child: PrimaryButton(label: 'Старт сессии', icon: Icons.play_arrow_rounded, onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkoutScreen()));
            })),
          ]),
        ])),
        const SizedBox(height: 12),
        if (program.isNotEmpty)
          GlassCard(child: SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: program.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _DayCard(day: i + 1, text: program[i]),
            ),
          )),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.text});
  final int day; final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('День $day', style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
      ]),
    );
  }
}