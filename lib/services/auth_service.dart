import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

/// Authentication Service for Supabase with UserRepository integration
/// Handles sign up, sign in, sign out, password reset, etc.
/// BULLETPROOF: Clears all data on signOut, loads profile on signIn
class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _client = SupabaseConfig.client;
  final UserRepository _userRepository = UserRepository();
  
  // State management
  StreamSubscription<AuthState>? _authSubscription;
  final _profileController = StreamController<UserModel?>.broadcast();
  UserModel? _currentProfile;
  
  /// Stream of profile changes
  Stream<UserModel?> get profileChanges => _profileController.stream;
  
  /// Current cached profile
  UserModel? get currentProfile => _currentProfile;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user ID
  String? get userId => currentUser?.id;

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  /// Initialize auth service - call in main.dart
  Future<void> initialize() async {
    // Listen to auth state changes (silently ignore errors - they're handled elsewhere)
    _authSubscription = _client.auth.onAuthStateChange.listen(
      _onAuthStateChanged,
      onError: (_) {},  // Silently ignore - offline errors are expected
    );
    
    // Check current session
    final session = _client.auth.currentSession;
    if (session != null && currentUser != null) {
      await _loadProfile(currentUser!.id);
    }
  }
  
  /// Handle auth state changes
  Future<void> _onAuthStateChanged(AuthState state) async {
    switch (state.event) {
      case AuthChangeEvent.signedIn:
        if (state.session?.user != null) {
          await _loadProfile(state.session!.user.id);
        }
        break;
        
      case AuthChangeEvent.signedOut:
        await _clearAllData();
        break;
        
      default:
        break;
    }
  }
  
  /// Load user profile
  Future<void> _loadProfile(String userId) async {
    try {
      _currentProfile = await _userRepository.getProfile(userId);
      _profileController.add(_currentProfile);
    } catch (_) {
      _currentProfile = null;
      _profileController.add(null);
    }
  }
  
  /// Clear all user data on sign out
  Future<void> _clearAllData() async {
    _currentProfile = null;
    _profileController.add(null);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => 
        key.startsWith('user_') || 
        key.startsWith('profile_') || 
        key.startsWith('cached_') ||
        key == 'user_id'
      ).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      if (kDebugMode) {
        print('[Auth] Sign up successful for: $email');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Sign up error: $e');
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('[Auth] Sign in successful for: $email');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Sign in error: $e');
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Полностью очищаем сессию Supabase
      await _client.auth.signOut(scope: SignOutScope.global);
      // _clearAllData() will be called automatically via _onAuthStateChanged
      
      if (kDebugMode) {
        print('[Auth] Sign out successful - session cleared globally');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Sign out error: $e');
      }
      // Even if signOut fails, clear local data
      await _clearAllData();
      rethrow;
    }
  }
  
  /// Refresh current profile
  Future<void> refreshProfile() async {
    if (currentUser != null) {
      await _loadProfile(currentUser!.id);
    }
  }
  
  /// Dispose (call on app close if needed)
  void dispose() {
    _authSubscription?.cancel();
    _profileController.close();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      
      if (kDebugMode) {
        print('[Auth] Password reset email sent to: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Password reset error: $e');
      }
      rethrow;
    }
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (kDebugMode) {
        print('[Auth] Password updated successfully');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Password update error: $e');
      }
      rethrow;
    }
  }

  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> data) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(data: data),
      );

      if (kDebugMode) {
        print('[Auth] User metadata updated');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] User metadata update error: $e');
      }
      rethrow;
    }
  }

  /// Check if session is valid
  Future<bool> hasValidSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return false;

      // Check if token is expired
      final expiresAt = session.expiresAt;
      if (expiresAt == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return expiresAt > now;
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Session check error: $e');
      }
      return false;
    }
  }

  /// Refresh session
  Future<AuthResponse?> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      
      if (kDebugMode) {
        print('[Auth] Session refreshed');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Session refresh error: $e');
      }
      return null;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      // Delete user profile (will cascade delete all related data due to FK constraints)
      await _client.from('profiles').delete().eq('id', userId);
      
      // Sign out
      await signOut();

      if (kDebugMode) {
        print('[Auth] Account deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Account deletion error: $e');
      }
      rethrow;
    }
  }
}
