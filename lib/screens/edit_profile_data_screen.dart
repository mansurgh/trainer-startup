import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../state/user_state.dart';

class EditProfileDataScreen extends ConsumerStatefulWidget {
  const EditProfileDataScreen({super.key});
  @override
  ConsumerState<EditProfileDataScreen> createState() => _EditProfileDataScreenState();
}

class _EditProfileDataScreenState extends ConsumerState<EditProfileDataScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _fat = TextEditingController(text: '20');
  final _muscle = TextEditingController(text: '40');

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

  bool _isValidPercentage(String value) {
    final pct = double.tryParse(value);
    return pct != null && pct >= 0 && pct <= 100;
  }

  @override
  void initState() {
    super.initState();
    final u = ref.read(userProvider);
    _name.text = u?.name ?? '';
    _age.text = (u?.age ?? '').toString();
    _height.text = (u?.height ?? '').toString();
    _weight.text = (u?.weight ?? '').toString();
    _fat.text = (u?.bodyFatPct ?? 20).toString();
    _muscle.text = (u?.musclePct ?? 70).toString();
    
    // Добавляем слушатели для валидации
    _name.addListener(() => setState(() {}));
    _age.addListener(() => setState(() {}));
    _height.addListener(() => setState(() {}));
    _weight.addListener(() => setState(() {}));
    _fat.addListener(() => setState(() {}));
    _muscle.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose(); _age.dispose(); _height.dispose(); _weight.dispose();
    _fat.dispose(); _muscle.dispose();
    super.dispose();
  }

  void _save() {
    final notifier = ref.read(userProvider.notifier);
    if (_name.text.trim().isNotEmpty) notifier.setName(_name.text.trim());
    final a = int.tryParse(_age.text);
    final h = int.tryParse(_height.text);
    final w = double.tryParse(_weight.text);
    notifier.setParams(age: a, height: h, weight: w);
    notifier.setComposition(
      fatPct: double.tryParse(_fat.text) ?? 20,
      musclePct: double.tryParse(_muscle.text) ?? 70,
    );
    
    // Показываем уведомление об успешном сохранении
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Данные профиля сохранены!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Возвращаемся в профиль
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Данные профиля')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Field(
              label: 'Имя', 
              controller: _name,
              errorText: _name.text.isNotEmpty && _name.text.trim().isEmpty 
                  ? 'Введите имя' 
                  : null,
            ),
            _Field(
              label: 'Возраст', 
              controller: _age, 
              keyboardType: TextInputType.number,
              errorText: _age.text.isNotEmpty && !_isValidAge(_age.text)
                  ? 'Возраст от 10 до 120 лет'
                  : null,
            ),
            _Field(
              label: 'Рост (см)', 
              controller: _height, 
              keyboardType: TextInputType.number,
              errorText: _height.text.isNotEmpty && !_isValidHeight(_height.text)
                  ? 'Рост от 100 до 250 см'
                  : null,
            ),
            _Field(
              label: 'Вес (кг)', 
              controller: _weight, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              errorText: _weight.text.isNotEmpty && !_isValidWeight(_weight.text)
                  ? 'Вес от 20 до 300 кг'
                  : null,
            ),
            _Field(
              label: 'Жир (%)', 
              controller: _fat, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              errorText: _fat.text.isNotEmpty && !_isValidPercentage(_fat.text)
                  ? 'Процент от 0 до 100'
                  : null,
            ),
            _Field(
              label: 'Мышцы (%)', 
              controller: _muscle, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              errorText: _muscle.text.isNotEmpty && !_isValidPercentage(_muscle.text)
                  ? 'Процент от 0 до 100'
                  : null,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _save, child: const Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label; 
  final TextEditingController controller; 
  final TextInputType? keyboardType;
  final String? errorText;
  
  const _Field({
    required this.label, 
    required this.controller, 
    this.keyboardType,
    this.errorText,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
