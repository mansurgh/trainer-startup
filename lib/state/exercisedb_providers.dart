import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/exercisedb_service.dart';

final exerciseDbServiceProvider = Provider<ExerciseDbService>((ref) => ExerciseDbService());

// Вернёт imageUrl (PNG/GIF) по названию упражнения
final exerciseImageByNameProvider = FutureProvider.family<String?, String>((ref, name) async {
  final svc = ref.read(exerciseDbServiceProvider);
  final list = await svc.searchByName(name, limit: 1);
  if (list.isEmpty) return null;
  return list.first.imageUrl;
});

// Пример: присед
final squatImageProvider = FutureProvider<String?>((ref) async {
  return ref.watch(exerciseImageByNameProvider('barbell squat').future);
});
