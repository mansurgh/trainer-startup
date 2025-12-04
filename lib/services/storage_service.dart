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
import '../config/supabase_config.dart';

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
    
    // НЕ удаляем базу данных - сохраняем данные между запусками
    // Если нужно обновить схему, используем onUpgrade
    
    return await openDatabase(
      path,
      version: 5, // +1 для email колонки
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_data(
            id TEXT PRIMARY KEY,
            email TEXT,
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
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE user_data ADD COLUMN email TEXT');
        }
      },
    );
  }

  // User methods
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? 'anonymous';
    prefs.setString('${_userKey}_$userId', jsonEncode(user.toJson()));

    // Сохраняем в локальную SQLite БД
    final db = await database;
    final userData = user.toJson();
    if (userData['photoHistory'] != null) {
      userData['photoHistory'] = jsonEncode(userData['photoHistory']);
    }
    await db.insert(
      'user_data',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Синхронизируем с Supabase profiles таблицей
    try {
      final supabaseUser = SupabaseConfig.client.auth.currentUser;
      if (supabaseUser != null && userId != 'anonymous') {
        await SupabaseConfig.client.from('profiles').upsert({
          'id': userId,
          'email': user.email, // Added email field
          'name': user.name,
          'age': user.age,
          'height': user.height,
          'weight': user.weight,
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('[Storage] ✅ User profile synced to Supabase');
      }
    } catch (e) {
      print('[Storage] ⚠️ Failed to sync to Supabase: $e');
    }
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? 'anonymous';
    
    // Пробуем загрузить из SharedPreferences
    final userJson = prefs.getString('${_userKey}_$userId');
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }

    // Пробуем загрузить из локальной SQLite
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_data', where: 'id = ?', whereArgs: [userId]);
    if (maps.isNotEmpty) {
      final userData = maps.first;
      if (userData['photoHistory'] != null && userData['photoHistory'] is String) {
        try {
          userData['photoHistory'] = jsonDecode(userData['photoHistory']);
        } catch (e) {
          userData['photoHistory'] = null;
        }
      }
      return UserModel.fromJson(userData);
    }
    
    // Пробуем загрузить из Supabase
    try {
      final supabaseUser = SupabaseConfig.client.auth.currentUser;
      if (supabaseUser != null && userId != 'anonymous') {
        final response = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        if (response != null) {
          print('[Storage] ✅ Loaded user profile from Supabase: ${response.toString()}');
          final user = UserModel(
            id: userId,
            email: response['email'] as String?, // Populate email
            name: response['name'] as String?,
            age: response['age'] as int?,
            height: response['height'] as int?,
            weight: response['weight'] as double?,
          );
          print('[Storage] 📦 UserModel created: name=${user.name}, age=${user.age}, height=${user.height}, weight=${user.weight}');
          // Сохраняем локально для быстрого доступа
          await saveUser(user);
          return user;
        } else {
          print('[Storage] ⚠️ No profile found in Supabase for userId: $userId');
        }
      }
    } catch (e) {
      print('[Storage] ⚠️ Failed to load from Supabase: $e');
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

  // Clear all data for current user only (при выходе из аккаунта)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    
    // Очищаем только SharedPreferences для текущего пользователя
    if (userId != null) {
      await prefs.remove('${_userKey}_$userId');
      await prefs.remove('${_planKey}_$userId');
      await prefs.remove('${_exercisesKey}_$userId');
      await prefs.remove('${_progressKey}_$userId');
      await prefs.remove('${_sessionsKey}_$userId');
    }
    
    // НЕ удаляем настройки - они общие для приложения
    // НЕ удаляем данные из SQLite - они сохраняются для каждого пользователя
  }

  /// Clear data for new user (keep settings, clear meals/workouts/progress)
  static Future<void> clearNewUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear user profile data but keep settings
      await prefs.remove(_userKey);
      await prefs.remove(_planKey);
      await prefs.remove(_exercisesKey);
      await prefs.remove(_progressKey);
      await prefs.remove(_sessionsKey);
      
      // Очищаем питание и прогресс фото для нового пользователя
      await prefs.remove('progress_photos');
      
      // Очищаем все ключи, связанные с питанием
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('meal_') || 
            key.startsWith('nutrition_') || 
            key.startsWith('food_')) {
          await prefs.remove(key);
        }
      }

      final db = await database;
      // Clear only existing tables for fresh start
      try {
        await db.delete('user_data');
      } catch (e) {
        print('[Storage] Could not delete user_data: $e');
      }
      
      // Эти таблицы могут не существовать - игнорируем ошибки
      try {
        await db.delete('meals');
      } catch (e) {
        // Таблица не существует - это нормально
      }
      
      try {
        await db.delete('meal_plans');
      } catch (e) {
        // Таблица не существует - это нормально
      }
      
      try {
        await db.delete('workout_sessions');
      } catch (e) {
        // Таблица не существует - это нормально
      }
      
      print('[Storage] Cleared new user data successfully (including nutrition and progress)');
    } catch (e) {
      print('[Storage] Error clearing new user data: $e');
      rethrow;
    }
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

  /// Очистить статистику и питание для ВСЕХ пользователей (сброс данных)
  static Future<void> resetAllUsersData() async {
    try {
      print('[Storage] 🔄 Starting data reset for all users...');
      final prefs = await SharedPreferences.getInstance();
      
      // Сначала выводим ВСЕ существующие ключи для отладки
      final allKeys = prefs.getKeys().toList();
      print('[Storage] 📋 Total keys before reset: ${allKeys.length}');
      for (final key in allKeys) {
        print('[Storage]   - $key');
      }
      
      // Очищаем прогресс, статистику и питание
      await prefs.remove(_progressKey);
      await prefs.remove(_sessionsKey);
      await prefs.remove(_planKey);
      await prefs.remove('progress_photos');
      print('[Storage] ✓ Cleared standard keys');
      
      // Очищаем ВСЕ ключи, которые могут содержать данные пользователя
      int removedCount = 0;
      for (final key in allKeys) {
        // НЕ удаляем системные ключи и настройки
        if (key.startsWith('flutter.') || 
            key.startsWith('data_reset_') ||
            key == _settingsKey) {
          continue;
        }
        
        // Удаляем все остальные ключи (данные пользователя)
        if (key != _userKey) { // Сохраняем информацию о пользователе (имя, параметры)
          await prefs.remove(key);
          removedCount++;
          print('[Storage]   🗑️ Removed: $key');
        }
      }
      print('[Storage] ✓ Removed $removedCount user data keys');

      final db = await database;
      
      // Очищаем таблицы статистики (если существуют)
      int tablesCleared = 0;
      
      try {
        final count = await db.delete('meals');
        if (count > 0) {
          print('[Storage] ✓ Cleared meals table: $count rows');
          tablesCleared++;
        }
      } catch (e) {
        print('[Storage] ℹ️ meals table does not exist');
      }
      
      try {
        final count = await db.delete('meal_plans');
        if (count > 0) {
          print('[Storage] ✓ Cleared meal_plans table: $count rows');
          tablesCleared++;
        }
      } catch (e) {
        print('[Storage] ℹ️ meal_plans table does not exist');
      }
      
      try {
        final count = await db.delete('workout_sessions');
        if (count > 0) {
          print('[Storage] ✓ Cleared workout_sessions table: $count rows');
          tablesCleared++;
        }
      } catch (e) {
        print('[Storage] ℹ️ workout_sessions table does not exist');
      }
      
      print('[Storage] ✅ Data reset completed: $tablesCleared tables cleared, $removedCount keys removed');
    } catch (e) {
      print('[Storage] ❌ Error resetting all users data: $e');
      rethrow;
    }
  }

  // Миграция профилей из SQLite в Supabase
  static Future<void> migrateProfilesToSupabase() async {
    try {
      print('[Storage] 🔍 Checking for profiles in SQLite...');
      final db = await database;
      
      // Получаем все профили из локальной БД
      final List<Map<String, dynamic>> profiles = await db.query('user_data');
      print('[Storage] 📋 Found ${profiles.length} profiles in SQLite');
      
      if (profiles.isEmpty) {
        print('[Storage] ℹ️ No profiles to migrate');
        return;
      }
      
      int migrated = 0;
      int skipped = 0;
      
      for (final profile in profiles) {
        final userId = profile['id'] as String?;
        if (userId == null || userId == 'anonymous') {
          skipped++;
          continue;
        }
        
        try {
          // Проверяем есть ли уже в Supabase
          final existing = await SupabaseConfig.client
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();
          
          if (existing != null) {
            print('[Storage] ⏭️ Profile already exists in Supabase: $userId');
            skipped++;
            continue;
          }
          
          // Переносим в Supabase
          await SupabaseConfig.client.from('profiles').insert({
            'id': userId,
            'name': profile['name'],
            'age': profile['age'],
            'height': profile['height'],
            'weight': profile['weight'],
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          
          print('[Storage] ✅ Migrated profile: $userId (${profile['name'] ?? "No name"})');
          migrated++;
        } catch (e) {
          print('[Storage] ⚠️ Failed to migrate profile $userId: $e');
          skipped++;
        }
      }
      
      print('[Storage] 🎉 Migration complete: $migrated migrated, $skipped skipped');
    } catch (e) {
      print('[Storage] ❌ Error during profile migration: $e');
      rethrow;
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
      final userId = prefs.getString('user_id') ?? 'anonymous';
      await prefs.setStringList('progress_photos_$userId', existingPhotos);
    }
    
    return existingPhotos;
  }

  static Future<void> deleteProgressPhoto(String photoPath) async {
    try {
      await File(photoPath).delete();
      
      final prefs = await SharedPreferences.getInstance();
      final List<String> photos = prefs.getStringList('progress_photos') ?? [];
      photos.remove(photoPath);
      final userId = prefs.getString('user_id') ?? 'anonymous';
      await prefs.setStringList('progress_photos_$userId', photos);
    } catch (e) {
      // Игнорируем ошибки удаления файла
    }
  }
}