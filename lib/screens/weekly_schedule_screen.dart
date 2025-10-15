import 'package:flutter/material.dart';
import '../core/design_tokens.dart';
import '../core/premium_components.dart';

class WeeklyScheduleScreen extends StatelessWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = const [
      'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'
    ];
    final plan = <String, List<String>>{
      'Понедельник': ['Жим штанги лёжа', 'Разводка гантелей', 'Отжимания'],
      'Вторник': ['Приседания со штангой', 'Румынская тяга', 'Выпады'],
      'Среда': ['Армейский жим', 'Махи в стороны', 'Французский жим'],
      'Четверг': ['Подтягивания', 'Тяга штанги в наклоне', 'Тяга верхнего блока'],
      'Пятница': ['Становая тяга', 'Тяга штанги', 'Тяга каната к лицу'],
      'Суббота': ['Отжимания на брусьях', 'Жим гантелей', 'Махи в стороны'],
      'Воскресенье': ['Отдых'],
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Расписание недели')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: days.length,
        itemBuilder: (ctx, i) {
          final d = days[i];
          final ex = plan[d] ?? [];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: PremiumComponents.glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d, style: DesignTokens.h3),
                  const SizedBox(height: 8),
                  if (ex.isEmpty) Text('Нет запланированных тренировок', style: DesignTokens.bodySmall)
                  else ...ex.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: DesignTokens.success),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e, style: DesignTokens.bodyMedium)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
