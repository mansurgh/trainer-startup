import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutSettingsState {
  final int workTime;
  final int restTime;

  WorkoutSettingsState({
    this.workTime = 60,
    this.restTime = 30,
  });

  WorkoutSettingsState copyWith({
    int? workTime,
    int? restTime,
  }) {
    return WorkoutSettingsState(
      workTime: workTime ?? this.workTime,
      restTime: restTime ?? this.restTime,
    );
  }
}

class WorkoutSettingsNotifier extends StateNotifier<WorkoutSettingsState> {
  WorkoutSettingsNotifier() : super(WorkoutSettingsState());

  void updateSettings({int? workTime, int? restTime}) {
    state = state.copyWith(workTime: workTime, restTime: restTime);
  }
}

final workoutSettingsProvider = StateNotifierProvider<WorkoutSettingsNotifier, WorkoutSettingsState>((ref) {
  return WorkoutSettingsNotifier();
});
