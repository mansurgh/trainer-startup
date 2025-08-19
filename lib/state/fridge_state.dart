import 'package:flutter_riverpod/flutter_riverpod.dart';

class FridgeState {
  final String? imagePath; // локальный путь выбранного фото
  const FridgeState({this.imagePath});

  FridgeState copyWith({String? imagePath}) => FridgeState(imagePath: imagePath ?? this.imagePath);
}

class FridgeNotifier extends StateNotifier<FridgeState> {
  FridgeNotifier() : super(const FridgeState());

  void setImage(String path) => state = state.copyWith(imagePath: path);
  void clearImage() => state = const FridgeState();
}

final fridgeProvider = StateNotifierProvider<FridgeNotifier, FridgeState>((ref) => FridgeNotifier());
