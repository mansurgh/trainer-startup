// =============================================================================
// auth_service.dart — Bulletproof Authentication Service
// =============================================================================
// Singleton service managing all authentication flows with:
// - Complete data isolation on signOut (no ghosting)
// - Typed error handling (AuthException)
// - Riverpod provider invalidation support
// - Secure token storage via supabase_flutter
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

// =============================================================================
// AUTH EXCEPTION — Typed error handling
// =============================================================================

/// Typed authentication errors for proper UI handling
enum AuthErrorType {
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  userNotFound,
  emailNotConfirmed,
  tooManyRequests,
  networkError,
  serverError,
  sessionExpired,
  unknown,
}

class AuthException implements Exception {
  const AuthException({
    required this.type,
    required this.message,
    this.originalError,
  });

  final AuthErrorType type;
  final String message;
  final dynamic originalError;

  /// User-friendly message in Russian
  String get userMessageRu {
    switch (type) {
      case AuthErrorType.invalidCredentials:
        return 'Неверный email или пароль';
      case AuthErrorType.emailAlreadyInUse:
        return 'Этот email уже зарегистрирован';
      case AuthErrorType.weakPassword:
        return 'Пароль слишком слабый (минимум 6 символов)';
      case AuthErrorType.userNotFound:
        return 'Пользователь не найден';
      case AuthErrorType.emailNotConfirmed:
        return 'Подтвердите email перед входом';
      case AuthErrorType.tooManyRequests:
        return 'Слишком много попыток. Подождите немного';
      case AuthErrorType.networkError:
        return 'Проверьте подключение к интернету';
      case AuthErrorType.serverError:
        return 'Ошибка сервера. Попробуйте позже';
      case AuthErrorType.sessionExpired:
        return 'Сессия истекла. Войдите снова';
      case AuthErrorType.unknown:
        return 'Произошла ошибка. Попробуйте снова';
    }
  }

  /// User-friendly message in English
  String get userMessageEn {
    switch (type) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid email or password';
      case AuthErrorType.emailAlreadyInUse:
        return 'This email is already registered';
      case AuthErrorType.weakPassword:
        return 'Password is too weak (minimum 6 characters)';
      case AuthErrorType.userNotFound:
        return 'User not found';
      case AuthErrorType.emailNotConfirmed:
        return 'Please confirm your email before signing in';
      case AuthErrorType.tooManyRequests:
        return 'Too many attempts. Please wait';
      case AuthErrorType.networkError:
        return 'Check your internet connection';
      case AuthErrorType.serverError:
        return 'Server error. Try again later';
      case AuthErrorType.sessionExpired:
        return 'Session expired. Please sign in again';
      case AuthErrorType.unknown:
        return 'An error occurred. Please try again';
    }
  }

  /// Get localized message
  String getUserMessage(bool isRussian) => isRussian ? userMessageRu : userMessageEn;

  @override
  String toString() => 'AuthException($type): $message';
}

// =============================================================================
// AUTH RESULT — Success/Failure wrapper
// =============================================================================

/// Result wrapper for auth operations
class AuthResult<T> {
  const AuthResult.success(this.data) : error = null;
  const AuthResult.failure(this.error) : data = null;

  final T? data;
  final AuthException? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

// =============================================================================
// AUTH SERVICE — Singleton Implementation
// =============================================================================

/// Bulletproof authentication service with complete data isolation.
/// 
/// Usage:
/// ```dart
/// final authService = AuthService();
/// final result = await authService.signUp(email: 'test@test.com', password: '123456');
/// if (result.isSuccess) {
///   // Success - user signed up
/// } else {
///   // Show result.error!.getUserMessage(isRussian)
/// }
/// ```
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _client = SupabaseConfig.client;
  final UserRepository _userRepository = UserRepository();
  
  // State management
  StreamSubscription<AuthState>? _authSubscription;
  final _profileController = StreamController<UserModel?>.broadcast();
  UserModel? _currentProfile;
  
  /// Callback for provider invalidation (set from main.dart or provider scope)
  /// This is THE KEY to preventing data ghosting
  VoidCallback? onSignOutCallback;
  
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

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initialize auth service - call in main.dart BEFORE runApp
  Future<void> initialize() async {
    // Listen to auth state changes
    _authSubscription?.cancel();
    _authSubscription = _client.auth.onAuthStateChange.listen(
      _onAuthStateChanged,
      onError: (_) {},  // Silently ignore - offline errors are expected
    );
    
    // Check current session and load profile if exists
    final session = _client.auth.currentSession;
    if (session != null && currentUser != null) {
      await _loadProfile(currentUser!.id);
    }
    
    if (kDebugMode) {
      print('[Auth] ✅ Initialized. User: ${currentUser?.email ?? 'none'}');
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
        
      case AuthChangeEvent.tokenRefreshed:
        // Token refreshed, no action needed
        break;
        
      default:
        break;
    }
  }
  
