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
  final _muscle = TextEditingController(text: '70');

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
            _Field(label: 'Имя', controller: _name),
            _Field(label: 'Возраст', controller: _age, keyboardType: TextInputType.number),
            _Field(label: 'Рост (см)', controller: _height, keyboardType: TextInputType.number),
            _Field(label: 'Вес (кг)', controller: _weight, keyboardType: TextInputType.number),
            _Field(label: 'Жир (%)', controller: _fat, keyboardType: TextInputType.number),
            _Field(label: 'Мышцы (%)', controller: _muscle, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            FilledButton(onPressed: _save, child: const Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label; final TextEditingController controller; final TextInputType? keyboardType;
  const _Field({required this.label, required this.controller, this.keyboardType});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
