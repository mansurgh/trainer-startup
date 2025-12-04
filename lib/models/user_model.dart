class UserModel {
  final String id;
  final String? email;          // EMAIL
  final String? name;           // <= ИМЯ
  final String? gender;         // m/f
  final int? age;
  final int? height;            // cm
  final double? weight;         // kg
  final double? targetWeight;   // целевой вес
  final double? initialWeight;  // начальный вес
  final String? goal;           // fat_loss | muscle_gain | fitness
  final String? activityLevel;  // low | medium | high
  final String? bodyImagePath;  // локальный путь к фото
  final String? avatarPath;     // путь к аватарке
  final List<String>? photoHistory; // история фотографий для отслеживания прогресса
  final double? bodyFatPct;     // процент жира
  final double? musclePct;      // процент мышц
  final DateTime? createdAt;    // дата создания профиля
  final DateTime? lastActive;   // последняя активность

  const UserModel({
    required this.id,
    this.email,
    this.name,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.targetWeight,
    this.initialWeight,
    this.goal,
    this.activityLevel,
    this.bodyImagePath,
    this.avatarPath,
    this.photoHistory,
    this.bodyFatPct,
    this.musclePct,
    this.createdAt,
    this.lastActive,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? gender,
    int? age,
    int? height,
    double? weight,
    double? targetWeight,
    double? initialWeight,
    String? goal,
    String? activityLevel,
    String? bodyImagePath,
    String? avatarPath,
    List<String>? photoHistory,
    double? bodyFatPct,
    double? musclePct,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      initialWeight: initialWeight ?? this.initialWeight,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      bodyImagePath: bodyImagePath ?? this.bodyImagePath,
      avatarPath: avatarPath ?? this.avatarPath,
      photoHistory: photoHistory ?? this.photoHistory,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      musclePct: musclePct ?? this.musclePct,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'initialWeight': initialWeight,
      'goal': goal,
      'activityLevel': activityLevel,
      'bodyImagePath': bodyImagePath,
      'avatarPath': avatarPath,
      'photoHistory': photoHistory,
      'bodyFatPct': bodyFatPct,
      'musclePct': musclePct,
      'createdAt': createdAt?.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'],
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      height: json['height'],
      weight: json['weight']?.toDouble(),
      targetWeight: json['targetWeight']?.toDouble(),
      initialWeight: json['initialWeight']?.toDouble(),
      goal: json['goal'],
      activityLevel: json['activityLevel'],
      bodyImagePath: json['bodyImagePath'],
      avatarPath: json['avatarPath'],
      photoHistory: json['photoHistory'] != null ? List<String>.from(json['photoHistory']) : null,
      bodyFatPct: json['bodyFatPct']?.toDouble(),
      musclePct: json['musclePct']?.toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive']) : null,
    );
  }
}
