// =============================================================================
// auth_provider.dart — Riverpod Auth State Management
// =============================================================================
// Provides:
// - Global auth state with loading/authenticated/unauthenticated states
// - Auto-refresh on auth events
// - Provider invalidation on signOut to prevent data ghosting
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, User, AuthChangeEvent;
import '../services/auth_service.dart';
import 'profile_provider.dart';
import 'stats_provider.dart';
import 'muscle_fatigue_provider.dart';
import '../state/user_state.dart';
import '../state/nutrition_goals_state.dart';
import '../state/fridge_state.dart';
import '../state/plan_state.dart';
import '../state/activity_state.dart';

// =============================================================================
// AUTH STATE — Immutable state container
// =============================================================================

/// Auth status enum (prefixed to avoid Supabase conflict)
enum AppAuthStatus {
  /// Initial state, checking session
  loading,
  
  /// User is authenticated
  authenticated,
  
  /// User is not authenticated
  unauthenticated,
  
  /// Error during auth check
  error,
}

/// App auth state (named to avoid Supabase AuthState conflict)
@immutable
class AppAuthState {
  const AppAuthState({
    this.status = AppAuthStatus.loading,
    this.user,
    this.error,
  });

  final AppAuthStatus status;
  final User? user;
  final String? error;

  bool get isLoading => status == AppAuthStatus.loading;
  bool get isAuthenticated => status == AppAuthStatus.authenticated;
  bool get isUnauthenticated => status == AppAuthStatus.unauthenticated;
  bool get hasError => status == AppAuthStatus.error;
  
  String? get userId => user?.id;
  String? get email => user?.email;

  AppAuthState copyWith({
    AppAuthStatus? status,
    User? user,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// =============================================================================
// AUTH NOTIFIER — StateNotifier for auth state
// =============================================================================

class AuthNotifier extends StateNotifier<AppAuthState> {
  AuthNotifier(this._ref) : super(const AppAuthState()) {
    _initialize();
  }

  final Ref _ref;
  StreamSubscription<supabase.AuthState>? _authSubscription;
  final _authService = AuthService();

  /// Initialize and start listening to auth changes
  Future<void> _initialize() async {
    // Set loading state
    state = const AppAuthState(status: AppAuthStatus.loading);
    
    // Setup auth listener
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      _onAuthStateChanged,
      onError: (error) {
        if (kDebugMode) {
          print('[AuthProvider] ❌ Auth stream error: $error');
        }
      },
    );
    
    // Check initial session
    await _checkCurrentSession();
  }

  /// Check current session on startup
  Future<void> _checkCurrentSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;
      
      if (session != null && user != null) {
        state = AppAuthState(
          status: AppAuthStatus.authenticated,
          user: user,
        );
        if (kDebugMode) {
          print('[AuthProvider] ✅ Session found: ${user.email}');
        }
      } else {
        state = const AppAuthState(status: AppAuthStatus.unauthenticated);
        if (kDebugMode) {
          print('[AuthProvider] ℹ️ No active session');
        }
      }
    } catch (e) {
      state = AppAuthState(
        status: AppAuthStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Handle Supabase auth state changes
  void _onAuthStateChanged(supabase.AuthState authState) {
    final event = authState.event;
    final session = authState.session;
    final user = session?.user;

    if (kDebugMode) {
      print('[AuthProvider] 🔄 Auth event: $event');
    }

    switch (event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
        if (user != null) {
          state = AppAuthState(
            status: AppAuthStatus.authenticated,
            user: user,
          );
        }
        break;
        
      case AuthChangeEvent.signedOut:
        // Clear state
        state = const AppAuthState(status: AppAuthStatus.unauthenticated);
        // Invalidate all user-related providers
        _invalidateAllProviders();
        break;
        
      case AuthChangeEvent.initialSession:
        if (user != null) {
          state = AppAuthState(
            status: AppAuthStatus.authenticated,
            user: user,
          );
        } else {
          state = const AppAuthState(status: AppAuthStatus.unauthenticated);
        }
        break;
        
      default:
        break;
    }
  }

  /// Invalidate all user-related providers on sign out.
  /// THIS IS THE KEY TO PREVENTING DATA GHOSTING!
  void _invalidateAllProviders() {
    try {
      // Core profile & stats
      _ref.invalidate(profileProvider);
      _ref.invalidate(statsProvider);
      _ref.invalidate(muscleFatigueProvider);
      
      // User state
      _ref.invalidate(userProvider);
      
      // Nutrition
      _ref.invalidate(nutritionGoalsProvider);
      _ref.invalidate(fridgeProvider);
      
      // Workout planning
      _ref.invalidate(planProvider);
      
      // Activity tracking
      _ref.invalidate(activityDataProvider);
      _ref.invalidate(workoutCountProvider);
      _ref.invalidate(todaysWinProvider);
      _ref.invalidate(consistencyStreakProvider);
      
      if (kDebugMode) {
        print('[AuthProvider] 🗑️ All user providers invalidated (12 providers)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AuthProvider] ⚠️ Error invalidating providers: $e');
      }
    }
  }

  /// Sign out and clear all data
  Future<void> signOut() async {
    state = state.copyWith(status: AppAuthStatus.loading);
    
    try {
      await _authService.signOut();
      state = const AppAuthState(status: AppAuthStatus.unauthenticated);
      _invalidateAllProviders();
    } catch (e) {
      // Even on error, force unauthenticated state
      state = const AppAuthState(status: AppAuthStatus.unauthenticated);
      _invalidateAllProviders();
    }
  }

  /// Refresh auth state
  Future<void> refresh() async {
    await _checkCurrentSession();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Main auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier(ref);
});

/// Convenience provider for auth status only
final authStatusProvider = Provider<AppAuthStatus>((ref) {
  return ref.watch(authProvider).status;
});

/// Convenience provider for checking if authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Convenience provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});

/// Convenience provider for current user email
final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).email;
});
