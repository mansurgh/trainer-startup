import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_tokens.dart';
import '../services/auth_service.dart';
import '../widgets/app_alert.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(_emailController.text.trim());

      setState(() => _emailSent = true);

      if (mounted) {
        AppAlert.show(
          context,
          title: 'Email sent',
          description: 'Check your inbox for password reset instructions',
          type: AlertType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlert.show(
          context,
          title: 'Failed to send email',
          description: _getErrorMessage(e.toString()),
          type: AlertType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('User not found') || error.contains('not found')) {
      return 'No account found with this email address';
    } else if (error.contains('rate limit')) {
      return 'Too many requests. Please try again later';
    }
    return 'An error occurred. Please try again';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Icon(
                    _emailSent ? Icons.mark_email_read_outlined : Icons.lock_reset,
                    size: 80,
                    color: DesignTokens.textPrimary,
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    _emailSent ? 'Check Your Email' : 'Reset Password',
                    style: DesignTokens.h1.copyWith(fontSize: 32),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    _emailSent
                        ? 'We\'ve sent password reset instructions to ${_emailController.text}'
                        : 'Enter your email address and we\'ll send you instructions to reset your password',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  if (!_emailSent) ...[
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enabled: !_isLoading,
                      style: DesignTokens.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'your@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: DesignTokens.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: DesignTokens.textSecondary.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: DesignTokens.textSecondary.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: DesignTokens.textPrimary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Send Reset Link Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.textPrimary,
                        foregroundColor: DesignTokens.bgBase,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.bgBase),
                              ),
                            )
                          : Text(
                              'Send Reset Link',
                              style: DesignTokens.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: DesignTokens.bgBase,
                              ),
                            ),
                    ),
                  ] else ...[
                    // Resend Button
                    OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _emailSent = false);
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignTokens.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: DesignTokens.textPrimary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Resend Email',
                        style: DesignTokens.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Back to Login Button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.textPrimary,
                        foregroundColor: DesignTokens.bgBase,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Back to Login',
                        style: DesignTokens.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.bgBase,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
