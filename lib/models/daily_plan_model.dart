class DailyPlanModel {
  final String id;
  final String userId;
  final DateTime date;
  final bool workoutDone;
  final int proteinLeft; // grams
  final List<String> supplementsLeft;
  final int targetProtein;
  final List<String> targetSupplements;

  const DailyPlanModel({
    required this.id,
    required this.userId,
    required this.date,
    this.workoutDone = false,
    this.proteinLeft = 0,
    this.supplementsLeft = const [],
    this.targetProtein = 120,
    this.targetSupplements = const ["Vitamin D3", "Creatine"],
  });

  DailyPlanModel copyWith({
    bool? workoutDone, int? proteinLeft, List<String>? supplementsLeft,
  }) => DailyPlanModel(
    id: id, userId: userId, date: date,
    workoutDone: workoutDone ?? this.workoutDone,
    proteinLeft: proteinLeft ?? this.proteinLeft,
    supplementsLeft: supplementsLeft ?? this.supplementsLeft,
    targetProtein: targetProtein,
    targetSupplements: targetSupplements,
  );
}