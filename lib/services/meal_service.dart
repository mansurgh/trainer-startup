// lib/services/meal_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';
import 'nutrition_goal_checker.dart';

/// Сервис для работы с приемами пищи с изоляцией данных по userId
class MealService {
  
  /// Установить текущего пользователя (deprecated, use SharedPreferences)
  Future<void> setUserId(String userId) async {
    // No-op or save to prefs if needed, but we rely on global user_id in prefs
  }
  
  /// Получить ID пользователя из SharedPreferences
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? 'default';
  }
  
  /// Получить ключ для хранения приемов пищи
  Future<String> _getMealsKey(DateTime date) async {
    final userId = await _getUserId();
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return 'meals_${userId}_$dateKey';
  }
  
  /// Получить приемы пищи за дату
  Future<List<Meal>> getMealsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getMealsKey(date);
    final jsonString = prefs.getString(key);
    
    if (jsonString == null || jsonString.isEmpty) {
      // Возвращаем пустые приемы пищи
      return _createEmptyMeals(date);
    }
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Meal.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('[MealService] Error loading meals: $e');
      return _createEmptyMeals(date);
    }
  }
  
  /// Создать пустые приемы пищи для даты
  List<Meal> _createEmptyMeals(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return [
      Meal(
        id: 'breakfast_${date.day}',
        type: MealType.breakfast,
        date: normalizedDate,
        dishes: [],
        customName: 'Breakfast', // Default English, will be localized in UI if needed
      ),
      Meal(
        id: 'lunch_${date.day}',
        type: MealType.lunch,
        date: normalizedDate,
        dishes: [],
        customName: 'Lunch',
      ),
      Meal(
        id: 'dinner_${date.day}',
        type: MealType.dinner,
        date: normalizedDate,
        dishes: [],
        customName: 'Dinner',
      ),
    ];
  }
  
  /// Сохранить приемы пищи
  Future<void> _saveMeals(List<Meal> meals, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getMealsKey(date);
    final jsonString = json.encode(meals.map((m) => m.toJson()).toList());
    await prefs.setString(key, jsonString);
  }
  
  /// Добавить блюдо в прием пищи
  Future<void> addDishToMeal(String mealId, Dish dish) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meals = await getMealsForDate(today);
    
    final mealIndex = meals.indexWhere((m) => m.id == mealId);
    if (mealIndex != -1) {
      meals[mealIndex].dishes.add(dish);
      await _saveMeals(meals, today);
      
      // Проверяем выполнение целей после добавления блюда
      await NutritionGoalChecker.checkNow();
    }
  }
  
  /// Удалить блюдо из приема пищи
  Future<void> removeDishFromMeal(String mealId, String dishId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meals = await getMealsForDate(today);
    
    final mealIndex = meals.indexWhere((m) => m.id == mealId);
    if (mealIndex != -1) {
      meals[mealIndex].dishes.removeWhere((d) => d.id == dishId);
      await _saveMeals(meals, today);
      
      // Проверяем выполнение целей после удаления блюда
      await NutritionGoalChecker.checkNow();
    }
  }
  
  /// Обновить блюдо
  Future<void> updateDish(String mealId, Dish updatedDish) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meals = await getMealsForDate(today);
    
    final mealIndex = meals.indexWhere((m) => m.id == mealId);
    if (mealIndex != -1) {
      final dishIndex = meals[mealIndex].dishes.indexWhere((d) => d.id == updatedDish.id);
      if (dishIndex != -1) {
        meals[mealIndex].dishes[dishIndex] = updatedDish;
        await _saveMeals(meals, today);
        
        // Проверяем выполнение целей после обновления блюда
        await NutritionGoalChecker.checkNow();
      }
    }
  }
  
  /// Отметить блюдо как съеденное/несъеденное
  Future<void> toggleDishCompletion(String mealId, String dishId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meals = await getMealsForDate(today);
    
    final mealIndex = meals.indexWhere((m) => m.id == mealId);
    if (mealIndex != -1) {
      final dishIndex = meals[mealIndex].dishes.indexWhere((d) => d.id == dishId);
      if (dishIndex != -1) {
        meals[mealIndex].dishes[dishIndex].isCompleted = 
            !meals[mealIndex].dishes[dishIndex].isCompleted;
        await _saveMeals(meals, today);
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
    
    for (final meal in meals) {
      totalCalories += meal.totalCalories;
      totalProtein += meal.totalProtein;
      totalFat += meal.totalFat;
      totalCarbs += meal.totalCarbs;
      
      completedCalories += meal.completedCalories;
      completedProtein += meal.completedProtein;
      completedFat += meal.completedFat;
      completedCarbs += meal.completedCarbs;
    }
    
    // Получаем цели (user-specific)
    final prefs = await SharedPreferences.getInstance();
    final userId = await _getUserId();
    final targetCalories = prefs.getInt('nutrition_goal_${userId}_calories') ?? 2000;
    final targetProtein = prefs.getInt('nutrition_goal_${userId}_protein') ?? 150;
    final targetFat = prefs.getInt('nutrition_goal_${userId}_fat') ?? 65;
    final targetCarbs = prefs.getInt('nutrition_goal_${userId}_carbs') ?? 250;
    
    // Save daily totals for NutritionGoalChecker
    final dateKey = '${date.year}-${date.month}-${date.day}';
    await prefs.setInt('daily_calories_${userId}_$dateKey', completedCalories);
    await prefs.setInt('daily_protein_${userId}_$dateKey', completedProtein.toInt());
    await prefs.setInt('daily_fat_${userId}_$dateKey', completedFat.toInt());
    await prefs.setInt('daily_carbs_${userId}_$dateKey', completedCarbs.toInt());
    
    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalFat': totalFat,
      'totalCarbs': totalCarbs,
      'completedCalories': completedCalories,
      'completedProtein': completedProtein,
      'completedFat': completedFat,
      'completedCarbs': completedCarbs,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein.toDouble(),
      'targetFat': targetFat.toDouble(),
      'targetCarbs': targetCarbs.toDouble(),
    };
  }
  
  /// Создать новый прием пищи
  Future<void> createMeal(Meal meal) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final meals = await getMealsForDate(meal.date);
    meals.add(meal);
    await _saveMeals(meals, meal.date);
  }
  
  /// Удалить прием пищи
  Future<void> deleteMeal(String mealId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final meals = await getMealsForDate(date);
    meals.removeWhere((m) => m.id == mealId);
    await _saveMeals(meals, date);
  }
  
  /// Переименовать прием пищи (изменить тип)
  Future<void> renameMeal(String mealId, MealType newType, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final meals = await getMealsForDate(date);
    final mealIndex = meals.indexWhere((m) => m.id == mealId);
    
    if (mealIndex != -1) {
      final oldMeal = meals[mealIndex];
      meals[mealIndex] = Meal(
        id: mealId,
        type: newType,
        date: oldMeal.date,
        dishes: oldMeal.dishes,
      );
      await _saveMeals(meals, date);
    }
  }

  /// Обновить кастомное название приема пищи
  Future<void> updateMealName(String mealId, String newName, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final meals = await getMealsForDate(date);
    final mealIndex = meals.indexWhere((m) => m.id == mealId);
    
    if (mealIndex != -1) {
      final oldMeal = meals[mealIndex];
      meals[mealIndex] = oldMeal.copyWith(customName: newName);
      await _saveMeals(meals, date);
    }
  }
  
  /// Изменить порядок приемов пищи
  Future<void> reorderMeals(List<String> mealIds, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final meals = await getMealsForDate(date);
    final reorderedMeals = <Meal>[];
    
    for (final id in mealIds) {
      final meal = meals.firstWhere((m) => m.id == id);
      reorderedMeals.add(meal);
    }
    
    await _saveMeals(reorderedMeals, date);
  }
  
  /// Очистить все данные (для смены пользователя)
  Future<void> clearAll() async {
    // No local state to clear, handled by SharedPreferences
  }
}
