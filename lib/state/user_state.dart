import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _loadUser();
  }

  /// Загрузить пользователя из хранилища
  Future<void> _loadUser() async {
    try {
      final user = await StorageService.getUser();
      if (user != null) {
        state = user;
      }
    } catch (e) {
      // Игнорируем ошибки загрузки при старте
    }
  }

  /// Создать или обновить профиль из онбординга
  Future<void> createOrUpdateProfile({
    required String id,
    String? email,
    String? name,
    String? gender,
    int? age,
    int? height,
    double? weight,
    String? goal,
  }) async {
    final base = state ?? UserModel(
      id: id,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );
    final updatedUser = base.copyWith(
      email: email ?? base.email,
      name: name ?? base.name,
      gender: gender ?? base.gender,
      age: age ?? base.age,
      height: height ?? base.height,
      weight: weight ?? base.weight,
      goal: goal ?? base.goal,
      lastActive: DateTime.now(),
    );
    state = updatedUser;
    await StorageService.saveUser(updatedUser);
  }

  void create(UserModel user) {
    state = user;
    StorageService.saveUser(user);
  }

  Future<void> setBodyImagePath(String path) async {
    if (!File(path).existsSync()) return;
    
    // Добавляем фото в историю
    final currentHistory = state?.photoHistory ?? <String>[];
    final newHistory = [...currentHistory, path];
    
    final updatedUser = state?.copyWith(
      bodyImagePath: path, // Последнее фото
      photoHistory: newHistory, // Вся история
      lastActive: DateTime.now(),
    );
    if (updatedUser != null) {
      state = updatedUser;
      await StorageService.saveUser(updatedUser);
    }
  }

  Future<void> clearPhotoHistory() async {
    final updatedUser = state?.copyWith(
      bodyImagePath: null,
      photoHistory: <String>[],
      lastActive: DateTime.now(),
    );
    if (updatedUser != null) {
      state = updatedUser;
      await StorageService.saveUser(updatedUser);
    }
  }

  Future<void> setAvatarPath(String path) async {
    if (!File(path).existsSync()) return;
    
    final updatedUser = state?.copyWith(
      avatarPath: path,
      lastActive: DateTime.now(),
    );
    if (updatedUser != null) {
      state = updatedUser;
      await StorageService.saveUser(updatedUser);
    }
  }

  Future<void> setComposition({double? fatPct, double? musclePct}) async {
    final updatedUser = state?.copyWith(
      bodyFatPct: fatPct,
      musclePct: musclePct,
      lastActive: DateTime.now(),
    );
    if (updatedUser != null) {
      state = updatedUser;
      await StorageService.saveUser(updatedUser);
    }
  }

  Future<void> setName(String name) async {
    final updatedUser = state?.copyWith(
      name: name,
      lastActive: DateTime.now(),
    );
    if (updatedUser != null) {
      state = updatedUser;
      await StorageService.saveUser(updatedUser);
    }
  }

  /// Пакетное обновление параметров пользователя.
  /// Передавай только то, что нужно изменить.
  Future<void> setParams({
    int? age,
    int? height,
    double? weight,
    String? gender,
    String? goal,
  }) async {
    final s = state;
    if (s == null) return;
    final updatedUser = s.copyWith(
      age: age ?? s.age,
      height: height ?? s.height,
      weight: weight ?? s.weight,
      gender: gender ?? s.gender,
      goal: goal ?? s.goal,
      lastActive: DateTime.now(),
    );
    state = updatedUser;
    await StorageService.saveUser(updatedUser);
  }

  /// Обновить аватар пользователя
  Future<void> updateAvatar(String avatarPath) async {
    final s = state;
    if (s == null) return;
    final updatedUser = s.copyWith(
      avatarPath: avatarPath,
      lastActive: DateTime.now(),
    );
    state = updatedUser;
    await StorageService.saveUser(updatedUser);
  }

  /// Очистить все данные пользователя
  Future<void> clearUser() async {
    state = null;
    await StorageService.clearAllData();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
