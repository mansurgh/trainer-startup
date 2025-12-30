import 'dart:io' show File;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Service for fetching user statistics from Supabase
/// Silent mode - no debug logs to reduce console spam
class StatsService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get user's current streak (consecutive days of activity)
  Future<int> getStreak() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final now = DateTime.now();
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));

      final workoutsResponse = await _client
          .from('workout_sessions')
          .select('workout_date')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .gte('workout_date', ninetyDaysAgo.toIso8601String().split('T')[0])
          .order('workout_date', ascending: false);

      final nutritionResponse = await _client
          .from('nutrition_logs')
          .select('meal_date')
          .eq('user_id', userId)
          .gte('meal_date', ninetyDaysAgo.toIso8601String().split('T')[0])
          .order('meal_date', ascending: false);

      final Set<String> activeDates = {};
      
      for (final row in workoutsResponse) {
        activeDates.add(row['workout_date'].toString().split('T')[0]);
      }
      for (final row in nutritionResponse) {
        activeDates.add(row['meal_date'].toString().split('T')[0]);
      }

      if (activeDates.isEmpty) return 0;

      int streak = 0;
      DateTime checkDate = DateTime(now.year, now.month, now.day);
      
      String todayStr = checkDate.toIso8601String().split('T')[0];
      if (!activeDates.contains(todayStr)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      while (true) {
        final dateStr = checkDate.toIso8601String().split('T')[0];
        if (activeDates.contains(dateStr)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streak;
    } catch (_) {
      return 0;
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

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final latestResponse = await _client
          .from('body_measurements')
          .select('weight, measurement_date')
          .eq('user_id', userId)
          .not('weight', 'is', null)
          .order('measurement_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (latestResponse == null || latestResponse['weight'] == null) {
        return null;
      }

      final currentWeight = (latestResponse['weight'] as num).toDouble();

      final oldResponse = await _client
          .from('body_measurements')
          .select('weight, measurement_date')
          .eq('user_id', userId)
          .not('weight', 'is', null)
          .lte('measurement_date', thirtyDaysAgo.toIso8601String().split('T')[0])
          .order('measurement_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (oldResponse == null || oldResponse['weight'] == null) {
        final profileResponse = await _client
            .from('profiles')
            .select('weight')
            .eq('id', userId)
            .maybeSingle();
        
        if (profileResponse != null && profileResponse['weight'] != null) {
          final initialWeight = (profileResponse['weight'] as num).toDouble();
          return currentWeight - initialWeight;
        }
        return null;
      }

      final oldWeight = (oldResponse['weight'] as num).toDouble();
      return currentWeight - oldWeight;
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
  Future<Map<String, double>> getCharacteristics() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return _getDefaultCharacteristics();

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      // 1. DISCIPLINE
      final streak = await getStreak();
      final workoutsThisMonth = await getWorkoutsThisMonth();
      
      final streakScore = (streak / 30 * 50).clamp(0.0, 50.0);
      final regularityScore = (workoutsThisMonth / 20 * 50).clamp(0.0, 50.0);
      final discipline = (streakScore + regularityScore).clamp(0.0, 100.0);

      // 2. NUTRITION
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

      // 3. STRENGTH
      final strengthResponse = await _client
          .from('exercise_logs')
          .select('weight, sets, reps')
          .eq('user_id', userId)
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .not('weight', 'is', null);

      double totalVolume = 0;
      for (final log in strengthResponse) {
        final sets = (log['sets'] as int?) ?? 1;
        final reps = (log['reps'] as int?) ?? 10;
        final weight = (log['weight'] as num?)?.toDouble() ?? 0;
        totalVolume += sets * reps * weight;
      }
      final strength = (totalVolume / 50000 * 100).clamp(0.0, 100.0);

      // 4. ENDURANCE
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

      // 5. BALANCE
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
    return {
      'discipline': 10.0,
      'nutrition': 10.0,
      'strength': 10.0,
      'endurance': 10.0,
      'balance': 10.0,
    };
  }
}
