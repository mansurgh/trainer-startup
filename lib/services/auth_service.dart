import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Authentication Service for Supabase
/// Handles sign up, sign in, sign out, password reset, etc.
class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user ID
  String? get userId => currentUser?.id;

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

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
      
      if (kDebugMode) {
        print('[Auth] Sign out successful - session cleared globally');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Sign out error: $e');
      }
      rethrow;
    }
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
