import 'exercise.dart';
import 'muscle_group.dart';

class WorkoutDay {
  final DateTime date;
  final List<MuscleGroup> targetGroups;
  final List<Exercise> exercises;
  final bool isFrontView;

  const WorkoutDay({
    required this.date,
    required this.targetGroups,
    required this.exercises,
    this.isFrontView = true,
  });

  String get title {
    if (exercises.isEmpty) return "Rest";
    
    if (targetGroups.contains(MuscleGroup.legs)) return "Lower Body";
    if (targetGroups.contains(MuscleGroup.chest) ||
        targetGroups.contains(MuscleGroup.shoulders) ||
        targetGroups.contains(MuscleGroup.arms)) return "Upper Body";
    if (targetGroups.contains(MuscleGroup.back) && 
        targetGroups.contains(MuscleGroup.core)) return "Back & Core";
    if (targetGroups.length >= 4) return "Full Body";
    return "Workout";
  }

  WorkoutDay copyWith({
    DateTime? date,
    List<MuscleGroup>? targetGroups,
    List<Exercise>? exercises,
    bool? isFrontView,
  }) {
    return WorkoutDay(
      date: date ?? this.date,
      targetGroups: targetGroups ?? this.targetGroups,
      exercises: exercises ?? this.exercises,
      isFrontView: isFrontView ?? this.isFrontView,
    );
  }
}