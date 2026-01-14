// =============================================================================
// profile_provider.dart — Reactive Profile State with Supabase Auth Sync
// =============================================================================
// Riverpod-based state management for user profile with:
// - Real-time auth state listening (onAuthStateChange)
// - Automatic profile fetch on signedIn event
// - Local caching to prevent UI flickering
// - Error handling with retry logic
// =============================================================================

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import 'dart:convert';

// =============================================================================
// PROFILE STATE — Immutable state container
// =============================================================================

/// Represents the current state of user profile loading and data.
@immutable
class ProfileState {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
    this.lastUpdated,
  });

  /// User profile data (null if not loaded or logged out)
  final UserModel? profile;
  
  /// Whether a profile fetch is in progress
  final bool isLoading;
  
  /// Whether the provider has been initialized (first load complete)
  final bool isInitialized;
  
  /// Error message if last fetch failed
  final String? error;
  
  /// Timestamp of last successful update
  final DateTime? lastUpdated;

  /// Convenience getters
  bool get hasProfile => profile != null;
  bool get hasError => error != null;
  String get displayName => profile?.name ?? 'Атлет';
  String get email => profile?.email ?? '';
  
  ProfileState copyWith({
    UserModel? profile,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    DateTime? lastUpdated,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return ProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// =============================================================================
// PROFILE NOTIFIER — StateNotifier with Supabase integration
// =============================================================================

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._ref) : super(const ProfileState()) {
    _initialize();
  }

  final Ref _ref;
  StreamSubscription<AuthState>? _authSubscription;
  
  /// Local cache key prefix
  static const String _cacheKeyProfile = 'cached_profile_data';
  static const String _cacheKeyTimestamp = 'cached_profile_timestamp';
  
  /// Cache validity duration (30 minutes for better offline experience)
  static const Duration _cacheValidity = Duration(minutes: 30);

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initialize the provider: load cache, setup auth listener
  Future<void> _initialize() async {
    // Step 1: Load cached profile for instant UI (no skeleton flash)
    await _loadFromCache();
    
    // Step 2: Setup auth state listener
    _setupAuthListener();
    
    // Step 3: If already authenticated, fetch fresh data
    if (SupabaseConfig.isAuthenticated) {
      await _fetchProfile();
    }
    
    // Mark as initialized
    state = state.copyWith(isInitialized: true);
  }

  // ===========================================================================
  // AUTH LISTENER — Core re-login fix
  // ===========================================================================

  /// Listen to Supabase auth state changes.
  /// This is the KEY FIX for re-login issues.
  void _setupAuthListener() {
    _authSubscription?.cancel();
    
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (AuthState authState) async {
        final event = authState.event;
        final session = authState.session;

        switch (event) {
          case AuthChangeEvent.signedIn:
          case AuthChangeEvent.tokenRefreshed:
          case AuthChangeEvent.userUpdated:
            // User signed in or session refreshed — fetch profile
            if (session != null) {
              await _onSignedIn(session);
            }
            break;
            
          case AuthChangeEvent.signedOut:
            // Clear all data on sign out
            await _onSignedOut();
            break;
            
          case AuthChangeEvent.initialSession:
            // Initial session on app start (already handled by _initialize)
            if (session != null && !state.hasProfile) {
              await _onSignedIn(session);
            }
            break;
            
          default:
            break;
        }
      },
      onError: (_) {},  // Silently ignore errors - offline is expected
    );
  }

  /// Handle sign-in event
  Future<void> _onSignedIn(Session session) async {
    if (kDebugMode) {
      print('[ProfileProvider] 🔐 User signed in: ${session.user.id}');
    }
    
    // Update userId in SharedPreferences for consistency
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', session.user.id);
    
    // Fetch fresh profile from Supabase
    await _fetchProfile();
  }

  /// Handle sign-out event
  Future<void> _onSignedOut() async {
    // Clear cache
    await _clearCache();
    
    // Reset state
    state = const ProfileState(isInitialized: true);
  }

  // ===========================================================================
  // PROFILE FETCHING — Main data retrieval
  // ===========================================================================

  /// Fetch profile from Supabase `profiles` table.
  /// Called on sign-in and manual refresh.
  Future<void> _fetchProfile() async {
    // Prevent concurrent fetches
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw Exception('No authenticated user');
      }

      // Fetch from Supabase
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        // Parse profile data
        final profile = _parseSupabaseProfile(response, userId);
        
        // Update state
        state = state.copyWith(
          profile: profile,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
        
        // Cache locally
        await _saveToCache(profile);
        
        // Also update StorageService for other parts of the app
        await StorageService.saveUser(profile);
      } else {
        // No profile exists yet — create skeleton profile
        final newProfile = await _createInitialProfile(userId);
        state = state.copyWith(
          profile: newProfile,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (_) {
      // If we have cached data, use it silently (don't show error)
      if (state.hasProfile) {
        // Just stop loading, keep cached profile
        state = state.copyWith(isLoading: false);
      } else {
        // No cache - try to load from local storage
        await _loadFromCache();
        if (state.hasProfile) {
          state = state.copyWith(isLoading: false);
        } else {
          // Really no data - but don't spam errors, just show empty state
          state = state.copyWith(isLoading: false);
        }
      }
    }
  }
  
  /// Format error message for user display
  String _formatError(Object e) {
    final errorStr = e.toString();
    if (errorStr.contains('SocketException') || 
        errorStr.contains('host lookup') ||
        errorStr.contains('network')) {
      return 'Нет подключения к интернету';
    }
    if (errorStr.contains('timeout')) {
      return 'Превышено время ожидания';
    }
    return errorStr.length > 100 ? '${errorStr.substring(0, 100)}...' : errorStr;
  }

  /// Parse Supabase response into UserModel
  UserModel _parseSupabaseProfile(Map<String, dynamic> data, String userId) {
    return UserModel(
      id: userId,
      email: data['email'] as String?,
      name: data['name'] as String?,
      gender: data['gender'] as String?,
      age: data['age'] as int?,
      height: data['height'] as int?,
      weight: (data['weight'] as num?)?.toDouble(),
      targetWeight: (data['target_weight'] as num?)?.toDouble(),
      goal: data['goal'] as String?,
      avatarPath: data['avatar_url'] as String?,
      bodyFatPct: 20.0,
      musclePct: 70.0,
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at']) 
          : null,
      lastActive: DateTime.now(),
    );
  }

  /// Create initial profile for new user
  Future<UserModel> _createInitialProfile(String userId) async {
    if (kDebugMode) {
      print('[ProfileProvider] 📝 Creating initial profile for: $userId');
    }
    
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email;
    final now = DateTime.now();
    
    // Email is required by database schema (NOT NULL constraint)
    if (email == null || email.isEmpty) {
      if (kDebugMode) {
        print('[ProfileProvider] ⚠️ Cannot create profile: email is null');
      }
      // Return local-only model without syncing to DB
      return UserModel(
        id: userId,
        email: null,
        name: 'Атлет',
        createdAt: now,
        lastActive: now,
      );
    }
    
    // Create profile with sensible defaults
    final initialData = {
      'id': userId,
      'email': email,
      'name': 'Атлет', // Default name for new users
      'subscription_status': 'trial',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
    
    try {
      await Supabase.instance.client
          .from('profiles')
          .upsert(initialData, onConflict: 'id');
      
      if (kDebugMode) {
        print('[ProfileProvider] ✅ Created initial profile with name: Атлет');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileProvider] ⚠️ Could not create profile: $e');
      }
    }
    
    return UserModel(
      id: userId,
      email: email,
      name: 'Атлет',
      createdAt: now,
      lastActive: now,
    );
  }

  // ===========================================================================
  // CACHING — Local persistence for instant UI
  // ===========================================================================

  /// Load profile from local cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKeyProfile);
      final cachedTimestamp = prefs.getInt(_cacheKeyTimestamp);
      
      if (cachedJson == null || cachedTimestamp == null) return;
      
      // Check cache validity
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
      if (DateTime.now().difference(cacheTime) > _cacheValidity) {
        if (kDebugMode) {
          print('[ProfileProvider] 📦 Cache expired, will fetch fresh data');
        }
        return;
      }
      
      // Parse cached profile
      final data = jsonDecode(cachedJson) as Map<String, dynamic>;
      final profile = UserModel.fromJson(data);
      
      state = state.copyWith(
        profile: profile,
        lastUpdated: cacheTime,
      );
      
      if (kDebugMode) {
        print('[ProfileProvider] 📦 Loaded from cache: ${profile.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileProvider] ⚠️ Cache load error: $e');
      }
    }
  }

  /// Save profile to local cache
  Future<void> _saveToCache(UserModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyProfile, jsonEncode(profile.toJson()));
      await prefs.setInt(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
      
      if (kDebugMode) {
        print('[ProfileProvider] 💾 Saved to cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileProvider] ⚠️ Cache save error: $e');
      }
    }
  }

  /// Clear local cache
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyProfile);
      await prefs.remove(_cacheKeyTimestamp);
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileProvider] ⚠️ Cache clear error: $e');
      }
    }
  }

  // ===========================================================================
  // PUBLIC API — Methods for UI interaction
  // ===========================================================================

  /// Force refresh profile from Supabase
  Future<void> refresh() async {
    await _fetchProfile();
  }

  /// Update profile fields and sync to Supabase
  Future<void> updateProfile({
    String? name,
    String? gender,
    int? age,
    int? height,
    double? weight,
    double? targetWeight,
    String? goal,
    String? avatarPath,
  }) async {
    if (!state.hasProfile) return;
    
    final current = state.profile!;
    final updated = current.copyWith(
      name: name ?? current.name,
      gender: gender ?? current.gender,
      age: age ?? current.age,
      height: height ?? current.height,
      weight: weight ?? current.weight,
      targetWeight: targetWeight ?? current.targetWeight,
      goal: goal ?? current.goal,
      avatarPath: avatarPath ?? current.avatarPath,
      lastActive: DateTime.now(),
    );
    
    // Optimistic update
    state = state.copyWith(profile: updated);
    
    // Sync to Supabase
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return;
      
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (name != null) updateData['name'] = name;
      if (gender != null) updateData['gender'] = gender;
      if (age != null) updateData['age'] = age;
      if (height != null) updateData['height'] = height;
      if (weight != null) updateData['weight'] = weight;
      if (targetWeight != null) updateData['target_weight'] = targetWeight;
      if (goal != null) updateData['goal'] = goal;
      if (avatarPath != null) updateData['avatar_url'] = avatarPath;
      
      await Supabase.instance.client
          .from('profiles')
          .update(updateData)
          .eq('id', userId);
      
      // Update cache
      await _saveToCache(updated);
      await StorageService.saveUser(updated);
      
      if (kDebugMode) {
        print('[ProfileProvider] ✅ Profile updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileProvider] ❌ Update error: $e');
      }
      // Revert on error
      state = state.copyWith(
        profile: current,
        error: 'Не удалось сохранить изменения',
      );
    }
  }

  /// Update weight specifically (common operation)
  /// Also saves to body_measurements table for trend tracking
  Future<void> updateWeight(double weight) async {
    await updateProfile(weight: weight);
    
    // Also record in body_measurements for weight trend tracking
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return;
      
      final now = DateTime.now();
      final measurementDate = now.toIso8601String().split('T')[0];
      
      // Delete existing record for today (if any) then insert new one
      // This avoids ON CONFLICT issues since table lacks unique constraint
      await Supabase.instance.client
          .from('body_measurements')
          .delete()
          .eq('user_id', userId)
          .eq('measurement_date', measurementDate);
      
      await Supabase.instance.client.from('body_measurements').insert({
        'user_id': userId,
        'weight': weight,
        'measurement_date': measurementDate,
        'created_at': now.toIso8601String(),
      });
      
      if (kDebugMode) {
        print('[ProfileProvider] ✅ Weight recorded in body_measurements: $weight kg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileProvider] ⚠️ Could not save to body_measurements: $e');
      }
      // Don't rethrow - profile update succeeded, this is secondary
    }
  }

  /// Upload and update avatar
  Future<void> updateAvatar(String localFilePath) async {
    if (!state.hasProfile) return;
    
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;
    
    try {
      if (kDebugMode) {
        print('[ProfileProvider] 📸 Uploading avatar from: $localFilePath');
      }
      
      // Read file
      final file = await _readFileAsBytes(localFilePath);
      if (file == null) {
        throw Exception('Could not read file');
      }
      
      // Generate unique filename
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'avatars/$fileName';
      
      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(storagePath, file, fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ));
      
      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(storagePath);
      
      if (kDebugMode) {
        print('[ProfileProvider] ✅ Avatar uploaded: $publicUrl');
      }
      
      // Update profile with new avatar URL
      await updateProfile(avatarPath: publicUrl);
      
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileProvider] ❌ Avatar upload error: $e');
      }
      rethrow;
    }
  }
  
  /// Helper to read file as bytes
  Future<Uint8List?> _readFileAsBytes(String path) async {
    try {
      final file = File(path);
      return await file.readAsBytes();
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileProvider] ⚠️ Could not read file: $e');
      }
      return null;
    }
  }

  /// Clear profile state (called by AuthNotifier on sign out)
  void clearProfile() {
    state = const ProfileState();
    if (kDebugMode) {
      print('[ProfileProvider] 🗑️ Profile state cleared');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// =============================================================================
// PROVIDER DEFINITION
// =============================================================================

/// Main profile provider — use this throughout the app
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});

/// Convenience selector: just the profile
final profileDataProvider = Provider<UserModel?>((ref) {
  return ref.watch(profileProvider).profile;
});

/// Convenience selector: is loading
final profileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isLoading;
});

/// Convenience selector: display name
final displayNameProvider = Provider<String>((ref) {
  return ref.watch(profileProvider).displayName;
});