  /// Load user profile from Supabase
  Future<void> _loadProfile(String userId) async {
    try {
      _currentProfile = await _userRepository.getProfile(userId);
      _profileController.add(_currentProfile);
    } catch (_) {
      _currentProfile = null;
      _profileController.add(null);
    }
  }

  // ===========================================================================
  // SIGN UP — Create new account
  // ===========================================================================

  /// Sign up with email and password.
  /// Returns AuthResult with user data or typed error.
  Future<AuthResult<AuthResponse>> signUp({
    required String email,
    required String password,
    String? name,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || !email.contains('@')) {
        return AuthResult.failure(const AuthException(
          type: AuthErrorType.invalidCredentials,
          message: 'Invalid email format',
        ));
      }
      
      if (password.length < 6) {
        return AuthResult.failure(const AuthException(
          type: AuthErrorType.weakPassword,
          message: 'Password must be at least 6 characters',
        ));
      }

      // Prepare metadata
      final userData = <String, dynamic>{
        if (name != null) 'name': name,
        ...?metadata,
      };

      final response = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: userData.isNotEmpty ? userData : null,
      );

      if (kDebugMode) {
        print('[Auth] ✅ Sign up successful for: $email');
      }

      return AuthResult.success(response);
      
    } on AuthException catch (e) {
      return AuthResult.failure(e);
    } catch (e) {
      final authError = _parseError(e);
      if (kDebugMode) {
        print('[Auth] ❌ Sign up error: $authError');
      }
      return AuthResult.failure(authError);
    }
  }

  // ===========================================================================
  // SIGN IN — Authenticate existing user
  // ===========================================================================

  /// Sign in with email and password.
  /// Returns AuthResult with session data or typed error.
  Future<AuthResult<AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (kDebugMode) {
        print('[Auth] ✅ Sign in successful for: $email');
      }

      return AuthResult.success(response);
      
    } on AuthException catch (e) {
      return AuthResult.failure(e);
    } catch (e) {
      final authError = _parseError(e);
      if (kDebugMode) {
        print('[Auth] ❌ Sign in error: $authError');
      }
      return AuthResult.failure(authError);
    }
  }

  // ===========================================================================
  // SIGN OUT — Complete data cleanup (CRITICAL!)
  // ===========================================================================

  /// Sign out and COMPLETELY clear all user data.
  /// This prevents data ghosting between accounts.
  Future<void> signOut() async {
    if (kDebugMode) {
      print('[Auth] 🔄 Starting sign out...');
    }
    
    try {
      // Step 1: Sign out from Supabase (globally on all devices)
      await _client.auth.signOut(scope: SignOutScope.global);
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] ⚠️ Supabase signOut error (continuing cleanup): $e');
      }
    }
    
    // Step 2: Clear all local data (even if Supabase signOut failed)
    await _clearAllData();
    
    // Step 3: Trigger Riverpod provider invalidation
    // This is THE KEY to preventing data ghosting
    onSignOutCallback?.call();
    
    if (kDebugMode) {
      print('[Auth] ✅ Sign out complete - all data cleared');
    }
  }

  /// Clear all cached/stored user data.
  /// Called on sign out and auth state change.
  Future<void> _clearAllData() async {
    // Clear in-memory profile
    _currentProfile = null;
    _profileController.add(null);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all keys that contain user-specific data
      final keysToRemove = prefs.getKeys().where((key) {
        return key.startsWith('user_') ||
               key.startsWith('profile_') ||
               key.startsWith('cached_') ||
               key.startsWith('workout_') ||
               key.startsWith('nutrition_') ||
               key.startsWith('settings_') ||
               key.startsWith('muscle_') ||
               key.contains('_cache_') ||
               key == 'user_id' ||
               key == 'current_user' ||
               key == 'last_sync';
      }).toList();
      
      // Remove each key
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      
      if (kDebugMode) {
        print('[Auth] 🗑️ Cleared ${keysToRemove.length} cached keys');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] ⚠️ Error clearing SharedPreferences: $e');
      }
    }
  }

  // ===========================================================================
  // PASSWORD RESET
  // ===========================================================================

  /// Send password reset email.
  Future<AuthResult<void>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim().toLowerCase());
      
      if (kDebugMode) {
        print('[Auth] ✅ Password reset email sent to: $email');
      }
      
      return const AuthResult.success(null);
    } catch (e) {
      final authError = _parseError(e);
      return AuthResult.failure(authError);
    }
  }

  /// Update password (requires active session).
  Future<AuthResult<UserResponse>> updatePassword(String newPassword) async {
    try {
      if (newPassword.length < 6) {
        return AuthResult.failure(const AuthException(
          type: AuthErrorType.weakPassword,
          message: 'Password must be at least 6 characters',
        ));
      }
      
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      return AuthResult.success(response);
    } catch (e) {
      return AuthResult.failure(_parseError(e));
    }
  }

  // ===========================================================================
  // SESSION MANAGEMENT
  // ===========================================================================

  /// Check if current session is valid.
  Future<bool> hasValidSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return false;

      final expiresAt = session.expiresAt;
      if (expiresAt == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return expiresAt > now;
    } catch (_) {
      return false;
    }
  }

  /// Refresh session token.
  Future<AuthResult<AuthResponse>> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return AuthResult.success(response);
    } catch (e) {
      return AuthResult.failure(_parseError(e));
    }
  }
  
  /// Refresh profile from database.
  Future<void> refreshProfile() async {
    if (currentUser != null) {
      await _loadProfile(currentUser!.id);
    }
  }

  // ===========================================================================
  // ACCOUNT MANAGEMENT
  // ===========================================================================

  /// Update user metadata.
  Future<AuthResult<UserResponse>> updateUserMetadata(Map<String, dynamic> data) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(data: data),
      );
      return AuthResult.success(response);
    } catch (e) {
      return AuthResult.failure(_parseError(e));
    }
  }

  /// Delete account and all associated data.
  /// WARNING: This is irreversible!
  Future<AuthResult<void>> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        return AuthResult.failure(const AuthException(
          type: AuthErrorType.userNotFound,
          message: 'No user logged in',
        ));
      }

      // Delete profile (cascades to all related data via FK)
      await _client.from('profiles').delete().eq('id', userId);
      
      // Sign out
      await signOut();

      if (kDebugMode) {
        print('[Auth] ✅ Account deleted successfully');
      }
      
      return const AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure(_parseError(e));
    }
  }

  // ===========================================================================
  // ERROR PARSING
  // ===========================================================================

  /// Parse Supabase errors into typed AuthException.
  AuthException _parseError(dynamic error) {
    final message = error.toString().toLowerCase();
    
    // Network errors
    if (message.contains('socket') || 
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return AuthException(
        type: AuthErrorType.networkError,
        message: error.toString(),
        originalError: error,
      );
    }
    
    // Auth-specific errors
    if (error is AuthApiException) {
      final code = error.code?.toLowerCase() ?? '';
      final msg = error.message.toLowerCase();
      
      if (code == 'invalid_credentials' || 
          msg.contains('invalid login credentials')) {
        return AuthException(
          type: AuthErrorType.invalidCredentials,
          message: error.message,
          originalError: error,
        );
      }
      
      if (code == 'user_already_exists' || 
          msg.contains('already registered') ||
          msg.contains('already exists')) {
        return AuthException(
          type: AuthErrorType.emailAlreadyInUse,
          message: error.message,
          originalError: error,
        );
      }
      
      if (msg.contains('weak password') || 
          msg.contains('password should be')) {
        return AuthException(
          type: AuthErrorType.weakPassword,
          message: error.message,
          originalError: error,
        );
      }
      
      if (code == 'email_not_confirmed' || 
          msg.contains('email not confirmed')) {
        return AuthException(
          type: AuthErrorType.emailNotConfirmed,
          message: error.message,
          originalError: error,
        );
      }
      
      if (msg.contains('rate limit') || 
          msg.contains('too many requests')) {
        return AuthException(
          type: AuthErrorType.tooManyRequests,
          message: error.message,
          originalError: error,
        );
      }
    }
    
    // PostgrestException (database errors)
    if (error is PostgrestException) {
      return AuthException(
        type: AuthErrorType.serverError,
        message: error.message,
        originalError: error,
      );
    }
    
    // Unknown error
    return AuthException(
      type: AuthErrorType.unknown,
      message: error.toString(),
      originalError: error,
    );
  }

  // ===========================================================================
  // CLEANUP
  // ===========================================================================

  /// Dispose (call on app close if needed).
  void dispose() {
    _authSubscription?.cancel();
    _profileController.close();
  }
}
