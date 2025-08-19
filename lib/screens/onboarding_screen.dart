import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'body_scan_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  String? _gender; // 'm'|'f'
  String? _goal;   // 'fat_loss'|'muscle_gain'|'fitness'

  bool get _canContinue =>
      _name.text.trim().isNotEmpty &&
      _age.text.trim().isNotEmpty &&
      _height.text.trim().isNotEmpty &&
      _weight.text.trim().isNotEmpty &&
      _gender != null &&
      _goal != null;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _age, _height, _weight]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _age, _height, _weight]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Профиль')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Имя'),
            ),
            const SizedBox(height: 12),

            // Пол — выпадающий список
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
                    decoration: const InputDecoration(labelText: 'Возраст'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _height,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Рост (см)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'Вес (кг)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Цель — выпадающий список
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

            const SizedBox(height: 20),
            FilledButton(
              onPressed: _canContinue
                  ? () async {
                      // открываем загрузку фото тела; закрытие — крестиком
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BodyScanScreen()),
                      );
                    }
                  : null,
              child: const Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }
}
