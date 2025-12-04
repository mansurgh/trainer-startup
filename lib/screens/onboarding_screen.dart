import 'package:flutter/material.dart';
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
    
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: AppleComponents.premiumText(
            l10n.welcome,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.name,
                errorText: _name.text.isNotEmpty && _name.text.trim().isEmpty 
                    ? 'Enter name' 
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // Пол
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(labelText: l10n.gender),
              items: [
                DropdownMenuItem(value: 'male', child: Text(l10n.male)),
                DropdownMenuItem(value: 'female', child: Text(l10n.female)),
              ],
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _age,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.age,
                      errorText: _age.text.isNotEmpty && !_isValidAge(_age.text)
                          ? '10-120'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _height,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.height,
                      errorText: _height.text.isNotEmpty && !_isValidHeight(_height.text)
                          ? '100-250'
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n.weight,
                      errorText: _weight.text.isNotEmpty && !_isValidWeight(_weight.text)
                          ? '20-300'
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Цель
            DropdownButtonFormField<String>(
              value: _goal,
              decoration: InputDecoration(labelText: l10n.goal),
              items: [
                DropdownMenuItem(value: 'fat_loss', child: Text(l10n.weightLoss)),
                DropdownMenuItem(value: 'muscle_gain', child: Text(l10n.muscleGain)),
                DropdownMenuItem(value: 'fitness', child: Text(l10n.fitness)),
              ],
              onChanged: (v) => setState(() => _goal = v),
            ),

            const SizedBox(height: 24),
            AppleComponents.premiumButton(
              onPressed: _canContinue
                  ? () async {
                      try {
                        // создаем или обновляем профиль пользователя
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getString('user_id') ?? 'anonymous';
                        
                        final email = prefs.getString('user_email') ?? '';
                        
                        final n = ref.read(userProvider.notifier);
                        await n.createOrUpdateProfile(
                          id: userId, // Используем реальный userId из сессии
                          email: email,
                          name: _name.text.trim(),
                          age: int.tryParse(_age.text),
                          height: int.tryParse(_height.text),
                          weight: double.tryParse(_weight.text),
                          gender: _gender,
                          goal: _goal,
                        );
                        
                        // Синхронизируем с Supabase
                        final user = ref.read(userProvider);
                        if (user != null) {
                          await StorageService.saveUser(user);
                          
                          // Явное обновление в Supabase для надежности
                          try {
                            await SupabaseConfig.client.from('profiles').upsert({
                              'id': userId,
                              'email': email, // Добавляем email, так как он обязателен
                              'name': user.name,
                              'age': user.age,
                              'height': user.height,
                              'weight': user.weight,
                              'gender': user.gender,
                              'goal': user.goal,
                              'updated_at': DateTime.now().toIso8601String(),
                            });
                            print('[Onboarding] ✅ Explicit Supabase sync successful');
                          } catch (e) {
                            print('[Onboarding] ⚠️ Explicit Supabase sync failed: $e');
                          }
                        }

                        // Переход на экран "Составляем программу..."
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const GeneratingProgramScreen()),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          AppAlert.show(
                            context,
                            title: 'Error',
                            description: e.toString(),
                            type: AlertType.error,
                          );
                        }
                      }
                    }
                  : () {
                      AppAlert.show(
                        context,
                        title: 'Incomplete form',
                        description: 'Please fill in all fields',
                        type: AlertType.warning,
                      );
                    },
              child: Text(_canContinue ? l10n.continueButton : 'Fill all fields'),
            ).withAppleFadeIn(delay: const Duration(milliseconds: 800)),
          ],
        ),
      ),
    );
  }
}
