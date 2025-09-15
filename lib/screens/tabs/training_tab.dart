import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/modern_components.dart';
import '../../core/apple_components.dart';
import '../../core/sexy_components.dart';
import '../../l10n/app_localizations.dart';
import '../../state/plan_state.dart';
import '../workout_screen.dart';
import '../modern_workout_screen.dart';

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
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.training)),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          child: Column(
            children: [
              if (days.isEmpty) ...[
                AppleComponents.premiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppleComponents.premiumText(
                        'Создай персональную программу на 28 дней',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      AppleComponents.premiumText(
                        'Мы учитываем цель, параметры тела и активность.',
                        textAlign: TextAlign.center,
                        delay: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppleComponents.premiumButton(
                        onPressed: () async {
                          await ref.read(planProvider.notifier).generateProgram();
                          setState(() {});
                          // Сразу переходим на красивый экран тренировки
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ModernWorkoutScreen()),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.createProgram),
                      ).withAppleFadeIn(delay: const Duration(milliseconds: 400)),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    // Левая стрелка без круга
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _pageCtrl.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.chevron_left_rounded, 
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Центральная карточка с днем
                    Expanded(
                      child: AppleComponents.premiumCard(
                        child: Center(
                          child: AppleComponents.premiumText(
                            'День ${_index + 1} / ${days.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Правая стрелка без круга
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _pageCtrl.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.chevron_right_rounded, 
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
                        child: AppleComponents.premiumCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: AppleComponents.premiumText(
                                  'План на день ${i + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: AppleComponents.premiumText(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      height: 1.5, 
                                      color: Colors.white,
                                    ),
                                    delay: const Duration(milliseconds: 200),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (isToday)
                                SexyComponents.sexyButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const ModernWorkoutScreen()),
                                    );
                                  },
                                  child: Text(AppLocalizations.of(context)!.startWorkout),
                                ).withSexyFadeIn(delay: const Duration(milliseconds: 300))
                              else
                                AppleComponents.premiumButton(
                                  onPressed: null,
                                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                                  child: Text(
                                    'Старт будет доступен в день тренировки',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ).withAppleFadeIn(delay: const Duration(milliseconds: 300)),
                            ],
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
