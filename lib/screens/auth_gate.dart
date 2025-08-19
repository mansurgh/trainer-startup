import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'onboarding_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Spacer(),
              Text('trainer.', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('ИИ-коуч тренировок и питания', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const Spacer(),
              FilledButton(onPressed: () { /* TODO: логин */ }, child: const Text('Войти в аккаунт')),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen())); },
                child: const Text('Экскурс и регистрация'),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}
