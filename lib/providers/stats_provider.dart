// =============================================================================
// stats_provider.dart — Riverpod Provider for User Statistics
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stats_service.dart';

/// State for user statistics
@immutable
class StatsState {
  const StatsState({
    this.streak = 0,
    this.workoutsThisMonth = 0,
    this.workoutsTarget = 20,
    this.weightChange,
    this.successDayPercentage = 10,
    this.successDayBreakdown = const {},
    this.muscleFatigue = const {},
    this.characteristics = const {},
    this.isLoading = false,
    this.lastUpdated,
  });

  final int streak;
  final int workoutsThisMonth;
  final int workoutsTarget;
  final double? weightChange;
  final int successDayPercentage;
  final Map<String, int> successDayBreakdown;
  final Map<String, double> muscleFatigue;
  final Map<String, double> characteristics;
  final bool isLoading;
  final DateTime? lastUpdated;

  StatsState copyWith({
    int? streak,
    int? workoutsThisMonth,
    int? workoutsTarget,
    double? weightChange,
    int? successDayPercentage,
    Map<String, int>? successDayBreakdown,
    Map<String, double>? muscleFatigue,
    Map<String, double>? characteristics,
    bool? isLoading,
    DateTime? lastUpdated,
    bool clearWeightChange = false,
  }) {
    return StatsState(
      streak: streak ?? this.streak,
      workoutsThisMonth: workoutsThisMonth ?? this.workoutsThisMonth,
      workoutsTarget: workoutsTarget ?? this.workoutsTarget,
      weightChange: clearWeightChange ? null : (weightChange ?? this.weightChange),
      successDayPercentage: successDayPercentage ?? this.successDayPercentage,
      successDayBreakdown: successDayBreakdown ?? this.successDayBreakdown,
      muscleFatigue: muscleFatigue ?? this.muscleFatigue,
      characteristics: characteristics ?? this.characteristics,
      isLoading: isLoading ?? this.isLoading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier for user statistics
class StatsNotifier extends StateNotifier<StatsState> {
  StatsNotifier() : super(const StatsState()) {
    loadStats();
  }

  final StatsService _statsService = StatsService();

  /// Load all statistics from Supabase
  Future<void> loadStats() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      // Fetch all stats in parallel
      final results = await Future.wait([
        _statsService.getSuccessDayStats(),
        _statsService.getWorkoutsThisMonth(),
        _statsService.getMonthlyWorkoutTarget(),
        _statsService.getWeightChange(),
        _statsService.getMuscleFatigue(),
        _statsService.getCharacteristics(),
      ]);

      final successDayData = results[0] as Map<String, dynamic>;
      final workoutsThisMonth = results[1] as int;
      final workoutsTarget = results[2] as int;
      final weightChange = results[3] as double?;
      final muscleFatigue = results[4] as Map<String, double>;
      final characteristics = results[5] as Map<String, double>;

      state = state.copyWith(
        streak: successDayData['streak'] as int? ?? 0,
        workoutsThisMonth: workoutsThisMonth,
        workoutsTarget: workoutsTarget,
        weightChange: weightChange,
        successDayPercentage: successDayData['percentage'] as int? ?? 10,
        successDayBreakdown: Map<String, int>.from(successDayData['breakdown'] ?? {}),
        muscleFatigue: muscleFatigue,
        characteristics: characteristics,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Refresh statistics
  Future<void> refresh() async {
    await loadStats();
  }

  /// Get formatted weight change string
  String getWeightChangeText() {
    if (state.weightChange == null) return '—';
    final change = state.weightChange!;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}';
  }

  /// Check if weight change is positive (for goal tracking)
  /// Positive = weight loss for those who want to lose, weight gain for those who want to gain
  bool isWeightChangePositive(String? goal) {
    if (state.weightChange == null) return false;
    final change = state.weightChange!;
    
    if (goal == 'lose_weight') {
      return change < 0; // Losing weight is positive
    } else if (goal == 'gain_muscle') {
      return change > 0; // Gaining weight is positive
    }
    return change <= 0; // Default: maintaining or losing
  }
}

/// Provider for user statistics
final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier();
});
