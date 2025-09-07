import 'package:flutter_test/flutter_test.dart';
import 'package:pulsefit_pro/services/storage_service.dart';
import 'package:pulsefit_pro/models/user_model.dart';
import 'package:pulsefit_pro/models/daily_plan_model.dart';
import 'package:pulsefit_pro/models/exercise.dart';

void main() {
  group('StorageService', () {
    setUp(() async {
      // Clear any existing data before each test
      await StorageService.clearAllData();
    });

    group('User data', () {
      test('should save and retrieve user data', () async {
        final user = UserModel(
          id: 'test_id',
          name: 'Test User',
          age: 25,
          height: 175,
          weight: 70.0,
          gender: 'm',
          goal: 'fitness',
          bodyImagePath: '/path/to/image.jpg',
          bodyFatPct: 15.0,
          musclePct: 45.0,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await StorageService.saveUser(user);
        final retrievedUser = await StorageService.getUser();

        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.id, equals(user.id));
        expect(retrievedUser.name, equals(user.name));
        expect(retrievedUser.age, equals(user.age));
        expect(retrievedUser.height, equals(user.height));
        expect(retrievedUser.weight, equals(user.weight));
        expect(retrievedUser.gender, equals(user.gender));
        expect(retrievedUser.goal, equals(user.goal));
        expect(retrievedUser.bodyImagePath, equals(user.bodyImagePath));
        expect(retrievedUser.bodyFatPct, equals(user.bodyFatPct));
        expect(retrievedUser.musclePct, equals(user.musclePct));
      });

      test('should return null when no user data exists', () async {
        final user = await StorageService.getUser();
        expect(user, isNull);
      });

      test('should update existing user data', () async {
        final user1 = UserModel(
          id: 'test_id',
          name: 'Test User',
          age: 25,
        );

        final user2 = UserModel(
          id: 'test_id',
          name: 'Updated User',
          age: 26,
        );

        await StorageService.saveUser(user1);
        await StorageService.saveUser(user2);
        
        final retrievedUser = await StorageService.getUser();
        
        expect(retrievedUser!.name, equals('Updated User'));
        expect(retrievedUser.age, equals(26));
      });
    });

    group('Workout plan', () {
      test('should save and retrieve workout plan', () async {
        final plan = DailyPlanModel(
          id: 'plan_1',
          userId: 'user_1',
          date: DateTime.now(),
          workoutDone: false,
          proteinLeft: 50,
          supplementsLeft: ['Vitamin D3'],
          targetProtein: 120,
          targetSupplements: ['Vitamin D3', 'Creatine'],
        );

        await StorageService.saveWorkoutPlan(plan);
        final retrievedPlan = await StorageService.getWorkoutPlan();

        expect(retrievedPlan, isNotNull);
        expect(retrievedPlan!.id, equals(plan.id));
        expect(retrievedPlan.userId, equals(plan.userId));
        expect(retrievedPlan.workoutDone, equals(plan.workoutDone));
        expect(retrievedPlan.proteinLeft, equals(plan.proteinLeft));
      });

      test('should return null when no workout plan exists', () async {
        final plan = await StorageService.getWorkoutPlan();
        expect(plan, isNull);
      });
    });

    group('Exercises', () {
      test('should save and retrieve exercises', () async {
        final exercises = [
          Exercise(
            id: '1',
            name: 'Push-ups',
            videoUrl: 'https://example.com/video1',
            imageUrl: 'https://example.com/image1',
          ),
          Exercise(
            id: '2',
            name: 'Squats',
            videoUrl: 'https://example.com/video2',
            imageUrl: 'https://example.com/image2',
          ),
        ];

        await StorageService.saveExercises(exercises);
        final retrievedExercises = await StorageService.getExercises();

        expect(retrievedExercises.length, equals(2));
        expect(retrievedExercises[0].name, equals('Push-ups'));
        expect(retrievedExercises[1].name, equals('Squats'));
      });

      test('should return empty list when no exercises exist', () async {
        final exercises = await StorageService.getExercises();
        expect(exercises, isEmpty);
      });
    });

    group('Progress tracking', () {
      test('should save and retrieve progress history', () async {
        final date = DateTime.now();
        
        await StorageService.saveProgress(
          date: date,
          weight: 70.0,
          bodyFat: 15.0,
          muscleMass: 45.0,
          notes: 'Feeling good',
        );

        final progressHistory = await StorageService.getProgressHistory();
        
        expect(progressHistory.length, equals(1));
        expect(progressHistory[0]['weight'], equals(70.0));
        expect(progressHistory[0]['body_fat'], equals(15.0));
        expect(progressHistory[0]['muscle_mass'], equals(45.0));
        expect(progressHistory[0]['notes'], equals('Feeling good'));
      });
    });

    group('Workout sessions', () {
      test('should save and retrieve workout sessions', () async {
        final date = DateTime.now();
        
        await StorageService.saveWorkoutSession(
          date: date,
          exerciseName: 'Push-ups',
          sets: 3,
          reps: 10,
          weight: 0.0,
          duration: 30,
          completed: true,
        );

        final sessions = await StorageService.getWorkoutSessions();
        
        expect(sessions.length, equals(1));
        expect(sessions[0]['exercise_name'], equals('Push-ups'));
        expect(sessions[0]['sets'], equals(3));
        expect(sessions[0]['reps'], equals(10));
        expect(sessions[0]['completed'], equals(1));
      });
    });

    group('Settings', () {
      test('should save and retrieve settings', () async {
        final settings = {
          'notifications_enabled': true,
          'data_sharing_enabled': false,
          'analytics_enabled': true,
          'language': 'ru',
        };

        await StorageService.saveSettings(settings);
        final retrievedSettings = await StorageService.getSettings();

        expect(retrievedSettings['notifications_enabled'], isTrue);
        expect(retrievedSettings['data_sharing_enabled'], isFalse);
        expect(retrievedSettings['analytics_enabled'], isTrue);
        expect(retrievedSettings['language'], equals('ru'));
      });

      test('should return empty map when no settings exist', () async {
        final settings = await StorageService.getSettings();
        expect(settings, isEmpty);
      });
    });

    group('Clear all data', () {
      test('should clear all data', () async {
        // Save some data
        final user = UserModel(id: 'test_id', name: 'Test User');
        await StorageService.saveUser(user);
        
        final plan = DailyPlanModel(
          id: 'plan_1',
          userId: 'user_1',
          date: DateTime.now(),
        );
        await StorageService.saveWorkoutPlan(plan);
        
        await StorageService.saveSettings({'test': 'value'});

        // Verify data exists
        expect(await StorageService.getUser(), isNotNull);
        expect(await StorageService.getWorkoutPlan(), isNotNull);
        expect(await StorageService.getSettings(), isNotEmpty);

        // Clear all data
        await StorageService.clearAllData();

        // Verify data is cleared
        expect(await StorageService.getUser(), isNull);
        expect(await StorageService.getWorkoutPlan(), isNull);
        expect(await StorageService.getSettings(), isEmpty);
      });
    });
  });
}
