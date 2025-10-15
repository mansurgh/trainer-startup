import 'package:flutter_riverpod/flutter_riverpod.dart';

class FridgeState {
  final String? imagePath; // локальный путь выбранного фото
  final List<String> ingredients; // список обнаруженных ингредиентов
  
  const FridgeState({
    this.imagePath,
    this.ingredients = const [],
  });

  FridgeState copyWith({
    String? imagePath,
    List<String>? ingredients,
  }) => FridgeState(
    imagePath: imagePath ?? this.imagePath,
    ingredients: ingredients ?? this.ingredients,
  );
}

class FridgeNotifier extends StateNotifier<FridgeState> {
  FridgeNotifier() : super(const FridgeState());

  void setImage(String path) {
    // При установке нового фото можно добавить заглушки ингредиентов
    final mockIngredients = [
      'Молоко',
      'Яйца', 
      'Хлеб',
      'Сыр',
      'Помидоры',
      'Огурцы',
    ];
    state = state.copyWith(
      imagePath: path,
      ingredients: mockIngredients,
    );
  }
  
  void clearImage() => state = const FridgeState();
  
  void addIngredient(String ingredient) {
    if (!state.ingredients.contains(ingredient)) {
      state = state.copyWith(
        ingredients: [...state.ingredients, ingredient],
      );
    }
  }
  
  void removeIngredient(String ingredient) {
    final updatedIngredients = state.ingredients.where((i) => i != ingredient).toList();
    state = state.copyWith(ingredients: updatedIngredients);
  }
  
  void updateIngredients(List<String> ingredients) {
    state = state.copyWith(ingredients: ingredients);
  }
}

final fridgeProvider = StateNotifierProvider<FridgeNotifier, FridgeState>((ref) => FridgeNotifier());
