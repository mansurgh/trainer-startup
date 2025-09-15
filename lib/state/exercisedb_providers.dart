// lib/state/exercisedb_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/exercise.dart';
import '../services/exercise_db_service.dart';

/// Ключ берём из .env файла или --dart-define=RAPIDAPI_KEY=...
String get _rapidApiKey {
  try {
    return dotenv.env['RAPIDAPI_KEY'] ?? 
           const String.fromEnvironment('RAPIDAPI_KEY', defaultValue: 'demo-key');
  } catch (e) {
    return const String.fromEnvironment('RAPIDAPI_KEY', defaultValue: 'demo-key');
  }
}

final exerciseDbServiceProvider = Provider<ExerciseDbService>((ref) {
  return ExerciseDbService(apiKey: _rapidApiKey);
});

/// Упражнение по имени + сразу формируем gifUrl через /image (stream)
final exerciseByNameProvider =
    FutureProvider.family<Exercise?, String>((ref, name) async {
  final api = ref.read(exerciseDbServiceProvider);
  final ex = await api.getByName(name);
  if (ex == null) return null;

  if ((ex.gifUrl == null || ex.gifUrl!.isEmpty) && ex.id.isNotEmpty) {
    final gif = api.buildGifUrl(
      exerciseId: ex.id,
      resolution: '180',
      keyInQuery: true, // ключ в query — удобно для прямой подстановки
    );
    return ex.copyWith(gifUrl: gif);
  }
  return ex;
});
