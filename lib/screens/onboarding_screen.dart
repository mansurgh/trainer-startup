import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../models/user_model.dart';
import '../state/app_providers.dart';
import 'home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _form = GlobalKey<FormState>();
  String gender = 'm';
  int age = 20; int height = 175; double weight = 70; String goal = 'muscle_gain';

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('trainer.', style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Создадим профиль и первую программу под твою цель.', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white70)),
              const SizedBox(height: 24),
              Form(key: _form, child: Column(children: [
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(
                    value: gender,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Пол', isDense: true),
                    items: const [
                      DropdownMenuItem(value: 'm', child: Text('Мужской')),
                      DropdownMenuItem(value: 'f', child: Text('Женский')),
                      DropdownMenuItem(value: 'o', child: Text('Другое')),
                    ], onChanged: (v){ if (v!=null) setState(()=>gender=v); },
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(initialValue: '$age', decoration: const InputDecoration(labelText: 'Возраст'), keyboardType: TextInputType.number, onSaved: (v)=>age=int.tryParse(v??'20')??20)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextFormField(initialValue: '$height', decoration: const InputDecoration(labelText: 'Рост (см)'), keyboardType: TextInputType.number, onSaved: (v)=>height=int.tryParse(v??'175')??175)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(initialValue: '$weight', decoration: const InputDecoration(labelText: 'Вес (кг)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), onSaved: (v)=>weight=double.tryParse(v??'70')??70)),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: goal,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Цель тренинга', isDense: true),
                  items: const [
                    DropdownMenuItem(value: 'muscle_gain', child: Text('Набор мышц')),
                    DropdownMenuItem(value: 'fat_loss', child: Text('Снижение жира')),
                    DropdownMenuItem(value: 'endurance', child: Text('Выносливость')),
                  ], onChanged: (v){ if(v!=null) setState(()=>goal=v); },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Создать профиль', icon: Icons.rocket_launch_rounded,
                  onPressed: () async {
                    _form.currentState?.save();
                    final user = UserModel(id: 'u-1', gender: gender, age: age, height: height, weight: weight, goal: goal);
                    ref.read(userProvider.notifier).set(user);

                    await ref.read(planProvider.notifier).loadForToday(user.id);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
                    }
                  },
                ),
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}