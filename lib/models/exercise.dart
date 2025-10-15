// lib/models/exercise.dart
import 'muscle_group.dart';

class Exercise {
  final String id;
  final String name;
  final String? imageUrl;
  final String? gifUrl;
  final String? videoUrl;
  final MuscleGroup? group;
  final int sets;
  final int reps;
  final int completedSets;

  Exercise({
    required this.id,
    required this.name,
    this.imageUrl,
    this.gifUrl,
    this.videoUrl,
    this.group,
    this.sets = 0,
    this.reps = 0,
    this.completedSets = 0,
  });

  double get progress => sets == 0 ? 0 : completedSets / sets;

  factory Exercise.fromJson(Map<String, dynamic> m) {
    return Exercise(
      id: (m['id'] ?? m['exerciseId'] ?? m['exercise_id'] ?? '').toString(),
      name: (m['name'] ?? '').toString(),
      imageUrl: (m['imageUrl'] ?? m['image'] ?? m['thumbnail'])?.toString(),
      gifUrl: (m['gifUrl'] ?? m['gif'])?.toString(),
      videoUrl: (m['videoUrl'] ?? m['video'])?.toString(),
      sets: m['sets'] ?? 0,
      reps: m['reps'] ?? 0,
      completedSets: m['completedSets'] ?? 0,
    );
  }

  Exercise copyWith({
    String? gifUrl, 
    String? imageUrl, 
    String? videoUrl,
    MuscleGroup? group,
    int? sets,
    int? reps,
    int? completedSets,
  }) {
    return Exercise(
      id: id,
      name: name,
      imageUrl: imageUrl ?? this.imageUrl,
      gifUrl: gifUrl ?? this.gifUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      group: group ?? this.group,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      completedSets: completedSets ?? this.completedSets,
    );
  }
}
