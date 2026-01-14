import 'dart:io' show File;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Service for fetching user statistics from Supabase
/// Silent mode - no debug logs to reduce console spam
class StatsService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get user's current streak (consecutive days of activity)
  /// Minimum streak is 1 if user is logged in (current visit counts)
  Future<int> getStreak() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 1; // User logged in = at least 1 day streak

      final now = DateTime.now();
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));
      final todayStr = DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];
      final yesterdayStr = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1))
          .toIso8601String().split('T')[0];

      // Get last visit date from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final lastVisitKey = 'last_visit_$userId';
      final lastVisit = prefs.getString(lastVisitKey);
      
      // Save today as last visit
      await prefs.setString(lastVisitKey, todayStr);
      
      // Get streak count
      final streakKey = 'streak_count_$userId';
      int currentStreak = prefs.getInt(streakKey) ?? 1;
      
      // If first visit or yesterday was visited, increment/maintain streak
      if (lastVisit == null) {
        // First visit ever
        currentStreak = 1;
      } else if (lastVisit == todayStr) {
        // Already visited today, keep current streak
      } else if (lastVisit == yesterdayStr) {
        // Visited yesterday, increment streak
        currentStreak++;
      } else {
        // Missed one or more days, reset to 1
        currentStreak = 1;
      }
      
      // Save updated streak
      await prefs.setInt(streakKey, currentStreak);
      
      return currentStreak;
    } catch (_) {
      return 1; // Default to 1 if any error
    }
  }

  /// Get number of completed workouts this month
  Future<int> getWorkoutsThisMonth() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      
      final response = await _client
          .from('workout_sessions')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .gte('workout_date', firstDayOfMonth.toIso8601String().split('T')[0]);

      return response.length;
    } catch (_) {
      return 0;
    }
  }

  /// Get workout target for the month
  Future<int> getMonthlyWorkoutTarget() async => 20;

  /// Get weight change from body_measurements table
  Future<double?> getWeightChange() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return null;

      // Get all weight measurements ordered by date
      final allMeasurements = await _client
          .from('body_measurements')
          .select('weight, measurement_date')
          .eq('user_id', userId)
          .not('weight', 'is', null)
          .order('measurement_date', ascending: false);

      if (allMeasurements == null || (allMeasurements as List).isEmpty) {
        return null;
      }

      final List<dynamic> measurements = allMeasurements;
      
      // Latest weight is first in list
      final currentWeight = (measurements[0]['weight'] as num).toDouble();
      
      // If we have at least 2 measurements, compare with previous
      if (measurements.length >= 2) {
        final previousWeight = (measurements[1]['weight'] as num).toDouble();
        return currentWeight - previousWeight;
      }
      
      // Only one measurement - compare with profile initial weight
      final profileResponse = await _client
          .from('profiles')
          .select('weight')
          .eq('id', userId)
          .maybeSingle();
      
      if (profileResponse != null && profileResponse['weight'] != null) {
        final initialWeight = (profileResponse['weight'] as num).toDouble();
        // Only return change if different from current
        if ((currentWeight - initialWeight).abs() >= 0.1) {
          return currentWeight - initialWeight;
        }
      }
      
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Calculate Success Day percentage
  Future<Map<String, dynamic>> getSuccessDayStats() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        return {'percentage': 0, 'breakdown': {}};
      }

      final now = DateTime.now();
      final todayStr = DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];

      int percentage = 10; // Login bonus
      final breakdown = <String, int>{'login': 10};

      final streak = await getStreak();
      if (streak > 0) {
        percentage += 20;
        breakdown['streak'] = 20;
      } else {
        breakdown['streak'] = 0;
      }

      final nutritionResponse = await _client
          .from('nutrition_logs')
          .select('id')
          .eq('user_id', userId)
          .eq('meal_date', todayStr)
          .limit(1);

      if (nutritionResponse.isNotEmpty) {
        percentage += 40;
        breakdown['nutrition'] = 40;
      } else {
        breakdown['nutrition'] = 0;
      }

      final workoutResponse = await _client
          .from('workout_sessions')
          .select('id')
          .eq('user_id', userId)
          .eq('workout_date', todayStr)
          .eq('status', 'completed')
          .limit(1);

      if (workoutResponse.isNotEmpty) {
        percentage += 30;
        breakdown['workout'] = 30;
      } else {
        breakdown['workout'] = 0;
      }

      return {
        'percentage': percentage,
        'breakdown': breakdown,
        'streak': streak,
      };
    } catch (_) {
      return {'percentage': 10, 'breakdown': {'login': 10}};
    }
  }

  /// Record today's visit
  Future<void> recordVisit() async {}

  /// Get all workout history for the user
  Future<List<Map<String, dynamic>>> getWorkoutHistory({int limit = 50}) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final response = await _client
          .from('workout_sessions')
          .select('*, exercise_logs(*)')
          .eq('user_id', userId)
          .order('workout_date', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  /// Get progress photos for the user
  Future<List<Map<String, dynamic>>> getProgressPhotos({int limit = 50}) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final response = await _client
          .from('progress_photos')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  /// Upload a progress photo
  Future<String?> uploadProgressPhoto({
    required String filePath,
    String? note,
    double? weight,
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      final file = await _uploadToStorage(filePath, userId, 'progress-photos');
      if (file == null) throw Exception('Failed to upload file');

      await _client.from('progress_photos').insert({
        'user_id': userId,
        'photo_url': file,
        'note': note,
        'weight': weight,
      });

      return file;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _uploadToStorage(String localPath, String userId, String bucket) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$userId/$timestamp.jpg';
      
      final bytes = await File(localPath).readAsBytes();

      await _client.storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );

      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  /// Get muscle fatigue data from recent workouts
  Future<Map<String, double>> getMuscleFatigue() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return {};

      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final response = await _client
          .from('exercise_logs')
          .select('muscle_group, sets, reps, weight')
          .eq('user_id', userId)
          .gte('created_at', sevenDaysAgo.toIso8601String());

      final fatigueMap = <String, double>{};
      final volumeMap = <String, double>{};

      for (final log in response) {
        final muscleGroup = log['muscle_group'] as String?;
        if (muscleGroup == null) continue;

        final sets = (log['sets'] as int?) ?? 1;
        final reps = (log['reps'] as int?) ?? 10;
        final weight = (log['weight'] as num?)?.toDouble() ?? 0;

        final volume = sets * reps * (weight > 0 ? weight : 1.0);
        volumeMap[muscleGroup] = (volumeMap[muscleGroup] ?? 0) + volume;
      }

      const maxVolume = 5000.0;
      for (final entry in volumeMap.entries) {
        fatigueMap[entry.key] = (entry.value / maxVolume).clamp(0.0, 1.0);
      }

      return fatigueMap;
    } catch (_) {
      return {};
    }
  }

  /// Get user characteristics for the radar chart
  /// RPG-style stats that grow with user activity:
  /// - Discipline = streak / 10 (max 100 at 1000 day streak)
  /// - Strength = 0.1 * total workouts (max 100 at 1000 workouts)
  /// - Nutrition = based on logged meals
  /// - Endurance = based on workout duration
  /// - Balance = based on muscle group variety
  Future<Map<String, double>> getCharacteristics() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return _getDefaultCharacteristics();

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      // 1. DISCIPLINE = streak / 10 (simple formula)
      final streak = await getStreak();
      final discipline = (streak / 10.0).clamp(0.0, 100.0);

      // 2. NUTRITION — based on logged meals in last 30 days
      final nutritionResponse = await _client
          .from('nutrition_logs')
          .select('meal_date, is_completed')
          .eq('user_id', userId)
          .gte('meal_date', thirtyDaysAgo.toIso8601String().split('T')[0]);

      final nutritionDays = <String>{};
      int completedMeals = 0;
      for (final log in nutritionResponse) {
        nutritionDays.add(log['meal_date'].toString().split('T')[0]);
        if (log['is_completed'] == true) completedMeals++;
      }
      final nutritionDaysScore = (nutritionDays.length / 30 * 70).clamp(0.0, 70.0);
      final completionBonus = (completedMeals / 90 * 30).clamp(0.0, 30.0);
      final nutrition = (nutritionDaysScore + completionBonus).clamp(0.0, 100.0);

      // 3. STRENGTH = 0.1 * total workouts (all time)
      final totalWorkoutsResponse = await _client
          .from('workout_sessions')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'completed');
      
      final totalWorkouts = (totalWorkoutsResponse as List).length;
      final strength = (totalWorkouts * 0.1).clamp(0.0, 100.0);

      // 4. ENDURANCE — based on total workout duration in last 30 days
      final enduranceResponse = await _client
          .from('workout_sessions')
          .select('duration_minutes')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .gte('workout_date', thirtyDaysAgo.toIso8601String().split('T')[0]);

      int totalMinutes = 0;
      for (final session in enduranceResponse) {
        totalMinutes += (session['duration_minutes'] as int?) ?? 0;
      }
      final endurance = (totalMinutes / 600 * 100).clamp(0.0, 100.0);

      // 5. BALANCE — based on muscle group variety in last 30 days
      final balanceResponse = await _client
          .from('exercise_logs')
          .select('muscle_group')
          .eq('user_id', userId)
          .gte('created_at', thirtyDaysAgo.toIso8601String());

      final muscleGroups = <String>{};
      for (final log in balanceResponse) {
        final group = log['muscle_group'] as String?;
        if (group != null) muscleGroups.add(group);
      }
      final balance = (muscleGroups.length / 8 * 100).clamp(0.0, 100.0);

      return {
        'discipline': discipline,
        'nutrition': nutrition,
        'strength': strength,
        'endurance': endurance,
        'balance': balance,
      };
    } catch (_) {
      return _getDefaultCharacteristics();
    }
  }

  Map<String, double> _getDefaultCharacteristics() {
    // New users start at 0 - no fake data
    return {
      'discipline': 0.0,
      'nutrition': 0.0,
      'strength': 0.0,
      'endurance': 0.0,
      'balance': 0.0,
    };
  }

  // ===========================================================================
  // 7-Day History Methods
  // ===========================================================================

  /// Get workout history for last 7 days
  Future<List<WorkoutDayStatus>> getWorkoutHistory7Days() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final results = <WorkoutDayStatus>[];
      
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        
        if (i == 0) {
          // Today - check if has workout
          if (userId != null) {
            final response = await _client
                .from('workout_sessions')
                .select('id')
                .eq('user_id', userId)
                .eq('workout_date', dateStr)
                .eq('status', 'completed');
            
            results.add(WorkoutDayStatus(
              date: date,
              status: response.isNotEmpty ? WorkoutStatus.completed : WorkoutStatus.today,
              workoutCount: response.length,
            ));
          } else {
            results.add(WorkoutDayStatus(
              date: date,
              status: WorkoutStatus.today,
            ));
          }
        } else {
          // Past days
          if (userId != null) {
            final response = await _client
                .from('workout_sessions')
                .select('id')
                .eq('user_id', userId)
                .eq('workout_date', dateStr)
                .eq('status', 'completed');
            
            results.add(WorkoutDayStatus(
              date: date,
              status: response.isNotEmpty ? WorkoutStatus.completed : WorkoutStatus.missed,
              workoutCount: response.isNotEmpty ? response.length : null,
            ));
          } else {
            results.add(WorkoutDayStatus(
              date: date,
              status: WorkoutStatus.missed,
            ));
          }
        }
      }
      
      return results;
    } catch (e) {
      // Return empty history on error
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return List.generate(7, (i) => WorkoutDayStatus(
        date: today.subtract(Duration(days: 6 - i)),
        status: i == 6 ? WorkoutStatus.today : WorkoutStatus.missed,
      ));
    }
  }

  /// Get nutrition history for last 7 days
  Future<List<NutritionDayStatus>> getNutritionHistory7Days() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Get user's calorie target
      int targetCalories = 2000;
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        targetCalories = prefs.getInt('nutrition_goal_${userId}_calories') ?? 2000;
      }
      
      final results = <NutritionDayStatus>[];
      
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        
        if (i == 0) {
          // Today
          if (userId != null) {
            final response = await _client
                .from('nutrition_logs')
                .select('calories')
                .eq('user_id', userId)
                .eq('meal_date', dateStr);
            
            int totalCalories = 0;
            for (final log in response) {
              totalCalories += (log['calories'] as int?) ?? 0;
            }
            
            final percentage = targetCalories > 0 ? totalCalories / targetCalories : 0.0;
            
            results.add(NutritionDayStatus(
              date: date,
              status: NutritionStatus.today,
              caloriePercentage: percentage,
            ));
          } else {
            results.add(NutritionDayStatus(
              date: date,
              status: NutritionStatus.today,
              caloriePercentage: 0,
            ));
          }
        } else {
          // Past days
          if (userId != null) {
            final response = await _client
                .from('nutrition_logs')
                .select('calories')
                .eq('user_id', userId)
                .eq('meal_date', dateStr);
            
            int totalCalories = 0;
            for (final log in response) {
              totalCalories += (log['calories'] as int?) ?? 0;
            }
            
            final percentage = targetCalories > 0 ? totalCalories / targetCalories : 0.0;
            final status = _getNutritionStatus(percentage);
            
            results.add(NutritionDayStatus(
              date: date,
              status: status,
              caloriePercentage: percentage,
            ));
          } else {
            results.add(NutritionDayStatus(
              date: date,
              status: NutritionStatus.empty,
              caloriePercentage: 0,
            ));
          }
        }
      }
      
      return results;
    } catch (e) {
      // Return empty history on error
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return List.generate(7, (i) => NutritionDayStatus(
        date: today.subtract(Duration(days: 6 - i)),
        status: i == 6 ? NutritionStatus.today : NutritionStatus.empty,
        caloriePercentage: 0,
      ));
    }
  }
  
  NutritionStatus _getNutritionStatus(double percentage) {
    if (percentage >= 0.9 && percentage <= 1.1) return NutritionStatus.excellent;
    if (percentage >= 0.7) return NutritionStatus.good;
    if (percentage > 0) return NutritionStatus.poor;
    return NutritionStatus.empty;
  }

  /// Get last 7 days nutrition data for profile widget
  /// Returns list of _DayNutrition objects (defined in profile_screen.dart)
  Future<List<dynamic>> getLast7DaysNutrition() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sevenDaysAgo = today.subtract(const Duration(days: 6));
      
      // Default target calories
      int targetCalories = 2000;
      
      // Try to get user's target from profile
      if (userId != null) {
        try {
          final profileResponse = await _client
              .from('profiles')
              .select('target_calories')
              .eq('id', userId)
              .maybeSingle();
          
          if (profileResponse != null && profileResponse['target_calories'] != null) {
            targetCalories = profileResponse['target_calories'] as int;
          }
        } catch (_) {
          // Use default
        }
      }
      
      // Fetch nutrition logs for last 7 days
      final List<Map<String, int>> results = [];
      
      for (int i = 0; i < 7; i++) {
        final date = sevenDaysAgo.add(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        
        int totalCalories = 0;
        
        if (userId != null) {
          try {
            final response = await _client
                .from('nutrition_logs')
                .select('calories')
                .eq('user_id', userId)
                .eq('meal_date', dateStr);
            
            for (final log in response) {
              totalCalories += (log['calories'] as int?) ?? 0;
            }
          } catch (_) {
            // Day has no data
          }
        }
        
        results.add({
          'year': date.year,
          'month': date.month,
          'day': date.day,
          'weekday': date.weekday,
          'calories': totalCalories,
          'target': targetCalories,
        });
      }
      
      return results;
    } catch (e) {
      // Return empty data on error
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return List.generate(7, (i) {
        final date = today.subtract(Duration(days: 6 - i));
        return {
          'year': date.year,
          'month': date.month,
          'day': date.day,
          'weekday': date.weekday,
          'calories': 0,
          'target': 2000,
        };
      });
    }
  }
  
  /// Get last 7 days workout data for profile widget
  /// Returns list of workout counts per day
  Future<List<dynamic>> getLast7DaysWorkouts() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sevenDaysAgo = today.subtract(const Duration(days: 6));
      
      final List<Map<String, int>> results = [];
      
      for (int i = 0; i < 7; i++) {
        final date = sevenDaysAgo.add(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        
        int workoutCount = 0;
        
        if (userId != null) {
          try {
            final response = await _client
                .from('workout_sessions')
                .select('id')
                .eq('user_id', userId)
                .gte('started_at', '$dateStr 00:00:00')
                .lt('started_at', '${date.add(const Duration(days: 1)).toIso8601String().split('T')[0]} 00:00:00')
                .eq('status', 'completed');
            
            workoutCount = response.length;
          } catch (_) {
            // Day has no data
          }
        }
        
        results.add({
          'year': date.year,
          'month': date.month,
          'day': date.day,
          'weekday': date.weekday,
          'workouts': workoutCount,
        });
      }
      
      return results;
    } catch (e) {
      // Return empty data on error
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return List.generate(7, (i) {
        final date = today.subtract(Duration(days: 6 - i));
        return {
          'year': date.year,
          'month': date.month,
          'day': date.day,
          'weekday': date.weekday,
          'workouts': 0,
        };
      });
    }
  }

  /// Get meals for a specific date (for nutrition history detail view)
  Future<List<Map<String, dynamic>>> getMealsByDate(DateTime date) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final dateStr = DateTime(date.year, date.month, date.day)
          .toIso8601String()
          .split('T')[0];

      final response = await _client
          .from('nutrition_logs')
          .select('*')
          .eq('user_id', userId)
          .eq('meal_date', dateStr)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }
}

// ===========================================================================
// Data Classes for History
// ===========================================================================

enum WorkoutStatus { completed, missed, today, future }
enum NutritionStatus { excellent, good, poor, empty, today, future }

class WorkoutDayStatus {
  final DateTime date;
  final WorkoutStatus status;
  final int? workoutCount;
  
  const WorkoutDayStatus({
    required this.date,
    required this.status,
    this.workoutCount,
  });
}

class NutritionDayStatus {
  final DateTime date;
  final NutritionStatus status;
  final double? caloriePercentage;
  
  const NutritionDayStatus({
    required this.date,
    required this.status,
    this.caloriePercentage,
  });
}
