import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/supabase_config.dart';

class MealItem {
  String name;
  int grams;
  int kcal;
  int protein;
  int fat;
  int carbs;
  bool completed;
  
  MealItem({
    required this.name,
    required this.grams,
    required this.kcal,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'grams': grams,
    'kcal': kcal,
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
    'completed': completed,
  };

  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
    name: json['name'] ?? '',
    grams: json['grams'] ?? 0,
    kcal: json['kcal'] ?? 0,
    protein: json['protein'] ?? 0,
    fat: json['fat'] ?? 0,
    carbs: json['carbs'] ?? 0,
    completed: json['completed'] ?? false,
  );
}

class MealGroup {
  String name;
  List<MealItem> items;
  
  MealGroup(this.name, [List<MealItem>? items]) : items = items ?? [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory MealGroup.fromJson(Map<String, dynamic> json) => MealGroup(
    json['name'] ?? '',
    (json['items'] as List?)?.map((e) => MealItem.fromJson(e)).toList(),
  );
}

final mealScheduleProvider =
    StateNotifierProvider<MealScheduleNotifier, List<MealGroup>>((ref) {
  return MealScheduleNotifier();
});

class MealScheduleNotifier extends StateNotifier<List<MealGroup>> {
  String? _lastUserId;
  
  MealScheduleNotifier() : super([]) {
    _loadMeals();
  }

  String get _storageKey {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    return 'meal_schedule_${userId ?? "guest"}';
  }
  
  String? get _currentUserId => SupabaseConfig.client.auth.currentUser?.id;

  Future<void> _loadMeals() async {
    try {
      // Проверяем, изменился ли пользователь
      final currentUserId = _currentUserId;
      if (_lastUserId != null && _lastUserId != currentUserId) {
        // Пользователь изменился - сбрасываем состояние
        print('[MealSchedule] User changed from $_lastUserId to $currentUserId, resetting state');
        state = [];
      }
      _lastUserId = currentUserId;
      
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString(_storageKey);
      
      if (mealsJson != null) {
        final List<dynamic> decoded = jsonDecode(mealsJson);
        state = decoded.map((e) => MealGroup.fromJson(e)).toList();
        print('[MealSchedule] Loaded ${state.length} meals for user $currentUserId');
      } else {
        // Дефолтные приемы пищи для нового пользователя
        state = [
          MealGroup('Завтрак', [MealItem(name: 'Овсянка', grams: 300, kcal: 350, protein: 12, fat: 7, carbs: 58)]),
          MealGroup('Обед', [MealItem(name: 'Курица+рис', grams: 400, kcal: 520, protein: 45, fat: 8, carbs: 65)]),
          MealGroup('Ужин', [MealItem(name: 'Творог', grams: 200, kcal: 180, protein: 30, fat: 3, carbs: 6)]),
        ];
        await _saveMeals();
      }
    } catch (e) {
      print('[MealSchedule] Error loading meals: $e');
      state = [
        MealGroup('Завтрак', [MealItem(name: 'Овсянка', grams: 300, kcal: 350, protein: 12, fat: 7, carbs: 58)]),
        MealGroup('Обед', [MealItem(name: 'Курица+рис', grams: 400, kcal: 520, protein: 45, fat: 8, carbs: 65)]),
        MealGroup('Ужин', [MealItem(name: 'Творог', grams: 200, kcal: 180, protein: 30, fat: 3, carbs: 6)]),
      ];
    }
  }

  Future<String> _getUserId() async {
    final user = SupabaseConfig.client.auth.currentUser;
    return user?.id ?? 'anonymous';
  }

  Future<void> _saveMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = jsonEncode(state.map((e) => e.toJson()).toList());
      final userId = await _getUserId();
      await prefs.setString('\${_storageKey}_\$userId', mealsJson);
      print('[MealSchedule] Saved \${state.length} meals');
    } catch (e) {
      print('[MealSchedule] Error saving meals: \$e');
    }
  }

  void addMeal(String name) {
    state = [...state, MealGroup(name)];
    _saveMeals();
  }

  void renameMeal(int index, String name) {
    final list = [...state];
    list[index].name = name;
    state = list;
    _saveMeals();
  }

  void removeMeal(int index) {
    final list = [...state]..removeAt(index);
    state = list;
    _saveMeals();
  }

  void addItem(int mealIndex, MealItem item) {
    final list = [...state];
    list[mealIndex].items = [...list[mealIndex].items, item];
    state = list;
    _saveMeals();
  }

  void editItem(int mealIndex, int itemIndex, MealItem item) {
    final list = [...state];
    list[mealIndex].items[itemIndex] = item;
    state = list;
    _saveMeals();
  }

  void deleteItem(int mealIndex, int itemIndex) {
    final list = [...state];
    list[mealIndex].items.removeAt(itemIndex);
    state = list;
    _saveMeals();
  }

  void toggleItemCompleted(int mealIndex, int itemIndex) {
    final list = [...state];
    list[mealIndex].items[itemIndex].completed = !list[mealIndex].items[itemIndex].completed;
    state = list;
    _saveMeals();
  }

  void reorderMeals(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    state = list;
    _saveMeals();
  }
  
  // Принудительная перезагрузка для нового пользователя
  Future<void> reload() async {
    _lastUserId = null;
    await _loadMeals();
  }

  // Получить общую статистику по КБЖУ
  Map<String, int> getTotalNutrition() {
    int totalKcal = 0;
    int totalProtein = 0;
    int totalFat = 0;
    int totalCarbs = 0;

    for (final meal in state) {
      for (final item in meal.items) {
        if (item.completed) {
          totalKcal += item.kcal;
          totalProtein += item.protein;
          totalFat += item.fat;
          totalCarbs += item.carbs;
        }
      }
    }

    return {
      'kcal': totalKcal,
      'protein': totalProtein,
      'fat': totalFat,
      'carbs': totalCarbs,
    };
  }
}
