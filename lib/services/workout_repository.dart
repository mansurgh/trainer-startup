import '../models/workout_day.dart';
import '../models/exercise.dart';
import '../models/muscle_group.dart';

class WorkoutRepository {
  Future<List<WorkoutDay>> getWeekPlan(DateTime startOfWeek) async {
    // Имитация задержки API
    await Future.delayed(const Duration(milliseconds: 300));
    
    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return _getWorkoutForDay(date, index);
    });
  }

  Future<WorkoutDay> getDay(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final dayIndex = date.weekday - 1;
    return _getWorkoutForDay(date, dayIndex);
  }

  Future<void> updateDay(WorkoutDay day) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // В реальном приложении здесь была бы отправка данных на сервер
  }

  WorkoutDay _getWorkoutForDay(DateTime date, int dayIndex) {
    switch (dayIndex) {
      case 0: // Monday - Upper Body
        return WorkoutDay(
          date: date,
          targetGroups: [MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.arms],
          exercises: [
            Exercise(
              id: 'm1_1',
              name: 'bench press',
              group: MuscleGroup.chest,
              sets: 4,
              reps: 12,
              completedSets: 2,
            ),
            Exercise(
              id: 'm1_2',
              name: 'shoulder press',
              group: MuscleGroup.shoulders,
              sets: 3,
              reps: 10,
              completedSets: 0,
            ),
            Exercise(
              id: 'm1_3',
              name: 'curl',
              group: MuscleGroup.arms,
              sets: 3,
              reps: 15,
              completedSets: 3,
            ),
            Exercise(
              id: 'm1_4',
              name: 'dip',
              group: MuscleGroup.arms,
              sets: 3,
              reps: 12,
              completedSets: 1,
            ),
          ],
        );

      case 1: // Tuesday - Back & Core
        return WorkoutDay(
          date: date,
          targetGroups: [MuscleGroup.back, MuscleGroup.core],
          exercises: [
            Exercise(
              id: 't1_1',
              name: 'pull-up',
              group: MuscleGroup.back,
              sets: 4,
              reps: 12,
              completedSets: 1,
            ),
            Exercise(
              id: 't1_2',
              name: 'row',
              group: MuscleGroup.back,
              sets: 3,
              reps: 10,
              completedSets: 0,
            ),
            Exercise(
              id: 't1_3',
              name: 'plank',
              group: MuscleGroup.core,
              sets: 3,
              reps: 60, // seconds
              completedSets: 2,
            ),
            Exercise(
              id: 't1_4',
              name: 'crunch',
              group: MuscleGroup.core,
              sets: 3,
              reps: 20,
              completedSets: 0,
            ),
          ],
        );

      case 2: // Wednesday - Lower Body
        return WorkoutDay(
          date: date,
          targetGroups: [MuscleGroup.legs],
          exercises: [
            Exercise(
              id: 'w1_1',
              name: 'squat',
              group: MuscleGroup.legs,
              sets: 4,
              reps: 15,
              completedSets: 0,
            ),
            Exercise(
              id: 'w1_2',
              name: 'deadlift',
              group: MuscleGroup.legs,
              sets: 3,
              reps: 12,
              completedSets: 0,
            ),
            Exercise(
              id: 'w1_3',
              name: 'lunge',
              group: MuscleGroup.legs,
              sets: 3,
              reps: 15,
              completedSets: 0,
            ),
            Exercise(
              id: 'w1_4',
              name: 'calf raise',
              group: MuscleGroup.legs,
              sets: 4,
              reps: 20,
              completedSets: 0,
            ),
          ],
        );

      case 3: // Thursday - Upper Body
        return WorkoutDay(
          date: date,
          targetGroups: [MuscleGroup.chest, MuscleGroup.arms, MuscleGroup.shoulders],
          exercises: [
            Exercise(
              id: 'th1_1',
              name: 'press',
              group: MuscleGroup.chest,
              sets: 3,
              reps: 12,
              completedSets: 0,
            ),
            Exercise(
              id: 'th1_2',
              name: 'raise',
              group: MuscleGroup.shoulders,
              sets: 3,
              reps: 15,
              completedSets: 0,
            ),
            Exercise(
              id: 'th1_3',
              name: 'curl',
              group: MuscleGroup.arms,
              sets: 3,
              reps: 12,
              completedSets: 0,
            ),
          ],
        );

      case 4: // Friday - Back
        return WorkoutDay(
          date: date,
          targetGroups: [MuscleGroup.back],
          exercises: [
            Exercise(
              id: 'f1_1',
              name: 'pull-up',
              group: MuscleGroup.back,
              sets: 4,
              reps: 8,
              completedSets: 0,
            ),
            Exercise(
              id: 'f1_2',
              name: 'row',
              group: MuscleGroup.back,
              sets: 3,
              reps: 10,
              completedSets: 0,
            ),
            Exercise(
              id: 'f1_3',
              name: 'pull',
              group: MuscleGroup.back,
              sets: 3,
              reps: 15,
              completedSets: 0,
            ),
          ],
        );

      case 5: // Saturday - Full Body (light)
        return WorkoutDay(
          date: date,
          targetGroups: [MuscleGroup.chest, MuscleGroup.back, MuscleGroup.legs, MuscleGroup.core],
          exercises: [
            Exercise(
              id: 's1_1',
              name: 'push-up',
              group: MuscleGroup.chest,
              sets: 3,
              reps: 15,
              completedSets: 0,
            ),
            Exercise(
              id: 's1_2',
              name: 'squat',
              group: MuscleGroup.legs,
              sets: 3,
              reps: 20,
              completedSets: 0,
            ),
            Exercise(
              id: 's1_3',
              name: 'mountain climber',
              group: MuscleGroup.core,
              sets: 3,
              reps: 30,
              completedSets: 0,
            ),
          ],
        );

      case 6: // Sunday - Rest
      default:
        return WorkoutDay(
          date: date,
          targetGroups: [],
          exercises: [],
        );
    }
  }
}