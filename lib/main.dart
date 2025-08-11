import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PulseFitProApp()));
}

class PulseFitProApp extends StatelessWidget {
  const PulseFitProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PulseFit Pro',
      theme: buildTheme(),
      home: const OnboardingScreen(),
    );
  }
}