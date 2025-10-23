// lib/models/activity_day.dart

/// Статус активности за день
enum ActivityStatus {
  completed,  // Зеленый - все выполнено (тренировка + питание)
  partial,    // Желтый - выполнено частично (только тренировка или только питание)
  missed;     // Серый - пропущено

  /// Цвет для отображения
  int get colorValue {
    switch (this) {
      case ActivityStatus.completed:
        return 0xFF4CAF50; // Green
      case ActivityStatus.partial:
        return 0xFFFFC107; // Yellow/Amber
      case ActivityStatus.missed:
        return 0xFF424242; // Gray
    }
  }
}

/// Модель дня активности
class ActivityDay {
  final DateTime date;
  final bool workoutCompleted;
  final bool nutritionGoalMet;

  ActivityDay({
    required this.date,
    this.workoutCompleted = false,
    this.nutritionGoalMet = false,
  });

  /// Статус активности на основе выполнения
  ActivityStatus get status {
    if (workoutCompleted && nutritionGoalMet) {
      return ActivityStatus.completed;
    } else if (workoutCompleted || nutritionGoalMet) {
      return ActivityStatus.partial;
    } else {
      return ActivityStatus.missed;
    }
  }

  ActivityDay copyWith({
    DateTime? date,
    bool? workoutCompleted,
    bool? nutritionGoalMet,
  }) {
    return ActivityDay(
      date: date ?? this.date,
      workoutCompleted: workoutCompleted ?? this.workoutCompleted,
      nutritionGoalMet: nutritionGoalMet ?? this.nutritionGoalMet,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'workoutCompleted': workoutCompleted,
      'nutritionGoalMet': nutritionGoalMet,
    };
  }

  factory ActivityDay.fromJson(Map<String, dynamic> json) {
    return ActivityDay(
      date: DateTime.parse(json['date'] as String),
      workoutCompleted: json['workoutCompleted'] as bool? ?? false,
      nutritionGoalMet: json['nutritionGoalMet'] as bool? ?? false,
    );
  }
}
