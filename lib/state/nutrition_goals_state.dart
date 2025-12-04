import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/supabase_config.dart';

class NutritionGoals {
  final int calories;
  final int protein;
  final int fat;
  final int carbs;

  NutritionGoals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
  };

  factory NutritionGoals.fromJson(Map<String, dynamic> json) => NutritionGoals(
    calories: json['calories'] ?? 2000,
    protein: json['protein'] ?? 150,
    fat: json['fat'] ?? 65,
    carbs: json['carbs'] ?? 250,
  );

  NutritionGoals copyWith({
    int? calories,
    int? protein,
    int? fat,
    int? carbs,
  }) => NutritionGoals(
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    fat: fat ?? this.fat,
    carbs: carbs ?? this.carbs,
  );
}

final nutritionGoalsProvider = StateNotifierProvider<NutritionGoalsNotifier, NutritionGoals>((ref) {
  return NutritionGoalsNotifier();
});

class NutritionGoalsNotifier extends StateNotifier<NutritionGoals> {
  NutritionGoalsNotifier() : super(NutritionGoals(
    calories: 2000,
    protein: 150,
    fat: 65,
    carbs: 250,
  )) {
    _loadGoals();
  }

  String get _storageKey {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    return 'nutrition_goals_${userId ?? "guest"}';
  }

  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString(_storageKey);
      
      if (goalsJson != null) {
        final decoded = jsonDecode(goalsJson);
        state = NutritionGoals.fromJson(decoded);
        print('[NutritionGoals] Loaded goals: ${state.calories} kcal');
      }
    } catch (e) {
      print('[NutritionGoals] Error loading goals: $e');
    }
  }

  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = jsonEncode(state.toJson());
      final userId = await _getUserId();
      await prefs.setString('${_storageKey}_$userId', goalsJson);
      print('[NutritionGoals] Saved goals: ${state.calories} kcal');
    } catch (e) {
      print('[NutritionGoals] Error saving goals: $e');
    }
  }

  void updateCalories(int value) {
    state = state.copyWith(calories: value);
    _saveGoals();
  }

  void updateProtein(int value) {
    state = state.copyWith(protein: value);
    _saveGoals();
  }

  void updateFat(int value) {
    state = state.copyWith(fat: value);
    _saveGoals();
  }

  void updateCarbs(int value) {
    state = state.copyWith(carbs: value);
    _saveGoals();
  }

  void updateAll({
    int? calories,
    int? protein,
    int? fat,
    int? carbs,
  }) {
    state = state.copyWith(
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    );
    _saveGoals();
  }
}
