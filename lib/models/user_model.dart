class UserModel {
  final String id;
  final String? name;           // <= ИМЯ
  final String? gender;         // m/f
  final int? age;
  final int? height;            // cm
  final double? weight;         // kg
  final String? goal;           // fat_loss | muscle_gain | fitness
  final String? bodyImagePath;  // локальный путь к фото

  const UserModel({
    required this.id,
    this.name,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.goal,
    this.bodyImagePath,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? gender,
    int? age,
    int? height,
    double? weight,
    String? goal,
    String? bodyImagePath,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      bodyImagePath: bodyImagePath ?? this.bodyImagePath,
    );
  }
}
