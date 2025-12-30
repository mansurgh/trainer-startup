import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOledBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Spacer(),
            Text('trainer.', textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.w900,
                color: kTextPrimary,
              )),
            const SizedBox(height: 8),
            const Text('ИИ-коуч тренировок и питания', textAlign: TextAlign.center, style: TextStyle(color: kTextSecondary)),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              style: FilledButton.styleFrom(
                backgroundColor: kElectricAmberStart,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Войти в аккаунт', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen())); },
              style: OutlinedButton.styleFrom(
                foregroundColor: kTextPrimary,
                side: const BorderSide(color: kObsidianBorder),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Экскурс и регистрация'),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
