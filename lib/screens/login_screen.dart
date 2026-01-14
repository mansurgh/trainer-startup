// =============================================================================
// login_screen.dart — Noir Glass Login Screen
// =============================================================================
// Strict monochrome design with glass effects
// NO Material blue, NO AppBar
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/noir_theme.dart';
import '../services/auth_service.dart';
import '../services/noir_toast_service.dart';
import '../l10n/app_localizations.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.isSuccess && result.data?.user != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        final previousUserId = prefs.getString('user_id');
        final newUserId = result.data!.user!.id;
        
        if (kDebugMode) print('[Login] Previous user: ${previousUserId ?? "none"}, New user: $newUserId');
        
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
        
        await prefs.setString('user_id', newUserId);
        await prefs.setString('user_email', _emailController.text.trim());
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, _getErrorMessage(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Неверный email или пароль';
    } else if (error.contains('Email not confirmed') || error.contains('email_not_confirmed')) {
      return 'Подтвердите email перед входом';
    } else if (error.contains('Too many requests')) {
      return 'Слишком много попыток. Попробуйте позже';
    }
    return 'Произошла ошибка. Попробуйте снова';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: kNoirBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Noir Glass: RadialGradient background with top light source
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Color(0xFF2A2A2A), // Light source at top for glass visibility
                  Color(0xFF0D0D0D), // Near-black
                  Color(0xFF000000), // Pure black edges
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
          
          // Glass overlay at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(kSpaceLG),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(height: kSpaceLG),
                      
                      // Title
                      Text(
                        l10n.welcomeBack,
                        style: kNoirDisplaySmall.copyWith(
                          color: kContentHigh,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpaceSM),
                      Text(
                        l10n.signInToContinue,
                        style: kNoirBodyLarge.copyWith(color: kContentMedium),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpaceXL),
                      
                      // Email field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'your@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterEmail;
                          }
                          if (!value.contains('@')) {
                            return l10n.enterValidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: kSpaceMD),
                      
                      // Password field
                      _buildTextField(
                        controller: _passwordController,
                        label: l10n.password,
                        hint: '••••••••',
                        icon: Icons.lock_outlined,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: kContentMedium,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterPassword;
                          }
                          if (value.length < 6) {
                            return l10n.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: kSpaceSM),
                      
                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                            l10n.forgotPassword,
                            style: kNoirBodyMedium.copyWith(color: kContentMedium),
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpaceLG),
                      
                      // Login button
                      _buildPrimaryButton(
                        label: l10n.signIn,
                        onPressed: _isLoading ? null : _handleLogin,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: kSpaceLG),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: kBorderLight)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
                            child: Text(
                              l10n.or,
                              style: kNoirBodySmall.copyWith(color: kContentLow),
                            ),
                          ),
                          Expanded(child: Divider(color: kBorderLight)),
                        ],
                      ),
                      const SizedBox(height: kSpaceLG),
                      
                      // Create account button
                      _buildSecondaryButton(
                        label: l10n.createAccount,
                        onPressed: _isLoading ? null : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                      ),
                    ],
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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Cold blue-grey outer glow for "expensive" feel
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.4),
            blurRadius: 60,
            spreadRadius: 10,
          ),
          // White rim light
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 5,
          ),
          // Inner ambient glow
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 150, // 1.5x увеличение (было 100)
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // 3D Glass gradient fill
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x1AFFFFFF), // White 10% at top-left
                  Color(0x0DFFFFFF), // White 5% middle
                  Color(0x33000000), // Black 20% at bottom-right
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/logo/app_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.fitness_center_rounded,
                    size: 64,
                    color: kContentHigh,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusMD),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          autocorrect: false,
          enabled: !_isLoading,
          style: kNoirBodyLarge.copyWith(color: kContentHigh),
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: kNoirBodyMedium.copyWith(color: kContentLow),
            labelStyle: kNoirBodyMedium.copyWith(color: kContentMedium),
            prefixIcon: Icon(icon, color: kContentMedium),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadiusMD),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadiusMD),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadiusMD),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadiusMD),
              borderSide: const BorderSide(color: Color(0xFFF87171)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadiusMD),
              borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
            ),
            errorStyle: kNoirBodySmall.copyWith(color: const Color(0xFFF87171)),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: kDurationFast,
        height: 56,
        decoration: BoxDecoration(
          color: onPressed == null ? kNoirSteel : kContentHigh,
          borderRadius: BorderRadius.circular(kRadiusMD),
          boxShadow: onPressed != null ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(kNoirBlack),
                  ),
                )
              : Text(
                  label,
                  style: kNoirBodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kNoirBlack,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusMD),
          border: Border.all(color: kBorderMedium),
        ),
        child: Center(
          child: Text(
            label,
            style: kNoirBodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: kContentHigh,
            ),
          ),
        ),
      ),
    );
  }
}
