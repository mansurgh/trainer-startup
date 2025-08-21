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
    final encoded = Uri.encodeComponent(name.trim());
    final uri = Uri.parse('$_base/exercises/name/$encoded?limit=$limit');
    final res = await http.get(uri, headers: _headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List && data.isNotEmpty) {
        return Exercise.fromJson(Map<String, dynamic>.from(data.first as Map));
      }
      return null;
    }
    throw Exception(
        'ExerciseDB /name failed: ${res.statusCode} ${res.body.substring(0, res.body.length > 200 ? 200 : res.body.length)}');
  }

  /// По ID (на будущее)
  Future<Exercise?> getById(String id) async {
    final uri = Uri.parse('$_base/exercises/exercise/$id');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return Exercise.fromJson(data);
      if (data is Map) return Exercise.fromJson(Map<String, dynamic>.from(data));
      return null;
    }
    throw Exception('ExerciseDB /exercise/$id failed: ${res.statusCode}');
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
