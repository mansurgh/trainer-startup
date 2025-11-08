import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  static Future<Database> get database async {
    await initialize();
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'pulsefit_pro.db');
    
    // Удаляем старую базу данных если она существует
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    
    return await openDatabase(
      path,
      version: 4, // Увеличиваем версию для новых полей
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_data(
            id TEXT PRIMARY KEY,
            name TEXT,
            gender TEXT,
            age INTEGER,
            height INTEGER,
            weight REAL,
            targetWeight REAL,
            initialWeight REAL,
            goal TEXT,
            activityLevel TEXT,
            bodyImagePath TEXT,
            avatarPath TEXT,
            photoHistory TEXT,
            bodyFatPct REAL,
            musclePct REAL,
            createdAt TEXT,
            lastActive TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE user_data ADD COLUMN avatarPath TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE user_data ADD COLUMN targetWeight REAL');
          await db.execute('ALTER TABLE user_data ADD COLUMN initialWeight REAL');
          await db.execute('ALTER TABLE user_data ADD COLUMN activityLevel TEXT');
        }
      },
    );
  }

  // User methods
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userKey, jsonEncode(user.toJson()));

    final db = await database;
    
    // Конвертируем photoHistory в JSON строку для SQLite
    final userData = user.toJson();
    if (userData['photoHistory'] != null) {
      userData['photoHistory'] = jsonEncode(userData['photoHistory']);
    }
    
    await db.insert(
      'user_data',
      userData,
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
      final userData = maps.first;
      
      // Конвертируем photoHistory из JSON строки обратно в List<String>
      if (userData['photoHistory'] != null && userData['photoHistory'] is String) {
        try {
          userData['photoHistory'] = jsonDecode(userData['photoHistory']);
        } catch (e) {
          userData['photoHistory'] = null;
        }
      }
      
      return UserModel.fromJson(userData);
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

  /// Clear data for new user (keep settings, clear meals/workouts/progress)
  static Future<void> clearNewUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear user profile data but keep settings
    await prefs.remove(_userKey);
    await prefs.remove(_planKey);
    await prefs.remove(_exercisesKey);
    await prefs.remove(_progressKey);
    await prefs.remove(_sessionsKey);

    final db = await database;
    // Clear all tables for fresh start
    await db.delete('user_data');
    await db.delete('meals');
    await db.delete('meal_plans');
    await db.delete('workout_sessions');
  }

  // Clear database completely (for development)
  static Future<void> clearDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Удаляем файл базы данных
    String path = join(await getDatabasesPath(), 'pulsefit_pro.db');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Clear only photo history (for development)
  static Future<void> clearPhotoHistory() async {
    final db = await database;
    await db.update(
      'user_data',
      {'photoHistory': null, 'bodyImagePath': null},
      where: 'id IS NOT NULL',
    );
  }

  // Методы для работы с фотографиями прогресса
  static Future<String> saveProgressPhoto(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final progressDir = Directory('${directory.path}/progress_photos');
    if (!await progressDir.exists()) {
      await progressDir.create(recursive: true);
    }
    
    final fileName = 'progress_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${progressDir.path}/$fileName';
    
    await File(imagePath).copy(newPath);
    
    // Сохраняем путь в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> photos = prefs.getStringList('progress_photos') ?? [];
    photos.add(newPath);
    await prefs.setStringList('progress_photos', photos);
    
    return newPath;
  }

  static Future<List<String>> getProgressPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> photos = prefs.getStringList('progress_photos') ?? [];
    
    // Проверяем, что файлы существуют
    final existingPhotos = <String>[];
    for (final photo in photos) {
      if (await File(photo).exists()) {
        existingPhotos.add(photo);
      }
    }
    
    // Обновляем список, если некоторые файлы были удалены
    if (existingPhotos.length != photos.length) {
      await prefs.setStringList('progress_photos', existingPhotos);
    }
    
    return existingPhotos;
  }

  static Future<void> deleteProgressPhoto(String photoPath) async {
    try {
      await File(photoPath).delete();
      
      final prefs = await SharedPreferences.getInstance();
      final List<String> photos = prefs.getStringList('progress_photos') ?? [];
      photos.remove(photoPath);
      await prefs.setStringList('progress_photos', photos);
    } catch (e) {
      // Игнорируем ошибки удаления файла
    }
  }
}