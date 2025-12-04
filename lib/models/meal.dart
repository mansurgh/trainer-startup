// lib/models/meal.dart

/// Модель блюда
class Dish {
  final String id;
  final String name;
  final int calories;
  final double protein;  // граммы
  final double fat;      // граммы
  final double carbs;    // граммы
  bool isCompleted;

  Dish({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.isCompleted = false,
  });

  Dish copyWith({
    String? id,
    String? name,
    int? calories,
    double? protein,
    double? fat,
    double? carbs,
    bool? isCompleted,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'isCompleted': isCompleted,
    };
  }

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

/// Тип приема пищи
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get displayNameRu {
    switch (this) {
      case MealType.breakfast:
        return 'Завтрак';
      case MealType.lunch:
        return 'Обед';
      case MealType.dinner:
        return 'Ужин';
      case MealType.snack:
        return 'Перекус';
    }
  }
}

/// Модель приема пищи
class Meal {
  final String id;
  final MealType type;
  final List<Dish> dishes;
  final DateTime date;
  final String? customName;

  Meal({
    required this.id,
    required this.type,
    required this.dishes,
    required this.date,
    this.customName,
  });

  int get totalCalories => dishes.fold(0, (sum, dish) => sum + dish.calories);
  double get totalProtein => dishes.fold(0.0, (sum, dish) => sum + dish.protein);
  double get totalFat => dishes.fold(0.0, (sum, dish) => sum + dish.fat);
  double get totalCarbs => dishes.fold(0.0, (sum, dish) => sum + dish.carbs);

  int get completedCalories => dishes.where((d) => d.isCompleted).fold(0, (sum, dish) => sum + dish.calories);
  double get completedProtein => dishes.where((d) => d.isCompleted).fold(0.0, (sum, dish) => sum + dish.protein);
  double get completedFat => dishes.where((d) => d.isCompleted).fold(0.0, (sum, dish) => sum + dish.fat);
  double get completedCarbs => dishes.where((d) => d.isCompleted).fold(0.0, (sum, dish) => sum + dish.carbs);

  String get displayName => customName ?? type.displayNameRu;
  
  Meal copyWith({
    String? id,
    MealType? type,
    List<Dish>? dishes,
    DateTime? date,
    String? customName,
  }) {
    return Meal(
      id: id ?? this.id,
      type: type ?? this.type,
      dishes: dishes ?? this.dishes,
      date: date ?? this.date,
      customName: customName ?? this.customName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'dishes': dishes.map((d) => d.toJson()).toList(),
      'date': date.toIso8601String(),
      'customName': customName,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      type: MealType.values.firstWhere((e) => e.name == json['type']),
      dishes: (json['dishes'] as List).map((d) => Dish.fromJson(d as Map<String, dynamic>)).toList(),
      date: DateTime.parse(json['date'] as String),
      customName: json['customName'] as String?,
    );
  }
}
