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
  
  // Additional fields from ExerciseDB API
  final String? target;
  final String? bodyPart;
  final String? equipment;
  final List<String>? secondaryMuscles;
  final List<String>? instructions;

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
    this.target,
    this.bodyPart,
    this.equipment,
    this.secondaryMuscles,
    this.instructions,
  });

  double get progress => sets == 0 ? 0 : completedSets / sets;

  factory Exercise.fromJson(Map<String, dynamic> m) {
    // Parse instructions which can be a list or null
    List<String>? instructions;
    if (m['instructions'] != null) {
      if (m['instructions'] is List) {
        instructions = (m['instructions'] as List).map((e) => e.toString()).toList();
      }
    }
    
    // Parse secondary muscles
    List<String>? secondaryMuscles;
    if (m['secondaryMuscles'] != null) {
      if (m['secondaryMuscles'] is List) {
        secondaryMuscles = (m['secondaryMuscles'] as List).map((e) => e.toString()).toList();
      }
    }
    
    return Exercise(
      id: (m['id'] ?? m['exerciseId'] ?? m['exercise_id'] ?? '').toString(),
      name: (m['name'] ?? '').toString(),
      imageUrl: (m['imageUrl'] ?? m['image'] ?? m['thumbnail'])?.toString(),
      gifUrl: (m['gifUrl'] ?? m['gif'])?.toString(),
      videoUrl: (m['videoUrl'] ?? m['video'])?.toString(),
      sets: m['sets'] ?? 0,
      reps: m['reps'] ?? 0,
      completedSets: m['completedSets'] ?? 0,
      target: m['target']?.toString(),
      bodyPart: m['bodyPart']?.toString(),
      equipment: m['equipment']?.toString(),
      secondaryMuscles: secondaryMuscles,
      instructions: instructions,
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
    String? target,
    String? bodyPart,
    String? equipment,
    List<String>? secondaryMuscles,
    List<String>? instructions,
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
      target: target ?? this.target,
      bodyPart: bodyPart ?? this.bodyPart,
      equipment: equipment ?? this.equipment,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructions: instructions ?? this.instructions,
    );
  }
}
