import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../theme/noir_theme.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/noir_toast_service.dart';
import '../config/supabase_config.dart';
import '../l10n/app_localizations.dart';
import 'trial_roulette_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      NoirToast.warning(context, l10n.pleaseFillAllFields);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) print('[Register] Attempting to sign up: ${_emailController.text.trim()}');
      
      final result = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (kDebugMode) print('[Register] Sign up response: ${result.data?.user?.id}');

      if (result.isSuccess && result.data?.user != null && mounted) {
        final userId = result.data!.user!.id;
        
        // Save user ID and email to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        await prefs.setString('user_email', _emailController.text.trim());
        
        // Clear all previous user data for fresh start
        await StorageService.clearNewUserData();
        
        // Создаём профиль в Supabase с базовыми данными (upsert для безопасности)
        try {
          await SupabaseConfig.client.from('profiles').upsert({
            'id': userId,
            'email': _emailController.text.trim(),
            'name': 'Атлет', // Дефолтное имя для нового пользователя
            'subscription_status': 'trial',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id');
          if (kDebugMode) print('[Register] ✅ Created profile in Supabase');
        } catch (e) {
          if (kDebugMode) print('[Register] ⚠️ Profile creation error: $e');
          // Не прерываем поток — ProfileNotifier создаст профиль при первом обращении
        }
        
        // Navigate to roulette screen for trial
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TrialRouletteScreen()),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) print('[Register] Error: $e');
      if (kDebugMode) print('[Register] Stack trace: $stackTrace');
      
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
    if (error.contains('already registered') || error.contains('already exists') || error.contains('already been registered')) {
      return 'This email is already registered. Try logging in instead';
    } else if (error.contains('Invalid email')) {
      return 'Please enter a valid email address';
    } else if (error.contains('Password')) {
      return 'Password must be at least 6 characters';
    } else if (error.contains('rate limit')) {
      return 'Too many attempts. Please try again later';
    } else if (error.contains('User')) {
      return 'Unable to create user account. Please try again';
    } else if (error.contains('Database') || error.contains('Storage')) {
      return 'Database error. Please try again';
    }
    // Показываем часть реальной ошибки для отладки
    final shortError = error.length > 100 ? error.substring(0, 100) : error;
    return 'Error: $shortError';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: kNoirBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Noir Glass: RadialGradient background with top light source (matching Login)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Color(0xFF2A2A2A), // Light source at top
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: kSpaceLG,
                right: kSpaceLG,
                top: kToolbarHeight, // Space for back button
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    kToolbarHeight,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: kSpaceLG),
                      // Logo with Glass Glow (matching Login)
                      _buildLogo(),
                      const SizedBox(height: kSpaceLG),
                      Text(
                        l10n.createAccount,
                        style: kNoirDisplaySmall.copyWith(color: kContentHigh),
                        textAlign: TextAlign.center,
                      ),
                  const SizedBox(height: kSpaceSM),
                  Text(
                    l10n.signInToContinue,
                    style: kNoirBodyMedium.copyWith(
                      color: kContentMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpaceXL),

                  // Email Field
                  _buildNoirTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    labelText: l10n.email,
                    hintText: 'your@email.com',
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterEmail;
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return l10n.enterValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kSpaceMD),

                  // Password Field
                  _buildNoirTextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !_isLoading,
                    labelText: l10n.password,
                    hintText: '••••••••',
                    icon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: kContentMedium,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
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
                  const SizedBox(height: kSpaceMD),

                  // Confirm Password Field
                  _buildNoirTextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    enabled: !_isLoading,
                    labelText: l10n.confirmPassword,
                    hintText: '••••••••',
                    icon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: kContentMedium,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterPassword;
                      }
                      if (value != _passwordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kSpaceMD),

                  // Terms & Conditions Checkbox — Noir Glass Style
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                setState(() => _acceptedTerms = !_acceptedTerms);
                              },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _acceptedTerms ? kContentHigh : Colors.transparent,
                            border: Border.all(
                              color: _acceptedTerms ? kContentHigh : kContentMedium,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _acceptedTerms
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: kNoirBlack,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: kSpaceSM),
                      Expanded(
                        child: GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _acceptedTerms = !_acceptedTerms);
                                },
                          child: Text(
                            'I accept the Terms & Conditions and Privacy Policy',
                            style: kNoirBodySmall.copyWith(
                              color: kContentMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpaceLG),

                  // Register Button — Noir Primary
                  GestureDetector(
                    onTap: _isLoading ? null : _handleRegister,
                    child: AnimatedContainer(
                      duration: kDurationFast,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isLoading ? kNoirSteel : kContentHigh,
                        borderRadius: BorderRadius.circular(kRadiusMD),
                        boxShadow: !_isLoading ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(kNoirBlack),
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: kNoirBodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: kNoirBlack,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpaceMD),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: kNoirBodySmall.copyWith(
                          color: kContentMedium,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                if (Navigator.canPop(context)) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pushReplacementNamed('/login');
                                }
                              },
                        child: Text(
                          l10n.signIn,
                          style: kNoirBodySmall.copyWith(
                            color: kContentHigh,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpaceXXL),
                ],
              ),
            ),
          ),
        ),
          ),
          
          // Floating back button
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: kContentHigh),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Noir Glass TextField with BackdropFilter (matching Login)
  Widget _buildNoirTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusMD),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          autocorrect: false,
          obscureText: obscureText,
          enabled: enabled,
          style: kNoirBodyLarge.copyWith(color: kContentHigh),
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            // FIX: Larger label with floating behavior to prevent cutoff
            labelStyle: kNoirBodyLarge.copyWith(color: kContentMedium),
            floatingLabelStyle: kNoirBodyMedium.copyWith(
              color: kContentHigh,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: kNoirBodyMedium.copyWith(color: kContentLow),
            prefixIcon: Icon(icon, color: kContentMedium),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            // FIX: Increased vertical padding to prevent text cutoff
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
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
          validator: validator,
        ),
      ),
    );
  }

  /// Logo with Glass Container and Glow (matching Login)
  Widget _buildLogo() {
    return Center(
      child: Container(
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
      ),
    );
  }
}
