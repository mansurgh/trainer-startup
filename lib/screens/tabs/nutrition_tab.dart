import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../../state/meal_schedule_state.dart';
import '../../state/fridge_state.dart';
import '../meal_schedule_screen.dart';
import '../chat_screen.dart';

class NutritionTab extends ConsumerStatefulWidget {
  const NutritionTab({super.key});
  @override
  ConsumerState<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends ConsumerState<NutritionTab> {
  Future<void> _chooseFridgePhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    ref.read(fridgeProvider.notifier).setImage(img.path);
    if (!mounted) return;
    _analyzeFridge();
  }

  void _analyzeFridge() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111217),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(builder: (ctx, setSheet) {
        // локальные списки — будем уменьшать
        var recipes = <MealItem>[
          MealItem(name: 'Омлет с овощами', grams: 250, kcal: 320),
          MealItem(name: 'Курица с рисом', grams: 400, kcal: 520),
          MealItem(name: 'Творог с ягодами', grams: 220, kcal: 240),
        ];
        var suggested = <String>['Оливковое масло', 'Овсянка', 'Йогурт греческий'];

        void addToPlan(MealItem r) {
          final meals = ref.read(mealScheduleProvider);
          int target = meals.indexWhere((m) => m.name.toLowerCase().contains('обед'));
          if (target < 0) target = 0;
          ref.read(mealScheduleProvider.notifier).addItem(target, r);
          setSheet(() => recipes = recipes.where((e) => e != r).toList());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Добавлено в "${meals[target].name}"')),
          );
        }

        void markSuggested(String p) {
          setSheet(() => suggested = suggested.where((e) => e != p).toList());
        }

        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: ListView(
                controller: controller,
                children: [
                  const Center(child: SizedBox(width: 40, child: Divider(thickness: 3))),
                  const SizedBox(height: 8),
                  const Text('Рецепты по фото холодильника', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  ...recipes.map((r) => ListTile(
                        dense: true,
                        title: Text('${r.name} • ${r.grams} г • ${r.kcal} ккал'),
                        trailing: FilledButton.tonal(
                          onPressed: () => addToPlan(r),
                          child: const Text('В рацион'),
                        ),
                      )),
                  if (recipes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Все добавлено ✔', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                    ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Предложенные продукты', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggested
                        .map((p) => InputChip(
                              label: Text(p),
                              selected: false,
                              onPressed: () => markSuggested(p),
                              deleteIcon: const Icon(Icons.check_rounded),
                              onDeleted: () => markSuggested(p),
                              backgroundColor: Colors.white.withValues(alpha: 0.06),
                            ))
                        .toList(),
                  ),
                  if (suggested.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Отлично! Всё учтено.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                    ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Партнёрский магазин (заглушка)'))),
                    child: const Text('Купить выбранное'),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealScheduleProvider);
    final fridge = ref.watch(fridgeProvider);

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Питание')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // чат
            Card(
              color: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: const Icon(Icons.chat_bubble_outline_rounded),
                title: const Text('Чат с тренером'),
                subtitle: const Text('КБЖУ по фото, контроль питания, вопросы'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen())),
              ),
            ),
            const SizedBox(height: 12),

            // краткий план на сегодня
            Card(
              color: Colors.white.withValues(alpha: 0.04),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Рацион на сегодня', style: TextStyle(fontWeight: FontWeight.w800)),
                        const Spacer(),
                        FilledButton.tonal(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MealScheduleScreen())),
                          child: const Text('Полный рацион'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...meals.take(3).map((m) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '• ${m.name}: ${m.items.map((e) => e.name).take(2).join(', ')}'
                            '${m.items.length > 2 ? '…' : ''}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // информационный блок
            Card(
              color: Colors.white.withValues(alpha: 0.04),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Фото холодильника — рацион, рецепты и советы.\n'
                  'План на сегодня — редактируй вручную или генерируй по фото.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Фото холодильника: до/после
            fridge.imagePath == null
                ? FilledButton(
                    onPressed: _chooseFridgePhoto,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.image_search_rounded), SizedBox(width: 8), Text('Фото холодильника')],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _analyzeFridge,
                          child: const Text('Анализ текущей фотки'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _chooseFridgePhoto,
                          child: const Text('Изменить фото'),
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
