/// Модель для продукта из Open Food Facts
class FoodProduct {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final Nutrients nutrients;
  final String? servingSize;
  final String? category;

  FoodProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.nutrients,
    this.servingSize,
    this.category,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    return FoodProduct(
      barcode: json['code'] ?? '',
      name: json['product_name'] ?? json['product_name_en'] ?? 'Unknown Product',
      brand: json['brands'],
      imageUrl: json['image_url'],
      nutrients: Nutrients.fromJson(json['nutriments'] ?? {}),
      servingSize: json['serving_size'],
      category: json['categories'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': barcode,
      'product_name': name,
      'brands': brand,
      'image_url': imageUrl,
      'nutriments': nutrients.toJson(),
      'serving_size': servingSize,
      'categories': category,
    };
  }

  // Калории на 100г
  double get caloriesPer100g => nutrients.energyKcal100g ?? 0;
  
  // Белки на 100г
  double get proteinPer100g => nutrients.proteins100g ?? 0;
  
  // Жиры на 100г
  double get fatPer100g => nutrients.fat100g ?? 0;
  
  // Углеводы на 100г
  double get carbsPer100g => nutrients.carbohydrates100g ?? 0;
}

/// Модель нутриентов
class Nutrients {
  // На 100г
  final double? energyKcal100g;
  final double? proteins100g;
  final double? fat100g;
  final double? carbohydrates100g;
  final double? fiber100g;
  final double? sugars100g;
  final double? salt100g;
  final double? sodium100g;

  // На порцию (если есть)
  final double? energyKcalServing;
  final double? proteinsServing;
  final double? fatServing;
  final double? carbohydratesServing;

  Nutrients({
    this.energyKcal100g,
    this.proteins100g,
    this.fat100g,
    this.carbohydrates100g,
    this.fiber100g,
    this.sugars100g,
    this.salt100g,
    this.sodium100g,
    this.energyKcalServing,
    this.proteinsServing,
    this.fatServing,
    this.carbohydratesServing,
  });

  factory Nutrients.fromJson(Map<String, dynamic> json) {
    return Nutrients(
      energyKcal100g: _parseDouble(json['energy-kcal_100g']),
      proteins100g: _parseDouble(json['proteins_100g']),
      fat100g: _parseDouble(json['fat_100g']),
      carbohydrates100g: _parseDouble(json['carbohydrates_100g']),
      fiber100g: _parseDouble(json['fiber_100g']),
      sugars100g: _parseDouble(json['sugars_100g']),
      salt100g: _parseDouble(json['salt_100g']),
      sodium100g: _parseDouble(json['sodium_100g']),
      energyKcalServing: _parseDouble(json['energy-kcal_serving']),
      proteinsServing: _parseDouble(json['proteins_serving']),
      fatServing: _parseDouble(json['fat_serving']),
      carbohydratesServing: _parseDouble(json['carbohydrates_serving']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'energy-kcal_100g': energyKcal100g,
      'proteins_100g': proteins100g,
      'fat_100g': fat100g,
      'carbohydrates_100g': carbohydrates100g,
      'fiber_100g': fiber100g,
      'sugars_100g': sugars100g,
      'salt_100g': salt100g,
      'sodium_100g': sodium100g,
      'energy-kcal_serving': energyKcalServing,
      'proteins_serving': proteinsServing,
      'fat_serving': fatServing,
      'carbohydrates_serving': carbohydratesServing,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
