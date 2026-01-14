// =============================================================================
// auth_wrapper.dart — App Entry Point with Auth State Handling
// =============================================================================
// Handles:
// - Loading state while checking session
// - Routing to login/home based on auth state
// - Profile preloading BEFORE showing HomeScreen
// - 7-Day Trial Lock: redirects to HardPaywallScreen if trial expired
// - Smooth transitions between states
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/stats_provider.dart';
import '../theme/noir_theme.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/hard_paywall_screen.dart';
import '../services/profile_service.dart';

/// Wrapper widget that handles auth state and shows appropriate screen.
/// 
/// KEY FIX: Profile is preloaded BEFORE rendering HomeScreen to prevent
/// "Guest" flashing on Profile tab.
/// 
/// Usage in main.dart:
/// ```dart
/// home: const AuthWrapper(),
/// ```
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);

    return AnimatedSwitcher(
      duration: kDurationMedium,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _buildContent(authState, profileState, ref),
    );
  }

  Widget _buildContent(AppAuthState authState, ProfileState profileState, WidgetRef ref) {
    switch (authState.status) {
      case AppAuthStatus.loading:
        return const _LoadingScreen(key: ValueKey('loading'));
        
      case AppAuthStatus.authenticated:
        // KEY FIX: Wait for profile to be initialized before showing HomeScreen
        // This prevents "Guest" flashing on Profile tab
        if (!profileState.isInitialized || (profileState.isLoading && !profileState.hasProfile)) {
          // Trigger profile load if not yet initialized
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!profileState.isInitialized) {
              ref.read(profileProvider.notifier).refresh();
              ref.read(statsProvider.notifier).loadStats();
            }
          });
          return const _LoadingScreen(key: ValueKey('profile_loading'));
        }
        
        // =====================================================================
        // 7-DAY TRIAL LOCK: Check if trial has expired
        // =====================================================================
        final profile = profileState.profile;
        if (profile != null && profile.createdAt != null) {
          final daysSinceSignup = DateTime.now().difference(profile.createdAt!).inDays;
          
          // Check if trial expired (7+ days) and user is not premium
          if (daysSinceSignup >= 7) {
            // Use FutureBuilder to check premium status asynchronously
            return FutureBuilder<bool>(
              future: ProfileService().isPremium(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingScreen(key: ValueKey('premium_check'));
                }
                
                final isPremium = snapshot.data ?? false;
                if (!isPremium) {
                  if (kDebugMode) {
                    print('[AuthWrapper] 🔒 Trial expired ($daysSinceSignup days). Showing paywall.');
                  }
                  return const HardPaywallScreen(key: ValueKey('paywall'));
                }
                
                // Premium user - allow access
                return const HomeScreen(key: ValueKey('home'));
              },
            );
          }
        }
        
        return const HomeScreen(key: ValueKey('home'));
        
      case AppAuthStatus.unauthenticated:
      case AppAuthStatus.error:
        return const LoginScreen(key: ValueKey('login'));
    }
  }
}

/// Premium loading screen shown while checking auth session.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNoirBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo from assets
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kContentHigh.withOpacity(0.2),
                      kContentHigh.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: kBorderLight,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/logo/app_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.fitness_center_rounded,
                        size: 40,
                        color: kContentHigh,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: kSpaceLG),
              
              // Loading indicator
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kContentMedium,
                ),
              ),
              
              const SizedBox(height: kSpaceMD),
              
              // Loading text
              Text(
                'Загрузка...',
                style: kNoirBodyMedium.copyWith(
                  color: kContentLow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alternative: Stateful loading screen with animation
class AnimatedLoadingScreen extends StatefulWidget {
  const AnimatedLoadingScreen({super.key});

  @override
  State<AnimatedLoadingScreen> createState() => _AnimatedLoadingScreenState();
}

class _AnimatedLoadingScreenState extends State<AnimatedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNoirBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kContentHigh.withOpacity(0.15),
                        kNoirCarbon,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kContentHigh.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 48,
                    color: kContentHigh,
                  ),
                ),
                
                const SizedBox(height: kSpaceXL),
                
                // App name
                Text(
                  'TRAINER',
                  style: kNoirDisplaySmall.copyWith(
                    letterSpacing: 8,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const SizedBox(height: kSpaceSM),
                
                Text(
                  'AI Fitness Coach',
                  style: kNoirBodySmall.copyWith(
                    color: kContentLow,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
