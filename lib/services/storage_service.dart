import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/daily_plan_model.dart';
import '../models/exercise.dart';

class StorageService {
  static const String _userKey = 'currentUser';
  static const String _planKey = 'workoutPlan';
  static const String _exercisesKey = 'exercises';
  static const String _progressKey = 'progressHistory';
  static const String _sessionsKey = 'workoutSessions';
  static const String _settingsKey = 'appSettings';
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'pulsefit_pro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_data(
            id TEXT PRIMARY KEY,
            name TEXT,
            gender TEXT,
            age INTEGER,
            height INTEGER,
            weight REAL,
            goal TEXT,
            bodyImagePath TEXT,
            bodyFatPct REAL,
            musclePct REAL,
            createdAt TEXT,
            lastActive TEXT
          )
        ''');
      },
    );
  }

  // User methods
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userKey, jsonEncode(user.toJson()));

    final db = await database;
    await db.insert(
      'user_data',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_data');
    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    }
    return null;
  }
  
  // Workout plan methods
  static Future<void> saveWorkoutPlan(DailyPlanModel plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planKey, jsonEncode({
      'id': plan.id,
      'userId': plan.userId,
      'date': plan.date.toIso8601String(),
      'workoutDone': plan.workoutDone,
      'proteinLeft': plan.proteinLeft,
      'supplementsLeft': plan.supplementsLeft,
      'targetProtein': plan.targetProtein,
      'targetSupplements': plan.targetSupplements,
    }));
  }
  
  static Future<DailyPlanModel?> getWorkoutPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final planData = prefs.getString(_planKey);
    if (planData == null) return null;
    
    final Map<String, dynamic> data = jsonDecode(planData);
    return DailyPlanModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      date: DateTime.parse(data['date']),
      workoutDone: data['workoutDone'] ?? false,
      proteinLeft: data['proteinLeft'] ?? 0,
      supplementsLeft: List<String>.from(data['supplementsLeft'] ?? []),
      targetProtein: data['targetProtein'] ?? 120,
      targetSupplements: List<String>.from(data['targetSupplements'] ?? []),
    );
  }
  
  // Exercise methods
  static Future<void> saveExercises(List<Exercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesData = exercises.map((e) => {
      'id': e.id,
      'name': e.name,
      'videoUrl': e.videoUrl,
      'imageUrl': e.imageUrl,
      'gifUrl': e.gifUrl,
    }).toList();
    await prefs.setString(_exercisesKey, jsonEncode(exercisesData));
  }
  
  static Future<List<Exercise>> getExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesData = prefs.getString(_exercisesKey);
    if (exercisesData == null) return [];
    
    final List<dynamic> data = jsonDecode(exercisesData);
    return data.map((e) => Exercise(
      id: e['id'] ?? '',
      name: e['name'] ?? '',
      videoUrl: e['videoUrl'],
      imageUrl: e['imageUrl'],
      gifUrl: e['gifUrl'],
    )).toList();
  }

  // Progress tracking methods
  static Future<void> saveProgress({
    required DateTime date,
    required double weight,
    required double bodyFat,
    required double muscleMass,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = prefs.getStringList(_progressKey) ?? [];
    
    final entry = {
      'date': date.toIso8601String(),
      'weight': weight,
      'body_fat': bodyFat,
      'muscle_mass': muscleMass,
      'notes': notes ?? '',
    };
    
    progressData.add(jsonEncode(entry));
    await prefs.setStringList(_progressKey, progressData);
  }

  static Future<List<Map<String, dynamic>>> getProgressHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = prefs.getStringList(_progressKey) ?? [];
    
    return progressData.map((entry) => jsonDecode(entry) as Map<String, dynamic>).toList();
  }

  // Workout session methods
  static Future<void> saveWorkoutSession({
    required DateTime date,
    required String exerciseName,
    required int sets,
    required int reps,
    required double weight,
    required int duration,
    required bool completed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsData = prefs.getStringList(_sessionsKey) ?? [];
    
    final session = {
      'date': date.toIso8601String(),
      'exercise_name': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'completed': completed ? 1 : 0,
    };
    
    sessionsData.add(jsonEncode(session));
    await prefs.setStringList(_sessionsKey, sessionsData);
  }

  static Future<List<Map<String, dynamic>>> getWorkoutSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsData = prefs.getStringList(_sessionsKey) ?? [];
    
    return sessionsData.map((session) => jsonDecode(session) as Map<String, dynamic>).toList();
  }

  // Settings methods
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsData = prefs.getString(_settingsKey);
    if (settingsData == null) return {};
    
    return Map<String, dynamic>.from(jsonDecode(settingsData));
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_planKey);
    await prefs.remove(_exercisesKey);
    await prefs.remove(_progressKey);
    await prefs.remove(_sessionsKey);
    await prefs.remove(_settingsKey);

    final db = await database;
    await db.delete('user_data');
  }
}