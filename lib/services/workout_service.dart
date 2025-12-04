import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Сервис для управления текущей тренировкой и упражнениями
class WorkoutService {
  static Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? 'anonymous';
  }
  
  static const String _currentWorkoutKey = 'current_workout';
  static const String _workoutHistoryKey = 'workout_history';

  /// Получить текущую тренировку
  Future<Map<String, dynamic>?> getCurrentWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _getUserId();
    final workoutJson = prefs.getString('${_currentWorkoutKey}_$userId');
    
    if (workoutJson == null) return null;
    
    try {
      return jsonDecode(workoutJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Сохранить текущую тренировку
  Future<void> saveCurrentWorkout(Map<String, dynamic> workout) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _getUserId();
    await prefs.setString('${_currentWorkoutKey}_$userId', jsonEncode(workout));
  }

  /// Удалить текущую тренировку (после завершения)
  static Future<void> clearCurrentWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _getUserId();
    await prefs.remove('${_currentWorkoutKey}_$userId');
  }

  /// Получить список упражнений текущей тренировки
  Future<List<String>> getCurrentExercises() async {
    final workout = await getCurrentWorkout();
    
    if (workout == null) return [];
    
    final exercises = workout['exercises'] as List?;
    if (exercises == null) return [];
    
    return exercises.map((e) => e.toString()).toList();
  }

  /// Заменить упражнение в текущей тренировке
  Future<bool> swapExercise(String oldExercise, String newExercise) async {
    final workout = await getCurrentWorkout();
    
    if (workout == null) {
      // Если нет активной тренировки, создаем новую с одним упражнением
      await saveCurrentWorkout({
        'exercises': [newExercise],
        'currentIndex': 0,
        'startedAt': DateTime.now().toIso8601String(),
      });
      return true;
    }
    
    final exercises = workout['exercises'] as List?;
    if (exercises == null) return false;
    
    // Ищем упражнение по частичному совпадению (case-insensitive)
    final oldLower = oldExercise.toLowerCase();
    int foundIndex = -1;
    
    for (int i = 0; i < exercises.length; i++) {
      final exerciseName = exercises[i].toString().toLowerCase();
      if (exerciseName.contains(oldLower) || oldLower.contains(exerciseName)) {
        foundIndex = i;
        break;
      }
    }
    
    if (foundIndex == -1) {
      // Упражнение не найдено, добавляем новое в конец
      exercises.add(newExercise);
    } else {
      // Заменяем найденное упражнение
      exercises[foundIndex] = newExercise;
    }
    
    workout['exercises'] = exercises;
    await saveCurrentWorkout(workout);
    
    return true;
  }

  /// Начать новую тренировку
  Future<void> startWorkout(List<String> exercises) async {
    await saveCurrentWorkout({
      'exercises': exercises,
      'currentIndex': 0,
      'startedAt': DateTime.now().toIso8601String(),
      'completedExercises': [],
    });
  }

  /// Обновить текущий индекс упражнения
  Future<void> updateCurrentIndex(int index) async {
    final workout = await getCurrentWorkout();
    if (workout == null) return;
    
    workout['currentIndex'] = index;
    await saveCurrentWorkout(workout);
  }

  /// Отметить упражнение как выполненное
  Future<void> completeExercise(String exerciseName) async {
    final workout = await getCurrentWorkout();
    if (workout == null) return;
    
    final completed = workout['completedExercises'] as List? ?? [];
    if (!completed.contains(exerciseName)) {
      completed.add(exerciseName);
      workout['completedExercises'] = completed;
      await saveCurrentWorkout(workout);
    }
  }

  /// Получить историю тренировок
  Future<List<Map<String, dynamic>>> getWorkoutHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_workoutHistoryKey) ?? [];
    
    return historyJson.map((json) {
      try {
        return jsonDecode(json) as Map<String, dynamic>;
      } catch (e) {
        return <String, dynamic>{};
      }
    }).where((w) => w.isNotEmpty).toList();
  }

  /// Завершить тренировку и добавить в историю
  Future<void> finishWorkout() async {
    final workout = await getCurrentWorkout();
    if (workout == null) return;
    
    workout['completedAt'] = DateTime.now().toIso8601String();
    
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_workoutHistoryKey) ?? [];
    history.add(jsonEncode(workout));
    
    // Храним только последние 50 тренировок
    if (history.length > 50) {
      history.removeAt(0);
    }
    
    final userId = await _getUserId();
    await prefs.setStringList('${_workoutHistoryKey}_$userId', history);
    await clearCurrentWorkout();
  }

  /// Получить текущее упражнение
  Future<String?> getCurrentExercise() async {
    final workout = await getCurrentWorkout();
    if (workout == null) return null;
    
    final exercises = workout['exercises'] as List?;
    final currentIndex = workout['currentIndex'] as int? ?? 0;
    
    if (exercises == null || currentIndex >= exercises.length) {
      return null;
    }
    
    return exercises[currentIndex].toString();
  }
}
