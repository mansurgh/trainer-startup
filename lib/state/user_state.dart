import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/profile_service.dart';
import '../config/supabase_config.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _loadUser();
  }

  final ProfileService _profileService = ProfileService();

  /// Загрузить пользователя из локального хранилища и синхронизировать с Supabase
  Future<void> _loadUser() async {
    try {
      // Сначала загружаем из локального хранилища для быстрого старта
      final localUser = await StorageService.getUser();
      if (localUser != null) {
        state = localUser;
      }

      // Если пользователь авторизован в Supabase, синхронизируем данные
      if (SupabaseConfig.isAuthenticated) {
        await _syncFromSupabase();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[UserState] Error loading user: $e');
      }
    }
  }

  /// Синхронизировать профиль из Supabase
  Future<void> _syncFromSupabase() async {
    try {
      final profile = await _profileService.getProfile();
      if (profile != null) {
        final supabaseUser = UserModel(
          id: profile['id'] ?? state?.id ?? '',
          email: profile['email'] ?? state?.email,
          name: profile['name'] ?? state?.name,
          gender: profile['gender'] ?? state?.gender,
          age: profile['age'] ?? state?.age,
          height: profile['height'] ?? state?.height,
          weight: (profile['weight'] as num?)?.toDouble() ?? state?.weight,
          targetWeight: (profile['target_weight'] as num?)?.toDouble() ?? state?.targetWeight,
          goal: profile['goal'] ?? state?.goal,
          activityLevel: state?.activityLevel, // Keep local value, not in Supabase
          avatarPath: profile['avatar_url'] ?? state?.avatarPath,
          bodyFatPct: state?.bodyFatPct ?? 20.0,
          musclePct: state?.musclePct ?? 70.0,
          createdAt: profile['created_at'] != null 
              ? DateTime.parse(profile['created_at']) 
              : state?.createdAt,
          lastActive: DateTime.now(),
        );
        
        state = supabaseUser;
        // Сохраняем в локальное хранилище
        await StorageService.saveUser(supabaseUser);
        
        if (kDebugMode) {
          print('[UserState] Synced user from Supabase');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[UserState] Error syncing from Supabase: $e');
      }
    }
  }
  /// Синхронизировать профиль в Supabase
  Future<void> _syncToSupabase() async {
    if (!SupabaseConfig.isAuthenticated || state == null) return;
    
    try {
      // CRITICAL: Always include email to satisfy NOT NULL constraint
      final currentEmail = Supabase.instance.client.auth.currentUser?.email;
      
      // Only sync fields that exist in Supabase profiles table
      await _profileService.upsertProfile({
        'email': currentEmail ?? state!.email, // Email is required!
        'name': state!.name,
        'gender': state!.gender,
        'age': state!.age,
        'height': state!.height,
        'weight': state!.weight,
        'target_weight': state!.targetWeight,
        'goal': state!.goal,
      });
      
      if (kDebugMode) {
        print('[UserState] Synced user to Supabase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[UserState] Error syncing to Supabase: $e');
      }
    }
  }

  /// Принудительно перезагрузить пользователя из Supabase
  Future<void> refreshFromSupabase() async {
    if (SupabaseConfig.isAuthenticated) {
      await _syncFromSupabase();
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
    // Синхронизируем с Supabase
    await _syncToSupabase();
  }

  void create(UserModel user) {
    state = user;
    StorageService.saveUser(user);
    _syncToSupabase();
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
    // Синхронизируем с Supabase
    await _syncToSupabase();
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
    // Синхронизируем с Supabase
    await _syncToSupabase();
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
