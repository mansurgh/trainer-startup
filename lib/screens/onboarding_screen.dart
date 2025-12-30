import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/design_tokens.dart';
import '../core/modern_components.dart';
import '../core/apple_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/user_state.dart';
import '../services/storage_service.dart';
import '../widgets/app_alert.dart';
import 'generating_program_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

import '../l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  String? _gender;
  String? _goal;
  bool _isLoading = false;

  bool get _canContinue =>
      _name.text.trim().isNotEmpty &&
      _gender != null &&
      _goal != null &&
      _age.text.trim().isNotEmpty &&
      _height.text.trim().isNotEmpty &&
      _weight.text.trim().isNotEmpty &&
      _isValidAge(_age.text) &&
      _isValidHeight(_height.text) &&
      _isValidWeight(_weight.text);

  bool _isValidAge(String value) {
    final age = int.tryParse(value);
    return age != null && age >= 10 && age <= 120;
  }

  bool _isValidHeight(String value) {
    final height = int.tryParse(value);
    return height != null && height >= 100 && height <= 250;
  }

  bool _isValidWeight(String value) {
    final weight = double.tryParse(value);
    return weight != null && weight >= 20 && weight <= 300;
  }

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _age.addListener(() => setState(() {}));
    _height.addListener(() => setState(() {}));
    _weight.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            children: [
              // Premium header with logo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo/app_logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ).animate()
               .fadeIn(duration: 600.ms)
               .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                l10n.welcome,
                style: const TextStyle(
                  color: DesignTokens.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ).animate()
               .fadeIn(duration: 600.ms, delay: 100.ms)
               .slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                isRussian 
                    ? 'Расскажите о себе для персональной программы'
                    : 'Tell us about yourself for a personalized program',
                style: TextStyle(
                  color: DesignTokens.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ).animate()
               .fadeIn(duration: 600.ms, delay: 200.ms),
              
              const SizedBox(height: 40),
              
              // Name field
              _buildPremiumTextField(
                controller: _name,
                label: l10n.name,
                icon: Icons.person_outline_rounded,
                delay: 300,
              ),
              const SizedBox(height: 16),

              // Gender dropdown
              _buildPremiumDropdown(
                value: _gender,
                label: l10n.gender,
                icon: Icons.wc_rounded,
                items: [
                  DropdownMenuItem(value: 'male', child: Text(l10n.male)),
                  DropdownMenuItem(value: 'female', child: Text(l10n.female)),
                ],
                onChanged: (v) => setState(() => _gender = v),
                delay: 400,
              ),
              const SizedBox(height: 16),

              // Age and Height row
              Row(
                children: [
                  Expanded(
                    child: _buildPremiumTextField(
                      controller: _age,
                      label: l10n.age,
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      delay: 500,
                      errorText: _age.text.isNotEmpty && !_isValidAge(_age.text)
                          ? '10-120'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPremiumTextField(
                      controller: _height,
                      label: l10n.height,
                      icon: Icons.height_rounded,
                      keyboardType: TextInputType.number,
                      delay: 600,
                      suffix: isRussian ? 'см' : 'cm',
                      errorText: _height.text.isNotEmpty && !_isValidHeight(_height.text)
                          ? '100-250'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Weight field
              _buildPremiumTextField(
                controller: _weight,
                label: l10n.weight,
                icon: Icons.monitor_weight_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                delay: 700,
                suffix: isRussian ? 'кг' : 'kg',
                errorText: _weight.text.isNotEmpty && !_isValidWeight(_weight.text)
                    ? '20-300'
                    : null,
              ),
              const SizedBox(height: 16),

              // Goal dropdown with icons
              _buildGoalSelector(l10n, isRussian),
              
              const SizedBox(height: 32),
              
              // Continue button
              _buildContinueButton(l10n, isRussian),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    TextInputType? keyboardType,
    String? suffix,
    String? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorText != null 
              ? DesignTokens.error.withValues(alpha: 0.5)
              : DesignTokens.cardSurface,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        style: const TextStyle(
          color: DesignTokens.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: DesignTokens.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: DesignTokens.textSecondary, size: 22),
          suffixText: suffix,
          suffixStyle: TextStyle(
            color: DesignTokens.textSecondary,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorText: errorText,
          errorStyle: const TextStyle(fontSize: 11),
        ),
      ),
    ).animate()
     .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay))
     .slideX(begin: -0.05, end: 0);
  }
  
  Widget _buildPremiumDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required int delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.cardSurface, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: DesignTokens.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: DesignTokens.textSecondary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        dropdownColor: DesignTokens.surface,
        style: const TextStyle(
          color: DesignTokens.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        items: items,
        onChanged: onChanged,
      ),
    ).animate()
     .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay))
     .slideX(begin: -0.05, end: 0);
  }
  
  Widget _buildGoalSelector(AppLocalizations l10n, bool isRussian) {
    final goals = [
      {
        'value': 'fat_loss',
        'label': l10n.weightLoss,
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.orange,
      },
      {
        'value': 'muscle_gain',
        'label': l10n.muscleGain,
        'icon': Icons.fitness_center_rounded,
        'color': Colors.blue,
      },
      {
        'value': 'fitness',
        'label': l10n.fitness,
        'icon': Icons.favorite_rounded,
        'color': Colors.green,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.goal,
            style: TextStyle(
              color: DesignTokens.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: goals.map((goal) {
            final isSelected = _goal == goal['value'];
            final color = goal['color'] as Color;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _goal = goal['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: goal != goals.last ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withValues(alpha: 0.15)
                        : DesignTokens.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : DesignTokens.cardSurface,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        goal['icon'] as IconData,
                        color: isSelected ? color : DesignTokens.textSecondary,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal['label'] as String,
                        style: TextStyle(
                          color: isSelected ? color : DesignTokens.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate()
     .fadeIn(duration: 500.ms, delay: 800.ms)
     .slideY(begin: 0.05, end: 0);
  }
  
  Widget _buildContinueButton(AppLocalizations l10n, bool isRussian) {
    return GestureDetector(
      onTap: _isLoading ? null : () async {
        if (!_canContinue) {
          AppAlert.show(
            context,
            title: isRussian ? 'Заполните все поля' : 'Incomplete form',
            description: isRussian 
                ? 'Пожалуйста, заполните все поля'
                : 'Please fill in all fields',
            type: AlertType.warning,
          );
          return;
        }
        
        setState(() => _isLoading = true);
        
        try {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString('user_id') ?? 'anonymous';
          final email = prefs.getString('user_email') ?? '';
          
          final n = ref.read(userProvider.notifier);
          await n.createOrUpdateProfile(
            id: userId,
            email: email,
            name: _name.text.trim(),
            age: int.tryParse(_age.text),
            height: int.tryParse(_height.text),
            weight: double.tryParse(_weight.text),
            gender: _gender,
            goal: _goal,
          );
          
          final user = ref.read(userProvider);
          if (user != null) {
            await StorageService.saveUser(user);
            
            try {
              await SupabaseConfig.client.from('profiles').upsert({
                'id': userId,
                'email': email,
                'name': user.name,
                'age': user.age,
                'height': user.height,
                'weight': user.weight,
                'gender': user.gender,
                'goal': user.goal,
                'updated_at': DateTime.now().toIso8601String(),
              });
            } catch (e) {
              debugPrint('[Onboarding] Supabase sync failed: $e');
            }
          }

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const GeneratingProgramScreen()),
            );
          }
        } catch (e) {
          setState(() => _isLoading = false);
          if (mounted) {
            AppAlert.show(
              context,
              title: 'Error',
              description: e.toString(),
              type: AlertType.error,
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: _canContinue 
              ? LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: _canContinue ? null : DesignTokens.cardSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _canContinue ? [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ] : null,
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  l10n.continueButton,
                  style: TextStyle(
                    color: _canContinue ? Colors.white : DesignTokens.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 600.ms, delay: 900.ms)
     .slideY(begin: 0.1, end: 0);
  }
}
