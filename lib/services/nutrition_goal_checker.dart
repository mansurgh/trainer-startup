import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/activity_state.dart';

/// Сервис для проверки выполнения целей по питанию
class NutritionGoalChecker {
  static Timer? _timer;
  
  /// Запустить фоновую проверку целей
  static void startMonitoring() {
    // Проверять каждые 5 минут
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _checkGoals());
    // Сразу проверяем при запуске
    _checkGoals();
  }
  
  /// Остановить мониторинг
  static void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Проверить выполнение целей за сегодня
  static Future<void> _checkGoals([WidgetRef? ref]) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? 'anonymous';
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    
    // Получаем текущие данные
    final currentCalories = prefs.getInt('daily_calories_${userId}_$dateKey') ?? 0;
    final currentProtein = prefs.getInt('daily_protein_${userId}_$dateKey') ?? 0;
    final currentFat = prefs.getInt('daily_fat_${userId}_$dateKey') ?? 0;
    final currentCarbs = prefs.getInt('daily_carbs_${userId}_$dateKey') ?? 0;
    
    // Получаем цели (с userId для изоляции)
    final goalCalories = prefs.getInt('nutrition_goal_${userId}_calories') ?? 2200;
    final goalProtein = prefs.getInt('nutrition_goal_${userId}_protein') ?? 120;
    final goalFat = prefs.getInt('nutrition_goal_${userId}_fat') ?? 80;
    final goalCarbs = prefs.getInt('nutrition_goal_${userId}_carbs') ?? 250;
    
    // Проверяем выполнение целей (более мягкие условия: 80-120% от цели)
    // Главное - калории и белок
    final caloriesOk = _isGoalMet(currentCalories, goalCalories, minPct: 0.8, maxPct: 1.5); // Allow up to 150%
    final proteinOk = _isGoalMet(currentProtein, goalProtein, minPct: 0.7, maxPct: 3.0); // Allow up to 300%
    
    // Жиры и углеводы менее критичны
    final fatOk = _isGoalMet(currentFat, goalFat, minPct: 0.5, maxPct: 2.0);
    final carbsOk = _isGoalMet(currentCarbs, goalCarbs, minPct: 0.5, maxPct: 2.0);
    
    // Если калории и белок в норме - считаем день успешным
    if (caloriesOk && proteinOk) {
      await prefs.setBool('nutrition_completed_${userId}_$dateKey', true);
      print('[NutritionGoalChecker] ✅ Goals met for $dateKey (Cal: $currentCalories/$goalCalories, Prot: $currentProtein/$goalProtein)');
      // Обновляем статистику Today's Win
      ref?.invalidate(todaysWinProvider);
    } else {
      // Если не выполнено - сбрасываем (если вдруг было true)
      // Но только если мы уверены, что это не "частичное" выполнение
      // Пока оставим как есть, чтобы не сбрасывать случайно
      // await prefs.setBool('nutrition_completed_${userId}_$dateKey', false);
    }
  }
  
  /// Проверяет достижение цели с учётом диапазона
  static bool _isGoalMet(int current, int goal, {double minPct = 0.9, double maxPct = 1.1}) {
    final min = goal * minPct;
    final max = goal * maxPct;
    return current >= min && current <= max;
  }
  
  /// Принудительная проверка (вызывается после добавления еды)
  static Future<void> checkNow([WidgetRef? ref]) async {
    await _checkGoals(ref);
  }
}
