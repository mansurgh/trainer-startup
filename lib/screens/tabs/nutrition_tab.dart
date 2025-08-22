import 'dart:io';
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
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
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

        // выбранные (галочки) для FilterChip — стартуем со всех включенных
        var selectedProducts = suggested.toSet();

        void addToPlan(MealItem r) {
          final meals = ref.read(mealScheduleProvider);
          int target = meals.indexWhere((m) => m.name.toLowerCase().contains('обед'));
          if (target < 0) target = 0;
          ref.read(mealScheduleProvider.notifier).addItem(target, r);
          // удаляем из предложений НАДЁЖНО — по имени, а не по ссылке на объект
          setSheet(() => recipes.removeWhere((e) => e.name == r.name));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Добавлено в "${meals[target].name}"')),
          );
        }

        void markSuggested(String p) {
          // если нужно именно убрать из списка целиком:
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${r.grams} г • ${r.kcal} ккал', style: const TextStyle(color: Colors.white70)),
                        trailing: FilledButton.tonal(onPressed: () => addToPlan(r), child: const Text('В рацион')),
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
                    children: suggested.map((p) {
                      final selected = selectedProducts.contains(p);
                      return FilterChip(
                        label: Text(p),
                        selected: selected,
                        onSelected: (val) {
                          setSheet(() {
                            if (val) {
                              selectedProducts.add(p);
                            } else {
                              selectedProducts.remove(p);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (suggested.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Отлично! Всё учтено.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                    ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Партнёрский магазин — скоро ✨'))),
                    child: const Text('Купить всё выбранное'),
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

            // краткий план на сегодня — ТАЙМЛАЙН
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
                    ...meals.take(3).map((m) {
                      final items = m.items.map((e) => e.name).join(', ');
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 6),
                              Container(width: 14, height: 14, decoration: const BoxDecoration(color: Color(0xFFB7A6FF), shape: BoxShape.circle)),
                              Container(width: 2, height: 48, color: Colors.white.withValues(alpha: 0.18)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text(items.isEmpty ? '—' : items, style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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
                child: Text('Загружай фото холодильника — подскажем, что докупить и что приготовить.'),
              ),
            ),
            const SizedBox(height: 12),

            // фото холодильника
            if (fridge.imagePath == null)
              OutlinedButton.icon(
                onPressed: _chooseFridgePhoto,
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Загрузить фото холодильника'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        // ignore: use_build_context_synchronously
                        // (мы уже проверяем mounted выше)
                        File(fridge.imagePath!),
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: _analyzeFridge,
                          child: const Text('Предложить рецепты'),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: _chooseFridgePhoto,
                          child: const Text('Изменить фото'),
                        ),
                      ],
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
