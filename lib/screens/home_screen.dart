import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tabs/training_tab.dart';
import 'tabs/nutrition_tab.dart';
import 'tabs/profile_tab.dart';
import '../core/theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  // Сделали const, чтобы убрать предупреждение анализатора (B)
  final pages = const [
    TrainingTab(),
    NutritionTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: pages[_index]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fitness_center_rounded),
              label: 'Тренировка',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Питание',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_rounded),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
