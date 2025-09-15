import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tabs/nutrition_tab.dart';
import 'tabs/modern_profile_tab.dart';
import 'modern_workout_screen.dart';
import '../core/theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0}); // Тренировка - первая страница

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
  }

  // Сделали const, чтобы убрать предупреждение анализатора (B)
  final pages = const [
    ModernWorkoutScreen(), // Тренировка - главная страница
    NutritionTab(),
    ModernProfileTab(),
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
