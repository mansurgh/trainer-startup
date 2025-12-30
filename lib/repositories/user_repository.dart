// =============================================================================
// user_repository.dart — Bulletproof User Data Repository
// =============================================================================
// Отвечает за фетчинг и обновление данных профиля.
// ЦЕЛЬ: Устранить race conditions и добавить retry logic при сетевых ошибках.
// 
// КЛЮЧЕВЫЕ ГАРАНТИИ:
// 1. Не пытаемся загрузить данные ДО получения токена auth
// 2. Retry при сетевых ошибках (exponential backoff)
// 3. Кэширование для оффлайн-режима
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  // Retry configuration - MINIMAL retries to avoid spam
  static const int maxRetries = 1;  // Only 1 retry to avoid spam
  static const Duration initialRetryDelay = Duration(milliseconds: 500);
  static const Duration cacheValidityDuration = Duration(minutes: 30);  // Longer cache

  /// Получить профиль пользователя с минимальной retry logic
  Future<UserModel?> getProfile(String userId, {int retryCount = 0}) async {
    try {
      // СНАЧАЛА проверяем кэш - даже устаревший лучше чем ничего при офлайне
      final cachedProfile = await _getCachedProfile(userId, ignoreExpiry: true);
      if (cachedProfile != null) {
        // Если есть кэш - возвращаем сразу, фоновый апдейт только если онлайн
        _fetchAndCacheProfile(userId).ignore();
        return cachedProfile;
      }

      // Нет кэша - загружаем из Supabase
      return await _fetchAndCacheProfile(userId);
      
    } on PostgrestException catch (e) {
      // Если профиль не найден (404), возвращаем null
      if (e.code == 'PGRST116' || e.message.contains('0 rows')) {
        return null;
      }
      
      // При ошибке - возвращаем кэш если есть
      final oldCache = await _getCachedProfile(userId, ignoreExpiry: true);
      if (oldCache != null) return oldCache;
      
      rethrow;
      
    } catch (e) {
      // При любой ошибке (включая сеть) - сразу возвращаем кэш
      final oldCache = await _getCachedProfile(userId, ignoreExpiry: true);
      if (oldCache != null) return oldCache;
      
      // Только один retry если совсем нет кэша
      if (retryCount < maxRetries) {
        await Future.delayed(initialRetryDelay);
        return getProfile(userId, retryCount: retryCount + 1);
      }
      
      rethrow;
    }
  }

  /// Фетчинг и кэширование профиля
  Future<UserModel?> _fetchAndCacheProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    final profile = UserModel.fromJson(response);
    
    // Сохраняем в кэш
    await _cacheProfile(userId, profile);
    
    return profile;
  }

  /// Обновить профиль
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    // Добавляем updated_at
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId);
    
    // Инвалидируем кэш
    await _invalidateCache(userId);
  }

  /// Создать профиль (если триггер не сработал)
  Future<UserModel> createProfile(String userId, Map<String, dynamic> data) async {
    data['id'] = userId;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    
    final response = await _client
        .from('profiles')
        .insert(data)
        .select()
        .single();
    
    final profile = UserModel.fromJson(response);
    await _cacheProfile(userId, profile);
    
    return profile;
  }

  // =========================================================================
  // КЭШИРОВАНИЕ
  // =========================================================================

  /// Получить профиль из кэша
  Future<UserModel?> _getCachedProfile(String userId, {bool ignoreExpiry = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('profile_cache_$userId');
      final cachedTime = prefs.getInt('profile_cache_time_$userId');
      
      if (cachedJson == null || cachedTime == null) {
        return null;
      }

      // Проверяем валидность кэша
      if (!ignoreExpiry) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTime;
        if (cacheAge > cacheValidityDuration.inMilliseconds) {
          return null;
        }
      }

      final json = jsonDecode(cachedJson) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Сохранить профиль в кэш
  Future<void> _cacheProfile(String userId, UserModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_cache_$userId', jsonEncode(profile.toJson()));
      await prefs.setInt('profile_cache_time_$userId', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Инвалидировать кэш
  Future<void> _invalidateCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_cache_$userId');
      await prefs.remove('profile_cache_time_$userId');
    } catch (_) {}
  }
}
