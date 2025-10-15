class MealItem {
  final String name;
  final double? grams;
  final int? calories;
  final String? description;

  MealItem({
    required this.name,
    this.grams,
    this.calories,
    this.description,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] ?? '',
      grams: json['grams']?.toDouble(),
      calories: json['calories']?.toInt(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grams': grams,
      'calories': calories,
      'description': description,
    };
  }
}

class MealGroup {
  final String name;
  final List<MealItem> items;
  final DateTime? scheduledTime;
  final String? notes;

  MealGroup({
    required this.name,
    required this.items,
    this.scheduledTime,
    this.notes,
  });

  factory MealGroup.fromJson(Map<String, dynamic> json) {
    return MealGroup(
      name: json['name'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => MealItem.fromJson(item))
          .toList() ?? [],
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'scheduledTime': scheduledTime?.toIso8601String(),
      'notes': notes,
    };
  }

  // Helper method to get total calories
  int get totalCalories {
    return items.fold(0, (sum, item) => sum + (item.calories ?? 0));
  }

  // Helper method to add an item
  MealGroup addItem(MealItem item) {
    return MealGroup(
      name: name,
      items: [...items, item],
      scheduledTime: scheduledTime,
      notes: notes,
    );
  }

  // Helper method to remove an item
  MealGroup removeItem(int index) {
    if (index >= 0 && index < items.length) {
      final newItems = List<MealItem>.from(items);
      newItems.removeAt(index);
      return MealGroup(
        name: name,
        items: newItems,
        scheduledTime: scheduledTime,
        notes: notes,
      );
    }
    return this;
  }
}