import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/design_tokens.dart';
import '../core/modern_components.dart';
import '../core/apple_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/user_state.dart';
import '../widgets/app_alert.dart';
import 'home_screen.dart';

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
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: AppleComponents.premiumText(
            'Добро пожаловать',
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
                labelText: 'Имя',
                errorText: _name.text.isNotEmpty && _name.text.trim().isEmpty 
                    ? 'Введите имя' 
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // Пол
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Пол'),
              items: const [
                DropdownMenuItem(value: 'm', child: Text('Мужской')),
                DropdownMenuItem(value: 'f', child: Text('Женский')),
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
                      labelText: 'Возраст',
                      errorText: _age.text.isNotEmpty && !_isValidAge(_age.text)
                          ? 'Возраст от 10 до 120 лет'
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
                      labelText: 'Рост (см)',
                      errorText: _height.text.isNotEmpty && !_isValidHeight(_height.text)
                          ? 'Рост от 100 до 250 см'
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
                      labelText: 'Вес (кг)',
                      errorText: _weight.text.isNotEmpty && !_isValidWeight(_weight.text)
                          ? 'Вес от 20 до 300 кг'
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
              decoration: const InputDecoration(labelText: 'Цель'),
              items: const [
                DropdownMenuItem(value: 'fat_loss', child: Text('Похудение')),
                DropdownMenuItem(value: 'muscle_gain', child: Text('Набор массы')),
                DropdownMenuItem(value: 'fitness', child: Text('Поддержание формы')),
              ],
              onChanged: (v) => setState(() => _goal = v),
            ),

            const SizedBox(height: 24),
            AppleComponents.premiumButton(
              onPressed: _canContinue
                  ? () async {
                      try {
                        // создаем или обновляем профиль пользователя
                        final n = ref.read(userProvider.notifier);
                        await n.createOrUpdateProfile(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _name.text.trim(),
                          age: int.tryParse(_age.text),
                          height: int.tryParse(_height.text),
                          weight: double.tryParse(_weight.text),
                          gender: _gender,
                          goal: _goal,
                        );

                        // Переход на главный экран (HomeScreen)
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
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
              child: Text(_canContinue ? 'Продолжить' : 'Заполните все поля'),
            ).withAppleFadeIn(delay: const Duration(milliseconds: 800)),
          ],
        ),
      ),
    );
  }
}
