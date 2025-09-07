import 'package:flutter_test/flutter_test.dart';
import 'package:pulsefit_pro/services/ai_service.dart';
import 'package:pulsefit_pro/models/ai_response.dart';
import 'package:pulsefit_pro/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('AIService', () {
    late AIService aiService;

    setUpAll(() async {
      // Initialize dotenv for tests with empty values
      dotenv.testLoad(fileInput: "OPENAI_API_KEY=");
    });

    setUp(() {
      aiService = AIService();
    });

    group('getResponse', () {
      test('should return fallback response when API key is null', () async {
        final response = await aiService.getResponse('Test message');
        
        expect(response.type, AIResponseType.general);
        expect(response.advice, isNotEmpty);
        expect(response.gifUrls, isEmpty);
      });

      test('should return fallback response for image analysis when API key is null', () async {
        final response = await aiService.getResponse('Test message', imagePath: 'test_image.jpg');
        
        expect(response.type, AIResponseType.tips);
        expect(response.advice, isNotEmpty);
        expect(response.gifUrls, isEmpty);
      });
    });

    group('analyzeFood', () {
      test('should return fallback food analysis when API key is null', () async {
        final response = await aiService.analyzeFood('test_food.jpg');
        
        expect(response.type, AIResponseType.macros);
        expect(response.advice, isNotEmpty);
        expect(response.macros, isNotNull);
        expect(response.macros!.kcal, greaterThan(0));
        expect(response.gifUrls, isEmpty);
      });
    });

    group('suggestRecipe', () {
      test('should return fallback recipe when API key is null', () async {
        final response = await aiService.suggestRecipe('test_fridge.jpg');
        
        expect(response.type, AIResponseType.general);
        expect(response.advice, isNotEmpty);
        expect(response.gifUrls, isEmpty);
      });
    });

    group('bodyCheck', () {
      test('should return fallback body check when API key is null', () async {
        final response = await aiService.bodyCheck('test_body.jpg');
        
        expect(response.type, AIResponseType.tips);
        expect(response.advice, isNotEmpty);
        expect(response.gifUrls, isEmpty);
      });
    });

    group('exerciseDetect', () {
      test('should return fallback exercise detection when API key is null', () async {
        final response = await aiService.exerciseDetect('test_exercise.jpg');
        
        expect(response.type, AIResponseType.tips);
        expect(response.advice, isNotEmpty);
        expect(response.gifUrls, isEmpty);
      });
    });

    group('generateProgram', () {
      test('should return fallback program when API key is null', () async {
        final user = UserModel(
          id: 'test_id',
          name: 'Test User',
          age: 25,
          height: 175,
          weight: 70,
          gender: 'm',
          goal: 'fitness',
        );
        
        final response = await aiService.generateProgram(user);
        
        expect(response.type, AIResponseType.program);
        expect(response.advice, isNotEmpty);
        expect(response.advice.split('\n').length, equals(28));
        expect(response.gifUrls, isEmpty);
      });

      test('should return fallback program with body image when API key is null', () async {
        final user = UserModel(
          id: 'test_id',
          name: 'Test User',
          age: 25,
          height: 175,
          weight: 70,
          gender: 'm',
          goal: 'fitness',
        );
        
        final response = await aiService.generateProgram(user, bodyImagePath: 'test_body.jpg');
        
        expect(response.type, AIResponseType.program);
        expect(response.advice, isNotEmpty);
        expect(response.advice.split('\n').length, equals(28));
        expect(response.gifUrls, isEmpty);
      });
    });

    group('analyzeVideo', () {
      test('should return fallback video analysis', () async {
        final response = await aiService.analyzeVideo(
          videoPath: 'test_video.mp4',
          exerciseName: 'squat',
        );
        
        expect(response.type, AIResponseType.posture);
        expect(response.advice, isNotEmpty);
        expect(response.advice.contains('•'), isTrue);
        expect(response.gifUrls, isEmpty);
      });
    });
  });
}
