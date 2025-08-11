class UserModel {
  final String id;
  final String gender; // m/f/other
  final int age;
  final int height; // cm
  final double weight; // kg
  final String goal; // e.g. "muscle_gain", "fat_loss"
  final bool isPro;
  final int requestsToday;
  final DateTime? lastRequestDate;

  const UserModel({
    required this.id,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
    this.isPro = false,
    this.requestsToday = 0,
    this.lastRequestDate,
  });

  UserModel copyWith({
    String? gender, int? age, int? height, double? weight, String? goal,
    bool? isPro, int? requestsToday, DateTime? lastRequestDate,
  }) => UserModel(
    id: id,
    gender: gender ?? this.gender,
    age: age ?? this.age,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    goal: goal ?? this.goal,
    isPro: isPro ?? this.isPro,
    requestsToday: requestsToday ?? this.requestsToday,
    lastRequestDate: lastRequestDate ?? this.lastRequestDate,
  );
}