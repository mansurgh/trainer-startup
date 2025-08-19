import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/plan_state.dart';
import '../workout_screen.dart';

class TrainingTab extends ConsumerStatefulWidget {
  const TrainingTab({super.key});
  @override
  ConsumerState<TrainingTab> createState() => _TrainingTabState();
}

class _TrainingTabState extends ConsumerState<TrainingTab> {
  final _pageCtrl = PageController(viewportFraction: 0.86);
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(planProvider);
    final days = plan?.programDays ?? const <String>[];
    final todayIdx = plan?.todayIndex ?? 0;

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Тренировки')),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          child: Column(
            children: [
              if (days.isEmpty) ...[
                Card(
                  color: Colors.white.withValues(alpha: 0.04),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Создай персональную программу на 28 дней',
                            style: TextStyle(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        const Text('Мы учитываем цель, параметры тела и активность.',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () async {
                            await ref.read(planProvider.notifier).generateProgram();
                            setState(() {});
                          },
                          child: const Text('Создать программу'),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      icon: const Icon(Icons.chevron_left_rounded, size: 32),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'День ${_index + 1} / ${days.length}',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      icon: const Icon(Icons.chevron_right_rounded, size: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: days.length,
                    itemBuilder: (_, i) {
                      final isToday = i == todayIdx;
                      final text = days[i];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Card(
                          color: Colors.white.withValues(alpha: 0.04),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Text(
                                    'План на день ${i + 1}',
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(text,
                                        style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (isToday)
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                                      );
                                    },
                                    child: const Text('Начать тренировку'),
                                  )
                                else
                                  const Center(
                                    child: Text(
                                      'Старт будет доступен в день тренировки',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
