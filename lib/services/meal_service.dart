// lib/services/meal_service.dart

import '../models/meal.dart';

class MealService {
  // Временное хранилище (в будущем будет заменено на Supabase)
  final List<Meal> _meals = [];

  MealService() {
    _initializeDemoData();
  }

  void _initializeDemoData() {
    // Используем только дату без времени для корректного сравнения
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Завтрак
    _meals.add(Meal(
      id: 'breakfast_${today.day}',
      type: MealType.breakfast,
      date: today,
      dishes: [
        Dish(
          id: 'b1',
          name: 'Oatmeal with berries',
          calories: 350,
          protein: 12,
          fat: 8,
          carbs: 55,
          isCompleted: true,
        ),
        Dish(
          id: 'b2',
          name: 'Greek yogurt',
          calories: 150,
          protein: 15,
          fat: 5,
          carbs: 12,
          isCompleted: true,
        ),
      ],
    ));

    // Обед
    _meals.add(Meal(
      id: 'lunch_${today.day}',
      type: MealType.lunch,
      date: today,
      dishes: [
        Dish(
          id: 'l1',
          name: 'Grilled chicken breast',
          calories: 280,
          protein: 45,
          fat: 8,
          carbs: 0,
          isCompleted: false,
        ),
        Dish(
          id: 'l2',
          name: 'Rice with vegetables',
          calories: 320,
          protein: 8,
          fat: 5,
          carbs: 60,
          isCompleted: false,
        ),
      ],
    ));

    // Ужин
    _meals.add(Meal(
      id: 'dinner_${today.day}',
      type: MealType.dinner,
      date: today,
      dishes: [
        Dish(
          id: 'd1',
          name: 'Salmon fillet',
          calories: 350,
          protein: 40,
          fat: 18,
          carbs: 0,
          isCompleted: false,
        ),
        Dish(
          id: 'd2',
          name: 'Sweet potato',
          calories: 180,
          protein: 4,
          fat: 0,
          carbs: 42,
          isCompleted: false,
        ),
      ],
    ));
  }

  /// Получить все приемы пищи за день
  Future<List<Meal>> getMealsForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Нормализуем дату (убираем время)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _meals.where((meal) {
      final mealDate = DateTime(meal.date.year, meal.date.month, meal.date.day);
      return mealDate == normalizedDate;
    }).toList();
  }

  /// Добавить новое блюдо в прием пищи
  Future<void> addDishToMeal(String mealId, Dish dish) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final mealIndex = _meals.indexWhere((m) => m.id == mealId);
    if (mealIndex != -1) {
      _meals[mealIndex].dishes.add(dish);
    }
  }

  /// Удалить блюдо из приема пищи
  Future<void> removeDishFromMeal(String mealId, String dishId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final mealIndex = _meals.indexWhere((m) => m.id == mealId);
    if (mealIndex != -1) {
      _meals[mealIndex].dishes.removeWhere((d) => d.id == dishId);
    }
  }

  /// Обновить блюдо
  Future<void> updateDish(String mealId, Dish updatedDish) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final mealIndex = _meals.indexWhere((m) => m.id == mealId);
    if (mealIndex != -1) {
      final dishIndex = _meals[mealIndex].dishes.indexWhere((d) => d.id == updatedDish.id);
      if (dishIndex != -1) {
        _meals[mealIndex].dishes[dishIndex] = updatedDish;
      }
    }
  }

  /// Отметить блюдо как съеденное/несъеденное
  Future<void> toggleDishCompletion(String mealId, String dishId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final mealIndex = _meals.indexWhere((m) => m.id == mealId);
    if (mealIndex != -1) {
      final dishIndex = _meals[mealIndex].dishes.indexWhere((d) => d.id == dishId);
      if (dishIndex != -1) {
        _meals[mealIndex].dishes[dishIndex].isCompleted = 
            !_meals[mealIndex].dishes[dishIndex].isCompleted;
      }
    }
  }

  /// Получить суммарные макросы за день
  Future<Map<String, dynamic>> getDailyTotals(DateTime date) async {
    final meals = await getMealsForDate(date);
    
    int totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    int completedCalories = 0;
    double completedProtein = 0;
    double completedFat = 0;
    double completedCarbs = 0;

    for (var meal in meals) {
      totalCalories += meal.totalCalories;
      totalProtein += meal.totalProtein;
      totalFat += meal.totalFat;
      totalCarbs += meal.totalCarbs;

      completedCalories += meal.completedCalories;
      completedProtein += meal.completedProtein;
      completedFat += meal.completedFat;
      completedCarbs += meal.completedCarbs;
    }

    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalFat': totalFat,
      'totalCarbs': totalCarbs,
      'completedCalories': completedCalories,
      'completedProtein': completedProtein,
      'completedFat': completedFat,
      'completedCarbs': completedCarbs,
      // Целевые значения (можно будет настраивать в профиле)
      'targetCalories': 2200,
      'targetProtein': 120.0,
      'targetFat': 80.0,
      'targetCarbs': 250.0,
    };
  }

  /// Создать новый прием пищи
  Future<void> createMeal(Meal meal) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _meals.add(meal);
  }
}
