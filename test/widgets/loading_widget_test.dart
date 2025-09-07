import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsefit_pro/widgets/loading_widget.dart' as custom_widgets;

void main() {
  group('LoadingWidget', () {
    testWidgets('should display loading indicator without message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('should display loading indicator with message', (WidgetTester tester) async {
      const message = 'Loading data...';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.LoadingWidget(message: message),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should display with custom size', (WidgetTester tester) async {
      const size = 60.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.LoadingWidget(size: size),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      
      expect(progressIndicator, isNotNull);
    });

    testWidgets('should display with custom color', (WidgetTester tester) async {
      const color = Colors.red;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.LoadingWidget(color: color),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoadingOverlay', () {
    testWidgets('should show loading overlay when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: custom_widgets.LoadingOverlay(
            isLoading: true,
            loadingMessage: 'Loading...',
            child: Container(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should hide loading overlay when isLoading is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: custom_widgets.LoadingOverlay(
            isLoading: false,
            child: Container(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show child widget when not loading', (WidgetTester tester) async {
      const childText = 'Child Widget';
      
      await tester.pumpWidget(
        MaterialApp(
          home: custom_widgets.LoadingOverlay(
            isLoading: false,
            child: Text(childText),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('ErrorWidget', () {
    testWidgets('should display error message', (WidgetTester tester) async {
      const message = 'Something went wrong';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.ErrorWidget(message: message),
          ),
        ),
      );

      expect(find.text('Упс! Что-то пошло не так'), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided', (WidgetTester tester) async {
      const message = 'Something went wrong';
      bool retryPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.ErrorWidget(
              message: message,
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Попробовать снова'), findsOneWidget);
      
      await tester.tap(find.text('Попробовать снова'));
      expect(retryPressed, isTrue);
    });

    testWidgets('should display custom icon', (WidgetTester tester) async {
      const message = 'Something went wrong';
      const customIcon = Icons.warning;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.ErrorWidget(
              message: message,
              icon: customIcon,
            ),
          ),
        ),
      );

      expect(find.byIcon(customIcon), findsOneWidget);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('should display empty state with title and message', (WidgetTester tester) async {
      const title = 'No data';
      const message = 'There is no data to display';
      const icon = Icons.inbox;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.EmptyStateWidget(
              title: title,
              message: message,
              icon: icon,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('should display action button when provided', (WidgetTester tester) async {
      const title = 'No data';
      const message = 'There is no data to display';
      const icon = Icons.inbox;
      const actionText = 'Add Item';
      bool actionPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.EmptyStateWidget(
              title: title,
              message: message,
              icon: icon,
              onAction: () => actionPressed = true,
              actionText: actionText,
            ),
          ),
        ),
      );

      expect(find.text(actionText), findsOneWidget);
      
      await tester.tap(find.text(actionText));
      expect(actionPressed, isTrue);
    });
  });

  group('RetryButton', () {
    testWidgets('should display retry button with default text', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.RetryButton(
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Попробовать снова'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      
      await tester.tap(find.text('Попробовать снова'));
      expect(pressed, isTrue);
    });

    testWidgets('should display retry button with custom text and icon', (WidgetTester tester) async {
      const customText = 'Try Again';
      const customIcon = Icons.replay;
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom_widgets.RetryButton(
              onPressed: () => pressed = true,
              text: customText,
              icon: customIcon,
            ),
          ),
        ),
      );

      expect(find.text(customText), findsOneWidget);
      expect(find.byIcon(customIcon), findsOneWidget);
      
      await tester.tap(find.text(customText));
      expect(pressed, isTrue);
    });
  });
}
