import 'package:flutter/material.dart';

class MealScheduleScreen extends StatefulWidget {
  const MealScheduleScreen({super.key});
  @override
  State<MealScheduleScreen> createState() => _MealScheduleScreenState();
}

class _MealScheduleScreenState extends State<MealScheduleScreen> {
  final List<String> meals = ['Завтрак', 'Обед', 'Ужин'];
  final Map<String, List<String>> plan = {
    'Завтрак': [],
    'Обед': [],
    'Ужин': [],
  };

  // предложенные позиции
  final List<String> suggested = [
    'Овсянка', 'Яйца', 'Курица с рисом', 'Творог', 'Салат'
  ];
  final Set<String> chosen = {};

  void _addChosenTo(String meal) {
    setState(() {
      plan[meal]!.addAll(chosen);
      // удалить из предложенных после добавления
      suggested.removeWhere((e) => chosen.contains(e));
      chosen.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание питания'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Секция предложенных
          if (suggested.isNotEmpty) ...[
            const Text('Предложенные продукты', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggested.map((name) {
                final selected = chosen.contains(name);
                return FilterChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        chosen.remove(name);
                      } else {
                        chosen.add(name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          for (final meal in meals) _mealCard(meal),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FilledButton(
          onPressed: chosen.isEmpty ? null : () => _addChosenTo('Обед'), // пример: добавляем в «Обед»; подстрой под свою логику
          child: const Text('Добавить выбранные в рацион'),
        ),
      ),
    );
  }

  Widget _mealCard(String meal) {
    final items = plan[meal]!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(meal, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                const Icon(Icons.drag_indicator_rounded, color: Colors.white24), // если используешь Reorderable, оставь
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('Пусто', style: TextStyle(color: Colors.white60))
            else
              Column(
                children: items
                    .map((e) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(e),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
