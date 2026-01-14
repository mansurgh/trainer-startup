// =============================================================================
// muscle_fatigue_provider.dart — Riverpod State for Muscle Fatigue
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/muscle_heatmap/muscle_heatmap_widget.dart';

// =============================================================================
// STATE MODEL
// =============================================================================

/// Immutable state container for muscle fatigue data
class MuscleFatigueState {
  const MuscleFatigueState({
    this.fatigueMap = const {},
    this.lastUpdated,
    this.isLoading = false,
    this.error,
  });

  /// Map of muscle ID to fatigue level (0.0-1.0)
  final Map<MuscleId, double> fatigueMap;
  
  /// When fatigue data was last updated
  final DateTime? lastUpdated;
  
  /// Loading state
  final bool isLoading;
  
  /// Error message if loading failed
  final String? error;

  /// Check if we have any fatigue data
  bool get hasData => fatigueMap.isNotEmpty;

  /// Calculate overall body fatigue (average of all muscles)
  double get overallFatigue {
    if (fatigueMap.isEmpty) return 0.0;
    final total = fatigueMap.values.reduce((a, b) => a + b);
    return total / fatigueMap.length;
  }

  /// Get list of muscles that need rest (fatigue > 0.7)
  List<MuscleId> get tiredMuscles {
    return fatigueMap.entries
        .where((e) => e.value > 0.7)
        .map((e) => e.key)
        .toList();
  }

  /// Get list of fresh muscles ready for training (fatigue < 0.3)
  List<MuscleId> get freshMuscles {
    return fatigueMap.entries
        .where((e) => e.value < 0.3)
        .map((e) => e.key)
        .toList();
  }

  MuscleFatigueState copyWith({
    Map<MuscleId, double>? fatigueMap,
    DateTime? lastUpdated,
    bool? isLoading,
    String? error,
  }) {
    return MuscleFatigueState(
      fatigueMap: fatigueMap ?? this.fatigueMap,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// =============================================================================
// NOTIFIER
// =============================================================================

/// StateNotifier for muscle fatigue management.
/// 
/// Tracks muscle fatigue levels based on:
/// - Recent workout sessions
/// - Exercise intensity and volume
/// - Recovery time (muscle-specific)
class MuscleFatigueNotifier extends StateNotifier<MuscleFatigueState> {
  MuscleFatigueNotifier() : super(const MuscleFatigueState());

  /// Load fatigue data from workout history.
  /// In production, this would calculate from actual workout logs.
  Future<void> loadFromWorkoutHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Integrate with UserRepository to get workout history
      // For now, use sample data for demonstration
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        fatigueMap: generateSampleFatigueMap(),
        lastUpdated: DateTime.now(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update fatigue for a specific muscle.
  /// 
  /// [muscleId] - Target muscle
  /// [fatigue] - New fatigue level (0.0-1.0)
  void updateMuscleFatigue(MuscleId muscleId, double fatigue) {
    final newMap = Map<MuscleId, double>.from(state.fatigueMap);
    newMap[muscleId] = fatigue.clamp(0.0, 1.0);
    
    state = state.copyWith(
      fatigueMap: newMap,
      lastUpdated: DateTime.now(),
    );
  }

  /// Apply fatigue from a completed workout.
  /// 
  /// [trainedMuscles] - Muscles worked during the session
  /// [intensity] - Workout intensity (0.0-1.0)
  void applyWorkoutFatigue({
    required List<MuscleId> trainedMuscles,
    double intensity = 0.7,
  }) {
    final newMap = Map<MuscleId, double>.from(state.fatigueMap);
    
    for (final muscle in trainedMuscles) {
      final current = newMap[muscle] ?? 0.0;
      // Add fatigue based on intensity, cap at 1.0
      newMap[muscle] = (current + intensity * 0.5).clamp(0.0, 1.0);
    }
    
    state = state.copyWith(
      fatigueMap: newMap,
      lastUpdated: DateTime.now(),
    );
  }

  /// Simulate recovery over time.
  /// Reduces fatigue based on hours passed since last workout.
  void applyRecovery({int hoursPassed = 24}) {
    final newMap = Map<MuscleId, double>.from(state.fatigueMap);
    
    for (final entry in newMap.entries) {
      final muscleInfo = MuscleDefinitions.defaults[entry.key];
      if (muscleInfo != null) {
        // Recovery rate: ~10% per 8 hours of the muscle's recovery time
        final recoveryRate = hoursPassed / muscleInfo.recoveryHours;
        newMap[entry.key] = (entry.value - recoveryRate * 0.3).clamp(0.0, 1.0);
      }
    }
    
    state = state.copyWith(
      fatigueMap: newMap,
      lastUpdated: DateTime.now(),
    );
  }

  /// Reset all muscle fatigue to fresh (0.0)
  void resetAllFatigue() {
    final freshMap = <MuscleId, double>{};
    for (final muscle in MuscleId.values) {
      freshMap[muscle] = 0.0;
    }
    
    state = state.copyWith(
      fatigueMap: freshMap,
      lastUpdated: DateTime.now(),
    );
  }

  /// Clear all data
  void clear() {
    state = const MuscleFatigueState();
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Main provider for muscle fatigue state
final muscleFatigueProvider =
    StateNotifierProvider<MuscleFatigueNotifier, MuscleFatigueState>(
  (ref) => MuscleFatigueNotifier(),
);

/// Shortcut provider for just the fatigue map
final fatigueMapProvider = Provider<Map<MuscleId, double>>((ref) {
  return ref.watch(muscleFatigueProvider).fatigueMap;
});

/// Provider for overall body fatigue percentage
final overallFatigueProvider = Provider<double>((ref) {
  return ref.watch(muscleFatigueProvider).overallFatigue;
});

/// Provider for muscles needing rest
final tiredMusclesProvider = Provider<List<MuscleId>>((ref) {
  return ref.watch(muscleFatigueProvider).tiredMuscles;
});

/// Provider for fresh/ready muscles
final freshMusclesProvider = Provider<List<MuscleId>>((ref) {
  return ref.watch(muscleFatigueProvider).freshMuscles;
});
