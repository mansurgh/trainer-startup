// =============================================================================
// login_screen_liquid.dart — Liquid Glass Login Screen
// =============================================================================
// Premium iOS 26 "Liquid Glass" aesthetic login experience:
// - Animated mesh gradient background with floating orbs
// - Glassmorphic input fields with cyan accent focus
// - Gradient buttons with glow effects
// - Smooth transitions and haptic feedback
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/liquid_theme.dart';
import '../widgets/liquid_glass_components.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import '../widgets/app_alert.dart';

class LoginScreenLiquid extends ConsumerStatefulWidget {
  const LoginScreenLiquid({super.key});

  @override
  ConsumerState<LoginScreenLiquid> createState() => _LoginScreenLiquidState();
}

class _LoginScreenLiquidState extends ConsumerState<LoginScreenLiquid>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Reset errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      return;
    }
    if (!_emailController.text.contains('@')) {
      setState(() => _emailError = 'Please enter a valid email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        final previousUserId = prefs.getString('user_id');
        final newUserId = response.user!.id;

        if (kDebugMode) {
          print('[Login] Previous user: ${previousUserId ?? "none"}, New user: $newUserId');
        }

        // Clear previous user data if different user
        if (previousUserId != null && previousUserId != newUserId) {
          if (kDebugMode) print('[Login] Different user detected - clearing previous user data');
          final keys = prefs.getKeys().toList();
          for (final key in keys) {
            if (key.contains('_${previousUserId}_') || key.contains('_$previousUserId')) {
              await prefs.remove(key);
            }
          }
        }

        // Save new user info
        await prefs.setString('user_id', newUserId);
        await prefs.setString('user_email', _emailController.text.trim());

        HapticFeedback.heavyImpact();

        // Navigate to home
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        AppAlert.show(
          context,
          title: 'Login Error',
          description: _getErrorMessage(e.toString()),
          type: AlertType.error,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (error.contains('Email not confirmed') || error.contains('email_not_confirmed')) {
      return 'Please verify your email before logging in.';
    } else if (error.contains('Too many requests')) {
      return 'Too many login attempts. Please try again later';
    }
    return 'An error occurred. Please try again';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLiquidBlack,
      body: Stack(
        children: [
          // Animated mesh background
          const LiquidMeshBackground(
            showOrbs: true,
            intensity: 0.8,
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(kLiquidSpaceLG),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          _buildLogo(),
                          SizedBox(height: kLiquidSpaceXL),

                          // Welcome text
                          _buildWelcomeText(),
                          SizedBox(height: kLiquidSpaceXXL),

                          // Login form card
                          _buildLoginForm(),
                          SizedBox(height: kLiquidSpaceLG),

                          // Forgot password
                          _buildForgotPassword(),
                          SizedBox(height: kLiquidSpaceLG),

                          // Login button
                          _buildLoginButton(),
                          SizedBox(height: kLiquidSpaceLG),

                          // Divider
                          _buildDivider(),
                          SizedBox(height: kLiquidSpaceLG),

                          // Create account button
                          _buildCreateAccountButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Glowing logo container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                kElectricBlue.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: kNeonCyan.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo/app_logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kLiquidPrimaryGradient,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 40,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        // Gradient title
        const LiquidGradientText(
          'Welcome Back',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: kLiquidSpaceSM),
        Text(
          'Sign in to continue your fitness journey',
          style: kLiquidBodyMedium.copyWith(
            color: kLiquidTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return LiquidGlassContainer(
      padding: EdgeInsets.all(kLiquidSpaceLG),
      borderRadius: BorderRadius.circular(kLiquidRadiusXL),
      opacity: kGlassOpacityLight,
      blur: kLiquidBlurMedium,
      child: Column(
        children: [
          // Email field
          LiquidGlassTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'your@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            errorText: _emailError,
            onChanged: (_) {
              if (_emailError != null) {
                setState(() => _emailError = null);
              }
            },
          ),
          SizedBox(height: kLiquidSpaceMD),

          // Password field
          LiquidGlassTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outlined,
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            errorText: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword 
                    ? Icons.visibility_outlined 
                    : Icons.visibility_off_outlined,
                color: kLiquidTextTertiary,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _isLoading
            ? null
            : () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                );
              },
        child: Text(
          'Forgot Password?',
          style: kLiquidBodySmall.copyWith(
            color: kNeonCyan,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return LiquidGlassButton(
      onPressed: _handleLogin,
      enabled: !_isLoading,
      isLoading: _isLoading,
      variant: LiquidButtonVariant.primary,
      height: 56,
      borderRadius: BorderRadius.circular(kLiquidRadiusMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sign In',
            style: kLiquidButton.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!_isLoading) ...[
            SizedBox(width: kLiquidSpaceSM),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.15),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: kLiquidSpaceMD),
          child: Text(
            'or',
            style: kLiquidBodySmall.copyWith(
              color: kLiquidTextTertiary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return LiquidGlassButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      },
      enabled: !_isLoading,
      variant: LiquidButtonVariant.ghost,
      height: 56,
      borderRadius: BorderRadius.circular(kLiquidRadiusMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_add_outlined,
            color: kNeonCyan,
            size: 20,
          ),
          SizedBox(width: kLiquidSpaceSM),
          Text(
            'Create Account',
            style: kLiquidButton.copyWith(
              color: kNeonCyan,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
