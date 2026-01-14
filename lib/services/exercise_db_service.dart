// lib/services/exercise_db_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';

/// ExerciseDB v2.2 (RapidAPI).
/// - По имени:   GET /exercises/name/{name}
/// - По ID:      GET /exercises/exercise/{id}
/// - GIF stream: GET /image?exerciseId=...&resolution=...
///
/// На free-плане доступно resolution=180.
/// Ключ: X-RapidAPI-Key (заголовок) или ?rapidapi-key=... (query для /image).
class ExerciseDbService {
  ExerciseDbService({required this.apiKey});

  final String apiKey;
  static const String _base = 'https://exercisedb.p.rapidapi.com';

  Map<String, String> get _headers => {
        if (apiKey.isNotEmpty) 'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
      };

  /// Маппинг популярных названий упражнений к названиям в ExerciseDB
  static const Map<String, String> _exerciseNameMapping = {
    // Chest
    'cable fly': 'cable fly',
    'cable flyes': 'cable fly',
    'dip': 'chest dip',
    'dips': 'chest dip',
    'bench press': 'barbell bench press',
    'push up': 'push-up',
    'push ups': 'push-up',
    'pushup': 'push-up',
    'incline press': 'incline dumbbell press',
    'decline press': 'decline dumbbell press',
    
    // Back
    'pull up': 'pull-up',
    'pull ups': 'pull-up',
    'pullup': 'pull-up',
    'barbell row': 'barbell bent over row',
    'bent over row': 'barbell bent over row',
    'lat pulldown': 'cable lat pulldown',
    'deadlift': 'barbell deadlift',
    'deadlifts': 'barbell deadlift',
    't-bar row': 't-bar row',
    'seated row': 'cable seated row',
    
    // Shoulders
    'shoulder press': 'dumbbell shoulder press',
    'overhead press': 'barbell overhead press',
    'lateral raise': 'dumbbell lateral raise',
    'front raise': 'dumbbell front raise',
    'face pull': 'cable rear delt fly',
    'rear delt fly': 'cable rear delt fly',
    'shrug': 'dumbbell shrug',
    'shrugs': 'dumbbell shrug',
    
    // Arms
    'bicep curl': 'dumbbell curl',
    'biceps curl': 'dumbbell curl',
    'hammer curl': 'dumbbell hammer curl',
    'preacher curl': 'ez-bar preacher curl',
    'tricep extension': 'cable triceps pushdown',
    'triceps extension': 'cable triceps pushdown',
    'overhead extension': 'dumbbell overhead triceps extension',
    'skull crusher': 'barbell lying triceps extension',
    'close grip press': 'close-grip barbell bench press',
    
    // Legs
    'squat': 'barbell squat',
    'squats': 'barbell squat',
    'front squat': 'barbell front squat',
    'leg press': 'sled leg press',
    'leg curl': 'lying leg curl',
    'leg extension': 'leg extension',
    'lunge': 'dumbbell lunge',
    'lunges': 'dumbbell lunge',
    'bulgarian split squat': 'bulgarian split squat',
    'romanian deadlift': 'barbell romanian deadlift',
    'calf raise': 'standing calf raise',
    'seated calf raise': 'seated calf raise',
    
    // Core
    'plank': 'front plank',
    'side plank': 'side plank',
    'crunch': 'crunch',
    'crunches': 'crunch',
    'sit up': 'sit-up',
    'sit ups': 'sit-up',
    'russian twist': 'russian twist',
    'leg raise': 'hanging leg raise',
    'hanging leg raise': 'hanging leg raise',
    
    // Common variations
    'barbell': 'barbell',
    'dumbbell': 'dumbbell',
    'cable': 'cable',
    'smith machine': 'smith',
  };
  
  /// Первый найденный по имени (или null)
  Future<Exercise?> getByName(String name, {int limit = 1}) async {
    // Если нет ключа API, возвращаем null вместо исключения
    if (apiKey.isEmpty || apiKey == 'YOUR_RAPIDAPI_KEY') {
      return null;
    }
    
    try {
      // Преобразуем название в нижний регистр для API
      var searchName = name.trim().toLowerCase();
      
      // Используем маппинг если название есть в словаре
      searchName = _exerciseNameMapping[searchName] ?? searchName;
      
      final encoded = Uri.encodeComponent(searchName);
      final uri = Uri.parse('$_base/exercises/name/$encoded?limit=$limit');
      
      if (kDebugMode) print('[ExerciseDB] Searching for: "$searchName" at $uri');
      final res = await http.get(uri, headers: _headers);

      if (kDebugMode) print('[ExerciseDB] Response status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (kDebugMode) print('[ExerciseDB] Response data: $data');
        
        if (data is List && data.isNotEmpty) {
          return Exercise.fromJson(Map<String, dynamic>.from(data.first as Map));
        }
        
        // Fallback: try search by first word only
        if (searchName.contains(' ')) {
          final firstWord = searchName.split(' ').first;
          if (kDebugMode) print('[ExerciseDB] Fallback search with first word: "$firstWord"');
          final fallbackUri = Uri.parse('$_base/exercises/name/${Uri.encodeComponent(firstWord)}?limit=$limit');
          final fallbackRes = await http.get(fallbackUri, headers: _headers);
          
          if (fallbackRes.statusCode == 200) {
            final fallbackData = jsonDecode(fallbackRes.body);
            if (fallbackData is List && fallbackData.isNotEmpty) {
              if (kDebugMode) print('[ExerciseDB] Fallback found: ${fallbackData.first}');
              return Exercise.fromJson(Map<String, dynamic>.from(fallbackData.first as Map));
            }
          }
        }
        
        if (kDebugMode) print('[ExerciseDB] No exercises found for "$searchName"');
        return null;
      }
      
      // Логируем ошибку и возвращаем null вместо исключения
      if (kDebugMode) print('[ExerciseDB] Request failed: ${res.statusCode} ${res.body}');
      return null;
    } catch (e) {
      if (kDebugMode) print('[ExerciseDB] Exception: $e');
      return null;
    }
  }

  /// По ID (на будущее)
  Future<Exercise?> getById(String id) async {
    // Если нет ключа API, возвращаем null
    if (apiKey.isEmpty || apiKey == 'YOUR_RAPIDAPI_KEY') {
      return null;
    }
    
    try {
      final uri = Uri.parse('$_base/exercises/exercise/$id');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return Exercise.fromJson(data);
        if (data is Map) return Exercise.fromJson(Map<String, dynamic>.from(data));
        return null;
      }
      
      if (kDebugMode) print('[ExerciseDB] GetById failed: ${res.statusCode}');
      return null;
    } catch (e) {
      if (kDebugMode) print('[ExerciseDB] GetById exception: $e');
      return null;
    }
  }

  /// Прямой потоковый URL для Image.network/CachedNetworkImage
  String buildGifUrl({
    required String exerciseId,
    String resolution = '180',
    bool keyInQuery = true,
  }) {
    final base = '$_base/image?exerciseId=$exerciseId&resolution=$resolution';
    return keyInQuery ? '$base&rapidapi-key=$apiKey' : base;
  }
}
