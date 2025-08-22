import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../state/meal_schedule_state.dart';

class MealScheduleScreen extends ConsumerWidget {
  const MealScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealScheduleProvider);
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Полный рацион'),
          actions: [
            IconButton(
              onPressed: () {
                ref.read(mealScheduleProvider.notifier).addMeal('Новый блок');
              },
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Добавить блок',
            ),
          ],
        ),
        body: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: meals.length,
          buildDefaultDragHandles: false, // перетаскиваем за любую область карточки
          itemBuilder: (context, index) {
            final block = meals[index];
            return ReorderableDragStartListener(
              key: ValueKey('meal-$index'),
              index: index,
              child: _MealBlockCard(index: index),
            );
          },
          onReorder: (oldIndex, newIndex) {
            ref.read(mealScheduleProvider.notifier).reorderMeals(oldIndex, newIndex);
          },
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent,
              child: Transform.scale(scale: 1.02, child: child),
            );
          },
        ),
      ),
    );
  }
}

class _MealBlockCard extends ConsumerWidget {
  final int index;
  const _MealBlockCard({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealScheduleProvider);
    final block = meals[index];
    final notifier = ref.read(mealScheduleProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: block.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: 'Название блока'),
                  onChanged: (v) => notifier.renameMeal(index, v),
                ),
              ),
              IconButton(
                onPressed: () => notifier.removeMeal(index),
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Удалить блок',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: IntrinsicColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(children: [
                _Hdr('Блюдо'), _Hdr('Грамм'), _Hdr('Ккал'), SizedBox.shrink(),
              ]),
              ...List.generate(block.items.length, (i) {
                final d = block.items[i];
                final nameCtrl = TextEditingController(text: d.name);
                final gramsCtrl = TextEditingController(text: d.grams.toString());
                final kcalCtrl  = TextEditingController(text: d.kcal.toString());
                return TableRow(children: [
                  _Txt(controller: nameCtrl, onChanged: (v) {
                    notifier.editItem(index, i, MealItem(name: v, grams: d.grams, kcal: d.kcal));
                  }),
                  _Num(controller: gramsCtrl, onChanged: (v) {
                    final g = int.tryParse(v) ?? d.grams;
                    notifier.editItem(index, i, MealItem(name: d.name, grams: g, kcal: d.kcal));
                  }),
                  _Num(controller: kcalCtrl, onChanged: (v) {
                    final k = int.tryParse(v) ?? d.kcal;
                    notifier.editItem(index, i, MealItem(name: d.name, grams: d.grams, kcal: k));
                  }),
                  IconButton(
                    onPressed: () => notifier.deleteItem(index, i),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Удалить блюдо',
                  ),
                ]);
              }),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: () => notifier.addItem(index, MealItem(name: 'Новое блюдо', grams: 100, kcal: 120)),
                child: const Text('Добавить блюдо'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hdr extends StatelessWidget {
  final String t; const _Hdr(this.t);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white70)),
  );
}

class _Txt extends StatelessWidget {
  final TextEditingController controller; final ValueChanged<String> onChanged;
  const _Txt({required this.controller, required this.onChanged});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
    child: TextField(controller: controller, decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: '—'), onChanged: onChanged),
  );
}

class _Num extends StatelessWidget {
  final TextEditingController controller; final ValueChanged<String> onChanged;
  const _Num({required this.controller, required this.onChanged});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
    child: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: '0'), onChanged: onChanged),
  );
}
