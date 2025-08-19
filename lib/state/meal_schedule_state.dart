import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealItem {
  String name;
  int grams;
  int kcal;
  MealItem({required this.name, required this.grams, required this.kcal});
}

class MealGroup {
  String name;
  List<MealItem> items;
  MealGroup(this.name, [List<MealItem>? items]) : items = items ?? [];
}

final mealScheduleProvider =
    StateNotifierProvider<MealScheduleNotifier, List<MealGroup>>((ref) {
  return MealScheduleNotifier();
});

class MealScheduleNotifier extends StateNotifier<List<MealGroup>> {
  MealScheduleNotifier()
      : super([
          MealGroup('Завтрак', [MealItem(name: 'Овсянка', grams: 300, kcal: 350)]),
          MealGroup('Обед', [MealItem(name: 'Курица+рис', grams: 400, kcal: 520)]),
          MealGroup('Ужин', [MealItem(name: 'Творог', grams: 200, kcal: 180)]),
        ]);

  void addMeal(String name) => state = [...state, MealGroup(name)];
  void renameMeal(int index, String name) {
    final list = [...state]; list[index].name = name; state = list;
  }
  void removeMeal(int index) {
    final list = [...state]..removeAt(index); state = list;
  }
  void addItem(int mealIndex, MealItem item) {
    final list = [...state];
    list[mealIndex].items = [...list[mealIndex].items, item];
    state = list;
  }
  void editItem(int mealIndex, int itemIndex, MealItem item) {
    final list = [...state]; list[mealIndex].items[itemIndex] = item; state = list;
  }
  void deleteItem(int mealIndex, int itemIndex) {
    final list = [...state]; list[mealIndex].items.removeAt(itemIndex); state = list;
  }
  void reorderMeals(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    state = list;
  }
}
