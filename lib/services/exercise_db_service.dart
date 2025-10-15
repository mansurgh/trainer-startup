// lib/services/exercise_db_service.dart
import 'dart:convert';
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

  /// Первый найденный по имени (или null)
  Future<Exercise?> getByName(String name, {int limit = 1}) async {
    // Если нет ключа API, возвращаем null вместо исключения
    if (apiKey.isEmpty || apiKey == 'YOUR_RAPIDAPI_KEY') {
      return null;
    }
    
    try {
      // Преобразуем название в нижний регистр для API
      final searchName = name.trim().toLowerCase();
      final encoded = Uri.encodeComponent(searchName);
      final uri = Uri.parse('$_base/exercises/name/$encoded?limit=$limit');
      
      print('[ExerciseDB] Searching for: "$searchName" at $uri');
      final res = await http.get(uri, headers: _headers);

      print('[ExerciseDB] Response status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print('[ExerciseDB] Response data: $data');
        
        if (data is List && data.isNotEmpty) {
          return Exercise.fromJson(Map<String, dynamic>.from(data.first as Map));
        }
        print('[ExerciseDB] No exercises found for "$searchName"');
        return null;
      }
      
      // Логируем ошибку и возвращаем null вместо исключения
      print('[ExerciseDB] Request failed: ${res.statusCode} ${res.body}');
      return null;
    } catch (e) {
      print('[ExerciseDB] Exception: $e');
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
      
      print('[ExerciseDB] GetById failed: ${res.statusCode}');
      return null;
    } catch (e) {
      print('[ExerciseDB] GetById exception: $e');
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
