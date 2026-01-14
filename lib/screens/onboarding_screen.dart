import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/noir_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/user_state.dart';
import '../services/storage_service.dart';
import '../widgets/app_alert.dart';
import 'generating_program_screen.dart';
import '../providers/unit_system_provider.dart';
import '../providers/profile_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

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
    // STRICT RULE: All UI text must use AppLocalizations.of(context)!
    final l10n = AppLocalizations.of(context)!;
    // Use isRussianProvider for locale-specific formatting (units, etc.)
    final isRussian = ref.watch(isRussianProvider);
    
    // Watch unit system for conversion
    final unitSystem = ref.watch(unitSystemProvider);
    final isMetric = unitSystem == UnitSystem.metric;
    
    return Scaffold(
      backgroundColor: kNoirBlack,
      body: Container(
        // Noir Glass: RadialGradient for realistic glass blur visibility
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1A1A1A), // Carbon center - subtle glow
              Color(0xFF0D0D0D), // Near-black
              Color(0xFF000000), // Pure black edges
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
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
                        color: Colors.white.withOpacity(0.1),
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
                style: kNoirDisplayMedium.copyWith(
                  color: kContentHigh,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ).animate()
               .fadeIn(duration: 600.ms, delay: 100.ms)
               .slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 8),
              
              // Use localized string instead of inline language check
              Text(
                l10n.tellUsAboutYourself,
                style: kNoirBodyLarge.copyWith(
                  color: kContentMedium,
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
                      // Dynamic unit based on unit system
                      suffix: isMetric ? l10n.cm : 'in',
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
                // Dynamic unit based on unit system
                suffix: isMetric ? l10n.kg : 'lb',
                errorText: _weight.text.isNotEmpty && !_isValidWeight(_weight.text)
                    ? '20-300'
                    : null,
              ),
              const SizedBox(height: 16),
              
              // Unit System Toggle
              _buildUnitSystemToggle(l10n, isMetric),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            // Noir Glass: Semi-transparent frosted glass effect
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText != null 
                  ? const Color(0xFFF87171).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        style: kNoirBodyLarge.copyWith(color: kContentHigh),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: kNoirBodyMedium.copyWith(color: kContentMedium),
          prefixIcon: Icon(icon, color: kContentMedium, size: 22),
          suffixText: suffix,
          suffixStyle: kNoirBodyMedium.copyWith(color: kContentMedium),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorText: errorText,
          errorStyle: const TextStyle(fontSize: 11),
        ),
      ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            // Noir Glass: Semi-transparent frosted glass effect
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: kNoirBodyMedium.copyWith(color: kContentMedium),
          prefixIcon: Icon(icon, color: kContentMedium, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        dropdownColor: const Color(0xFF1A1A1A),
        style: kNoirBodyLarge.copyWith(color: kContentHigh),
        items: items,
        onChanged: onChanged,
        iconEnabledColor: kContentMedium,
      ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay))
     .slideX(begin: -0.05, end: 0);
  }
  
  Widget _buildUnitSystemToggle(AppLocalizations l10n, bool isMetric) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Noir Glass: Semi-transparent frosted glass effect
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Row(
        children: [
          Icon(Icons.straighten_rounded, color: kContentMedium, size: 22),
          const SizedBox(width: 12),
          Text(
            l10n.unitSystem,
            style: kNoirBodyMedium.copyWith(color: kContentMedium),
          ),
          const Spacer(),
          // Toggle between Metric and Imperial
          Container(
            decoration: BoxDecoration(
              color: kNoirCarbon,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Metric button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(unitSystemStateProvider.notifier).setUnitSystem(UnitSystem.metric);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMetric ? kContentHigh : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'kg/cm',
                      style: kNoirBodySmall.copyWith(
                        color: isMetric ? kNoirBlack : kContentMedium,
                        fontWeight: isMetric ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Imperial button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(unitSystemStateProvider.notifier).setUnitSystem(UnitSystem.imperial);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: !isMetric ? kContentHigh : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'lb/in',
                      style: kNoirBodySmall.copyWith(
                        color: !isMetric ? kNoirBlack : kContentMedium,
                        fontWeight: !isMetric ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 500.ms, delay: 750.ms)
     .slideX(begin: -0.05, end: 0);
  }
  
  Widget _buildGoalSelector(AppLocalizations l10n, bool isRussian) {
    final goals = [
      {
        'value': 'fat_loss',
        'label': l10n.weightLoss,
        'icon': Icons.local_fire_department_rounded,
      },
      {
        'value': 'muscle_gain',
        'label': l10n.muscleGain,
        'icon': Icons.fitness_center_rounded,
      },
      {
        'value': 'fitness',
        'label': l10n.fitness,
        'icon': Icons.favorite_rounded,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.goal,
            style: kNoirBodyMedium.copyWith(color: kContentMedium),
          ),
        ),
        Row(
          children: goals.map((goal) {
            final isSelected = _goal == goal['value'];
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _goal = goal['value'] as String);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: goal != goals.last ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        // Noir Glass: Semi-transparent frosted glass
                        color: isSelected 
                            ? Colors.white.withOpacity(0.12)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            goal['icon'] as IconData,
                            color: isSelected ? kContentHigh : kContentMedium,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goal['label'] as String,
                            style: kNoirBodySmall.copyWith(
                              color: isSelected ? kContentHigh : kContentMedium,
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
            title: l10n.error,
            description: l10n.pleaseFillAllFields,
            type: AlertType.warning,
          );
          return;
        }
        
        setState(() => _isLoading = true);
        
        try {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString('user_id') ?? 'anonymous';
          final email = prefs.getString('user_email') ?? '';
          
          // Parse values
          final name = _name.text.trim();
          final age = int.tryParse(_age.text);
          final height = int.tryParse(_height.text);
          final weight = double.tryParse(_weight.text);
          final gender = _gender;
          final goal = _goal;
          
          // 1. Update legacy userProvider (for backward compatibility)
          final n = ref.read(userProvider.notifier);
          await n.createOrUpdateProfile(
            id: userId,
            email: email,
            name: name,
            age: age,
            height: height,
            weight: weight,
            gender: gender,
            goal: goal,
          );
          
          // 2. Save to StorageService
          final user = ref.read(userProvider);
          if (user != null) {
            await StorageService.saveUser(user);
          }
          
          // 3. Sync to Supabase directly (PRIMARY data source)
          try {
            await SupabaseConfig.client.from('profiles').upsert({
              'id': userId,
              'email': email,
              'name': name,
              'age': age,
              'height': height,
              'weight': weight,
              'gender': gender,
              'goal': goal,
              'updated_at': DateTime.now().toIso8601String(),
            }, onConflict: 'id');
            debugPrint('[Onboarding] ✅ Supabase profile synced');
          } catch (e) {
            debugPrint('[Onboarding] ⚠️ Supabase sync failed: $e');
          }
          
          // 4. CRITICAL: Update profileProvider to sync ProfileScreen
          await ref.read(profileProvider.notifier).updateProfile(
            name: name,
            age: age,
            height: height,
            weight: weight,
            gender: gender,
            goal: goal,
          );
          
          // 5. Force refresh to ensure ProfileScreen gets fresh data
          await ref.read(profileProvider.notifier).refresh();
          
          debugPrint('[Onboarding] ✅ All providers synced');

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
              title: l10n.error,
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
          color: _canContinue ? kContentHigh : kNoirSteel,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _canContinue ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
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
                    valueColor: AlwaysStoppedAnimation(kNoirBlack),
                  ),
                )
              : Text(
                  l10n.continueButton,
                  style: kNoirBodyLarge.copyWith(
                    color: _canContinue ? kNoirBlack : kContentMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 600.ms, delay: 900.ms)
     .slideY(begin: 0.1, end: 0);
  }
}
