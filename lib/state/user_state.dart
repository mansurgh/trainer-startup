import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserModel {
  final String id;
  final String? name;
  final String? gender; // m / f
  final int? age;
  final int? height;
  final double? weight;
  final String? goal; // fat_loss / muscle_gain / fitness
  final String? bodyImagePath;

  // Состав тела
  final double? bodyFatPct;
  final double? musclePct;

  const UserModel({
    required this.id,
    this.name,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.goal,
    this.bodyImagePath,
    this.bodyFatPct,
    this.musclePct,
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
    double? bodyFatPct,
    double? musclePct,
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
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      musclePct: musclePct ?? this.musclePct,
    );
  }
}

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  /// Создать или обновить профиль из онбординга
  void createOrUpdateProfile({
    required String id,
    String? name,
    String? gender,
    int? age,
    int? height,
    double? weight,
    String? goal,
  }) {
    final base = state ?? UserModel(id: id);
    state = base.copyWith(
      name: name ?? base.name,
      gender: gender ?? base.gender,
      age: age ?? base.age,
      height: height ?? base.height,
      weight: weight ?? base.weight,
      goal: goal ?? base.goal,
    );
  }

  void create(UserModel user) => state = user;

  Future<void> setBodyImagePath(String path) async {
    if (!File(path).existsSync()) return;
    state = state?.copyWith(bodyImagePath: path);
  }

  void setComposition({double? fatPct, double? musclePct}) {
    state = state?.copyWith(bodyFatPct: fatPct, musclePct: musclePct);
  }

  void setName(String name) => state = state?.copyWith(name: name);
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
