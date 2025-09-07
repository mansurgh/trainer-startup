import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pulsefit_pro/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PulseFit Pro Integration Tests', () {
    testWidgets('Complete onboarding flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify onboarding screen is displayed
      expect(find.text('Добро пожаловать'), findsOneWidget);

      // Fill in user information
      await tester.enterText(find.byType(TextField).at(0), 'Test User');
      await tester.pumpAndSettle();

      // Select gender
      await tester.tap(find.text('Мужской'));
      await tester.pumpAndSettle();

      // Select goal
      await tester.tap(find.text('Фитнес'));
      await tester.pumpAndSettle();

      // Fill age
      await tester.enterText(find.byType(TextField).at(1), '25');
      await tester.pumpAndSettle();

      // Fill height
      await tester.enterText(find.byType(TextField).at(2), '175');
      await tester.pumpAndSettle();

      // Fill weight
      await tester.enterText(find.byType(TextField).at(3), '70');
      await tester.pumpAndSettle();

      // Tap continue button
      await tester.tap(find.text('Продолжить'));
      await tester.pumpAndSettle();

      // Verify main screen is displayed
      expect(find.text('Тренировки'), findsOneWidget);
      expect(find.text('Питание'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('Navigation between tabs', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if present
      if (find.text('Добро пожаловать').evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).at(0), 'Test User');
        await tester.tap(find.text('Мужской'));
        await tester.tap(find.text('Фитнес'));
        await tester.enterText(find.byType(TextField).at(1), '25');
        await tester.enterText(find.byType(TextField).at(2), '175');
        await tester.enterText(find.byType(TextField).at(3), '70');
        await tester.tap(find.text('Продолжить'));
        await tester.pumpAndSettle();
      }

      // Test navigation to Training tab
      await tester.tap(find.text('Тренировки'));
      await tester.pumpAndSettle();
      expect(find.text('Тренировки'), findsOneWidget);

      // Test navigation to Nutrition tab
      await tester.tap(find.text('Питание'));
      await tester.pumpAndSettle();
      expect(find.text('Питание'), findsOneWidget);

      // Test navigation to Profile tab
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('Training tab functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if present
      if (find.text('Добро пожаловать').evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).at(0), 'Test User');
        await tester.tap(find.text('Мужской'));
        await tester.tap(find.text('Фитнес'));
        await tester.enterText(find.byType(TextField).at(1), '25');
        await tester.enterText(find.byType(TextField).at(2), '175');
        await tester.enterText(find.byType(TextField).at(3), '70');
        await tester.tap(find.text('Продолжить'));
        await tester.pumpAndSettle();
      }

      // Navigate to Training tab
      await tester.tap(find.text('Тренировки'));
      await tester.pumpAndSettle();

      // Check if create program button is present
      expect(find.text('Создать программу'), findsOneWidget);

      // Tap create program button
      await tester.tap(find.text('Создать программу'));
      await tester.pumpAndSettle();

      // Wait for program generation (this might take some time)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('Nutrition tab functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if present
      if (find.text('Добро пожаловать').evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).at(0), 'Test User');
        await tester.tap(find.text('Мужской'));
        await tester.tap(find.text('Фитнес'));
        await tester.enterText(find.byType(TextField).at(1), '25');
        await tester.enterText(find.byType(TextField).at(2), '175');
        await tester.enterText(find.byType(TextField).at(3), '70');
        await tester.tap(find.text('Продолжить'));
        await tester.pumpAndSettle();
      }

      // Navigate to Nutrition tab
      await tester.tap(find.text('Питание'));
      await tester.pumpAndSettle();

      // Check if chat with trainer option is present
      expect(find.text('Чат с тренером'), findsOneWidget);

      // Check if upload fridge photo option is present
      expect(find.text('Загрузить фото холодильника'), findsOneWidget);
    });

    testWidgets('Profile tab functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if present
      if (find.text('Добро пожаловать').evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).at(0), 'Test User');
        await tester.tap(find.text('Мужской'));
        await tester.tap(find.text('Фитнес'));
        await tester.enterText(find.byType(TextField).at(1), '25');
        await tester.enterText(find.byType(TextField).at(2), '175');
        await tester.enterText(find.byType(TextField).at(3), '70');
        await tester.tap(find.text('Продолжить'));
        await tester.pumpAndSettle();
      }

      // Navigate to Profile tab
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();

      // Check if profile elements are present
      expect(find.text('ИМТ'), findsOneWidget);
      expect(find.text('Уровень'), findsOneWidget);
      expect(find.text('Прогресс'), findsOneWidget);
      expect(find.text('Состав тела'), findsOneWidget);
      expect(find.text('Физические параметры'), findsOneWidget);
      expect(find.text('Достижения'), findsOneWidget);
      expect(find.text('Быстрые действия'), findsOneWidget);

      // Test settings access
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();
      
      // Check if settings screen opened
      expect(find.text('Настройки'), findsOneWidget);
      
      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });

    testWidgets('Settings screen functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if present
      if (find.text('Добро пожаловать').evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).at(0), 'Test User');
        await tester.tap(find.text('Мужской'));
        await tester.tap(find.text('Фитнес'));
        await tester.enterText(find.byType(TextField).at(1), '25');
        await tester.enterText(find.byType(TextField).at(2), '175');
        await tester.enterText(find.byType(TextField).at(3), '70');
        await tester.tap(find.text('Продолжить'));
        await tester.pumpAndSettle();
      }

      // Navigate to Profile tab
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();

      // Open settings
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();

      // Check settings sections
      expect(find.text('Уведомления'), findsOneWidget);
      expect(find.text('Приватность и данные'), findsOneWidget);
      expect(find.text('Язык и регион'), findsOneWidget);
      expect(find.text('Разрешения'), findsOneWidget);
      expect(find.text('О приложении'), findsOneWidget);

      // Test language selection
      await tester.tap(find.text('Язык'));
      await tester.pumpAndSettle();
      
      // Check language options
      expect(find.text('Русский'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      
      // Select English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Go back to settings
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test about section
      await tester.tap(find.text('О приложении'));
      await tester.pumpAndSettle();
      
      // Check about screen elements
      expect(find.text('PulseFit Pro'), findsOneWidget);
      expect(find.text('Версия 1.0.0'), findsOneWidget);
      expect(find.text('Поддержка'), findsOneWidget);
      
      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });

    testWidgets('Error handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if present
      if (find.text('Добро пожаловать').evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).at(0), 'Test User');
        await tester.tap(find.text('Мужской'));
        await tester.tap(find.text('Фитнес'));
        await tester.enterText(find.byType(TextField).at(1), '25');
        await tester.enterText(find.byType(TextField).at(2), '175');
        await tester.enterText(find.byType(TextField).at(3), '70');
        await tester.tap(find.text('Продолжить'));
        await tester.pumpAndSettle();
      }

      // Test that app doesn't crash with invalid inputs
      // This is a basic smoke test
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
