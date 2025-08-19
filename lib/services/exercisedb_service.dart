import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/exercise.dart';

class ExerciseDbService {
  final _base = 'https://exercisedb.p.rapidapi.com';
  Map<String, String> get _headers => {
        'X-RapidAPI-Key': dotenv.env['RAPIDAPI_KEY'] ?? '',
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
      };

  Future<List<Exercise>> searchByName(String query, {int limit = 5}) async {
    final uri = Uri.parse('$_base/search?query=${Uri.encodeQueryComponent(query)}');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('ExerciseDB error: ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body);
    if (data is! List) return [];
    final list = data.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
    return (limit > 0 && list.length > limit) ? list.take(limit).toList() : list;
  }

  Future<Exercise?> getById(String id) async {
    final uri = Uri.parse('$_base/exercises/id/${Uri.encodeComponent(id)}');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body);
    if (data is List && data.isNotEmpty) {
      return Exercise.fromJson(data.first as Map<String, dynamic>);
    } else if (data is Map<String, dynamic>) {
      return Exercise.fromJson(data);
    }
    return null;
  }
}
