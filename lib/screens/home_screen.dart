import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'tabs/training_tab.dart';
import 'tabs/nutrition_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = const [TrainingTab(), NutritionTab(), ProfileTab()];
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: pages[index]),
        bottomNavigationBar: NavigationBar(
          height: 72,
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.fitness_center_rounded), label: 'Тренировка'),
            NavigationDestination(icon: Icon(Icons.restaurant_rounded), label: 'Питание'),
            NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
          ],
        ),
      ),
    );
  }
}