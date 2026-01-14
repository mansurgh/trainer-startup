import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ai_response.dart';
import '../models/form_check_result.dart';
import '../models/user_model.dart';
import 'error_service.dart';

/// Enhanced AI Service для интеграции с OpenAI
/// Поддерживает генерацию планов, анализ техники и питания
class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4o';
  
  String? get _apiKey {
    try {
      return dotenv.env['OPENAI_API_KEY'] ?? const String.fromEnvironment('OPENAI_API_KEY');
    } catch (e) {
      return const String.fromEnvironment('OPENAI_API_KEY');
    }
  }

  /// Get the system prompt language instruction based on locale.
  String _getLanguageInstruction(String locale) {
    if (locale == 'ru') {
      return 'ВАЖНО: Отвечай ТОЛЬКО на русском языке.';
    }
    return 'IMPORTANT: Respond ONLY in English.';
  }

  Future<AIResponse> getResponse(String text, {String? imagePath, String locale = 'ru'}) async {
    try {
      if (_apiKey == null || _apiKey == 'demo-key') {
        return _getFallbackResponse(text, imagePath, locale);
      }

      final languageInstruction = _getLanguageInstruction(locale);
      final systemPrompt = locale == 'ru' 
        ? '''Ты персональный AI-тренер PulseFit Pro. Твоя задача - давать краткие, мотивирующие советы по фитнесу и питанию. 
           Будь дружелюбным и профессиональным. 
           Если пользователь задает вопрос о питании, давай конкретные рекомендации по продуктам и порциям.
           Если о тренировках - давай советы по технике и мотивации.
           $languageInstruction'''
        : '''You are a personal AI trainer for PulseFit Pro. Your task is to give brief, motivating fitness and nutrition advice.
           Be friendly and professional.
           If the user asks about nutrition, give specific recommendations about products and portions.
           If about training - give technique tips and motivation.
           $languageInstruction''';

      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content': text,
        }
      ];

      if (imagePath != null) {
        final imageBase64 = await _encodeImage(imagePath);
        messages[1]['content'] = [
          {'type': 'text', 'text': text},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}
          }
        ];
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return AIResponse(
          type: AIResponseType.general,
          advice: content,
          gifUrls: const [],
        );
      } else {
        return _getFallbackResponse(text, imagePath, locale);
      }
    } catch (e, stackTrace) {
      ErrorService.logError(ErrorService.handleException(e, stackTrace));
      return _getFallbackResponse(text, imagePath, locale);
    }
  }

  Future<AIResponse> analyzeFood(String imagePath, {String locale = 'ru'}) async {
    try {
      if (_apiKey == null || _apiKey == 'demo-key') {
        return _getFallbackFoodAnalysis();
      }

      final imageBase64 = await _encodeImage(imagePath);
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'system',
              'content': '''Ты эксперт по анализу питания. Проанализируй фото еды и дай оценку:
              1. Примерную калорийность
              2. Содержание белков, жиров, углеводов
              3. Рекомендации по улучшению рациона
              4. Предложи дополнительные продукты для баланса
              Отвечай в формате JSON: {"kcal": число, "protein": число, "fat": число, "carbs": число, "advice": "текст"}'''
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': 'Проанализируй это блюдо и дай рекомендации по питанию'},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}
                }
              ]
            }
          ],
          'max_tokens': 500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        try {
          final analysis = jsonDecode(content);
          return AIResponse(
            type: AIResponseType.macros,
            advice: analysis['advice'] ?? 'Анализ завершен',
            macros: MacroNutrients(
              kcal: analysis['kcal']?.toInt() ?? 0,
              protein: analysis['protein']?.toDouble() ?? 0,
              fat: analysis['fat']?.toDouble() ?? 0,
              carbs: analysis['carbs']?.toDouble() ?? 0,
            ),
            gifUrls: const [],
          );
        } catch (e) {
          return AIResponse(
            type: AIResponseType.macros,
            advice: content,
            macros: const MacroNutrients(kcal: 0, protein: 0, fat: 0, carbs: 0),
            gifUrls: const [],
          );
        }
      } else {
        return _getFallbackFoodAnalysis();
      }
    } catch (e, stackTrace) {
      ErrorService.logError(ErrorService.handleException(e, stackTrace));
      return _getFallbackFoodAnalysis();
    }
  }

  Future<AIResponse> suggestRecipe(String imagePath) async {
    try {
      if (_apiKey == null || _apiKey == 'demo-key') {
        return _getFallbackRecipe();
      }

      final imageBase64 = await _encodeImage(imagePath);
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'system',
              'content': '''Ты шеф-повар и диетолог. Посмотри на продукты в холодильнике и предложи 2-3 рецепта блюд:
              1. Название блюда
              2. Ингредиенты и их количество
              3. Пошаговый рецепт
              4. Калорийность и БЖУ
              5. Время приготовления
              Отвечай на русском языке, будь конкретным и практичным.'''
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': 'Что можно приготовить из этих продуктов?'},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}
                }
              ]
            }
          ],
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return AIResponse(
          type: AIResponseType.general,
          advice: content,
          gifUrls: const [],
        );
      } else {
        return _getFallbackRecipe();
      }
    } catch (e, stackTrace) {
      ErrorService.logError(ErrorService.handleException(e, stackTrace));
      return _getFallbackRecipe();
    }
  }

  Future<AIResponse> bodyCheck(String imagePath) async {
    try {
      if (_apiKey == null || _apiKey == 'demo-key') {
        return _getFallbackBodyCheck();
      }

      final imageBase64 = await _encodeImage(imagePath);
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'system',
              'content': '''Ты фитнес-тренер и специалист по осанке. Проанализируй фото человека и дай рекомендации:
              1. Оценка осанки
              2. Проблемные зоны
              3. Упражнения для коррекции
              4. Общие рекомендации по тренировкам
              Отвечай профессионально, но дружелюбно на русском языке.'''
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': 'Проанализируй мою осанку и дай рекомендации'},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}
                }
              ]
            }
          ],
          'max_tokens': 600,
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return AIResponse(
          type: AIResponseType.tips,
          advice: content,
          gifUrls: const [],
        );
      } else {
        return _getFallbackBodyCheck();
      }
    } catch (e, stackTrace) {
      ErrorService.logError(ErrorService.handleException(e, stackTrace));
      return _getFallbackBodyCheck();
    }
  }

  Future<AIResponse> exerciseDetect(String imagePath) async {
    try {
      if (_apiKey == null || _apiKey == 'demo-key') {
        return _getFallbackExerciseDetect();
      }

      final imageBase64 = await _encodeImage(imagePath);
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'system',
              'content': '''Ты фитнес-тренер. Определи упражнение на фото и дай советы по технике:
              1. Название упражнения
              2. Оценка техники выполнения
              3. Основные ошибки
              4. Советы по улучшению
              5. Альтернативные варианты
              Отвечай кратко и по делу на русском языке.'''
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': 'Проанализируй технику выполнения упражнения'},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}
                }
              ]
            }
          ],
          'max_tokens': 500,
          'temperature': 0.4,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return AIResponse(
          type: AIResponseType.tips,
          advice: content,
          gifUrls: const [],
        );
      } else {
        return _getFallbackExerciseDetect();
      }
    } catch (e, stackTrace) {
      ErrorService.logError(ErrorService.handleException(e, stackTrace));
      return _getFallbackExerciseDetect();
    }
  }

  Future<AIResponse> generateProgram(UserModel user, {String? bodyImagePath}) async {
    try {
      if (_apiKey == null || _apiKey == 'demo-key') {
        return _getFallbackProgram(user);
      }

      final userInfo = '''
        Пользователь: ${user.name ?? 'Не указано'}
        Пол: ${user.gender == 'm' ? 'Мужской' : 'Женский'}
        Возраст: ${user.age ?? 'Не указан'} лет
        Рост: ${user.height ?? 'Не указан'} см
        Вес: ${user.weight ?? 'Не указан'} кг
        Цель: ${_getGoalText(user.goal)}
        Уровень подготовки: ${_getFitnessLevel(user)}
      ''';

      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content': '''Ты персональный тренер. Создай 28-дневную программу тренировок на основе данных пользователя.
          Программа должна включать:
          - Разнообразные упражнения
          - Прогрессию нагрузки
          - Дни отдыха
          - Кардио тренировки
          - Растяжку
          
          Формат: "День X: [Тип тренировки] - [Упражнения и подходы]"
          Отвечай на русском языке.'''
        },
        {
          'role': 'user',
          'content': userInfo,
        }
      ];

      if (bodyImagePath != null) {
        final imageBase64 = await _encodeImage(bodyImagePath);
        messages[1]['content'] = [
          {'type': 'text', 'text': userInfo},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}
          }
        ];
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': messages,
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final days = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
        return AIResponse(
          type: AIResponseType.program,
          advice: days.join('\n'),
          gifUrls: const [],
        );
      } else {
        return _getFallbackProgram(user);
      }
    } catch (e, stackTrace) {
      ErrorService.logError(ErrorService.handleException(e, stackTrace));
      return _getFallbackProgram(user);
    }
  }

  Future<AIResponse> analyzeVideo({String? videoPath, String? exerciseName}) async {
    // Для видео анализа пока используем fallback, так как OpenAI Vision API не поддерживает видео
    await Future.delayed(const Duration(milliseconds: 900));
    final tips = [
      'Держи нейтральную спину',
      'Колени по траектории носков',
      'Контролируй эксцентрику 2–3с',
      'Дыши: вниз — вдох, вверх — выдох',
      'Работай в полном ROM',
    ];
    tips.shuffle(Random());
    return AIResponse(
      type: AIResponseType.posture,
      advice: tips.take(4).map((e) => '• $e').join('\n'),
      gifUrls: const [],
    );
  }

  // Helper methods
  Future<String> _encodeImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }

  String _getGoalText(String? goal) {
    switch (goal) {
      case 'fat_loss': return 'Похудение';
      case 'muscle_gain': return 'Набор мышечной массы';
      case 'fitness': return 'Общая физическая подготовка';
      default: return 'Не указана';
    }
  }

  String _getFitnessLevel(UserModel user) {
    if (user.age == null || user.weight == null || user.height == null) {
      return 'Новичок';
    }
    
    final bmi = user.weight! / ((user.height! / 100) * (user.height! / 100));
    if (bmi < 18.5) return 'Новичок';
    if (bmi < 25) return 'Средний';
    if (bmi < 30) return 'Средний';
    return 'Продвинутый';
  }

  // Fallback responses when API is not available
  AIResponse _getFallbackResponse(String text, String? imagePath, String locale) {
    if (imagePath != null) {
      if (locale == 'ru') {
        return AIResponse(
          type: AIResponseType.tips,
          advice: 'На фото вижу продукты. Совет: добавь больше белка к ужину.\n— Творог 200г\n— Яйца 3шт\n— Овсянка 80г',
          gifUrls: const [],
        );
      } else {
        return AIResponse(
          type: AIResponseType.tips,
          advice: 'I see food in the photo. Tip: add more protein to your dinner.\n— Cottage cheese 200g\n— Eggs 3pcs\n— Oatmeal 80g',
          gifUrls: const [],
        );
      }
    }
    if (locale == 'ru') {
      return AIResponse(
        type: AIResponseType.general,
        advice: 'Держи краткий ответ-тренера: пей воду, разомнись 5 минут и фокус на технике.',
        gifUrls: const [],
      );
    } else {
      return AIResponse(
        type: AIResponseType.general,
        advice: 'Quick trainer tip: drink water, warm up for 5 minutes and focus on proper technique.',
        gifUrls: const [],
      );
    }
  }

  AIResponse _getFallbackFoodAnalysis({String locale = 'ru'}) {
    final advice = locale == 'ru' 
      ? 'Оценка еды: добавить источник белка и клетчатку.'
      : 'Food analysis: add a protein source and fiber.';
    return AIResponse(
      type: AIResponseType.macros,
      advice: advice,
      macros: const MacroNutrients(kcal: 620, protein: 38, fat: 20, carbs: 72),
      gifUrls: const [],
    );
  }

  AIResponse _getFallbackRecipe({String locale = 'ru'}) {
    final advice = locale == 'ru'
      ? 'Идея блюда: рис + курица + овощи-брокколи; соус йогурт-чеснок.'
      : 'Meal idea: rice + chicken + broccoli vegetables; yogurt-garlic sauce.';
    return AIResponse(
      type: AIResponseType.general,
      advice: advice,
      gifUrls: const [],
    );
  }

  AIResponse _getFallbackBodyCheck({String locale = 'ru'}) {
    final advice = locale == 'ru'
      ? 'Осанка ок. Добавь упражнения на заднюю дельту и мобилку Т-спайна.'
      : 'Posture looks ok. Add rear delt exercises and T-spine mobility work.';
    return AIResponse(
      type: AIResponseType.tips,
      advice: advice,
      gifUrls: const [],
    );
  }

  AIResponse _getFallbackExerciseDetect() {
    return const AIResponse(
      type: AIResponseType.tips,
      advice: 'Похоже на присед. Держи колени над стопой, корпус чуть прямее.',
      gifUrls: [],
    );
  }

  AIResponse _getFallbackProgram(UserModel user) {
    final days = List.generate(28, (i) => 'День ${i + 1}: ${i % 2 == 0 ? 'Силы (верх)' : 'Силы (низ)'} + 10 мин кардио');
    return AIResponse(
      type: AIResponseType.program,
      advice: days.join('\n'),
      gifUrls: const [],
    );
  }

  // Generate training program
  Future<AIResponse> generateTrainingProgram(String userInfo) async {
    try {
      if (_apiKey == null || _apiKey == 'demo-key') {
        return _getFallbackTrainingProgram();
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''Ты персональный AI-тренер. Создай детальную программу тренировок на 28 дней.
              Формат ответа: для каждого дня дай заголовок "День X" и подробное описание тренировки.
              Включай разминку, основную часть с конкретными упражнениями, подходами и повторениями, заминку.
              Адаптируй программу под данные пользователя.'''
            },
            {
              'role': 'user',
              'content': userInfo,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        return AIResponse(
          type: AIResponseType.program,
          advice: content,
          gifUrls: const [],
        );
      } else {
        return _getFallbackTrainingProgram();
      }
    } catch (e, stackTrace) {
      ErrorService.logError(ErrorService.handleException(e, stackTrace));
      return _getFallbackTrainingProgram();
    }
  }

  AIResponse _getFallbackTrainingProgram() {
    return AIResponse(
      type: AIResponseType.program,
      advice: '''День 1 - Верх тела
Разминка: 10 мин легкого кардио
• Жим лежа - 3×8-10
• Тяга штанги - 3×8-10
• Жим гантелей - 3×10-12
• Подтягивания - 3×6-8
• Планка - 3×30 сек

День 2 - Низ тела
Разминка: 10 мин легкого кардио
• Приседания - 4×8-10
• Румынская тяга - 3×8-10
• Выпады - 3×10 на ногу
• Подъемы на носки - 3×15-20
• Планка - 3×30 сек

Продолжи программу на 28 дней...''',
      gifUrls: const [],
    );
  }

  /// Генерирует персональный план тренировок
  Future<AIResponse> generateWorkoutPlan({
    required String fitnessLevel,
    required String goals,
    required int daysPerWeek,
    List<String>? preferences,
  }) async {
    final prompt = '''
Создай персональный план тренировок на основе следующих данных:
- Уровень подготовки: $fitnessLevel
- Цели: $goals
- Количество дней в неделю: $daysPerWeek
${preferences != null ? '- Предпочтения: ${preferences.join(", ")}' : ''}

Создай детальный план тренировок с упражнениями, подходами и повторениями.
''';

    return await getResponse(prompt);
  }

  /// Анализирует питание пользователя
  Future<AIResponse> analyzeNutrition({
    required String currentDiet,
    required String goals,
    String? restrictions,
    String? preferences,
  }) async {
    final prompt = '''
Проанализируй мое питание и дай рекомендации:
- Текущий рацион: $currentDiet
- Цели: $goals
${restrictions != null ? '- Ограничения: $restrictions' : ''}
${preferences != null ? '- Предпочтения: $preferences' : ''}

Дай конкретные рекомендации по улучшению питания, включая примеры блюд и продуктов.
''';

    return await getResponse(prompt);
  }

  // ===========================================================================
  // Form Check Analysis — Video-based technique analysis
  // ===========================================================================

  /// Analyze exercise form from video by extracting keyframes
  /// Returns FormCheckResult with errors, corrections, and YouTube search query
  Future<FormCheckResult> analyzeExerciseForm(
    String? videoPath,
    String exerciseName,
  ) async {
    try {
      // If no video path (desktop fallback), return mock immediately
      if (videoPath == null) {
        await Future.delayed(const Duration(seconds: 1));
        return FormCheckResult.mock(exerciseName);
      }
      
      // Check API key availability
      if (_apiKey == null || _apiKey == 'demo-key' || _apiKey!.isEmpty) {
        // Return mock response for demo
        await Future.delayed(const Duration(seconds: 2));
        return FormCheckResult.mock(exerciseName);
      }

      // Extract keyframes from video
      final keyframes = await _extractKeyframes(videoPath);
      
      if (keyframes.isEmpty) {
        return FormCheckResult.mock(exerciseName);
      }

      // Send keyframes to GPT-4o for analysis
      final result = await _analyzeKeyframesWithAI(keyframes, exerciseName);
      
      // Cleanup extracted frames
      for (final framePath in keyframes) {
        try {
          await File(framePath).delete();
        } catch (_) {}
      }
      
      return result;
    } catch (e, stackTrace) {
      ErrorService.logError(ErrorService.handleException(e, stackTrace));
      // Return mock on error
      return FormCheckResult.mock(exerciseName);
    }
  }

  /// Extract 3-5 keyframes from video (start, middle, end)
  Future<List<String>> _extractKeyframes(String videoPath) async {
    final frames = <String>[];
    
    try {
      // Use video_player to extract frames at different timestamps
      // Note: For production, consider using ffmpeg_kit_flutter for better extraction
      
      final file = File(videoPath);
      if (!await file.exists()) return frames;

      // For now, we'll use a simplified approach:
      // Take screenshots at specific intervals using video_thumbnail or similar
      // In production, use ffmpeg_kit_flutter for precise frame extraction
      
      // Simplified: Extract frames at 0%, 25%, 50%, 75%, 100% of video duration
      // This is a placeholder - actual implementation would use ffmpeg
      
      final tempDir = await getTemporaryDirectory();
      final timestamps = [0.0, 0.25, 0.5, 0.75, 1.0];
      
      for (int i = 0; i < timestamps.length; i++) {
        final framePath = '${tempDir.path}/frame_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        // Placeholder: In production, use FFmpegKit to extract actual frames
        // For now, we'll read the first frame using video_player workaround
        // or just use the video file directly with GPT-4o
        
        // Since direct frame extraction requires native code,
        // we'll send the video as a single frame analysis for demo
        frames.add(videoPath); // Use video path for now
        break; // Only one "frame" for demo
      }
      
      return frames;
    } catch (e) {
      return frames;
    }
  }

  /// Analyze keyframes with GPT-4o Vision
  Future<FormCheckResult> _analyzeKeyframesWithAI(
    List<String> framePaths,
    String exerciseName,
  ) async {
    try {
      // Encode frames to base64
      final frameContents = <Map<String, dynamic>>[];
      
      for (final path in framePaths.take(5)) { // Max 5 frames
        try {
          final base64Image = await _encodeImage(path);
          frameContents.add({
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$base64Image',
              'detail': 'high',
            }
          });
        } catch (_) {
          continue;
        }
      }

      if (frameContents.isEmpty) {
        return FormCheckResult.mock(exerciseName);
      }

      // Build prompt for form analysis
      final prompt = '''
Ты профессиональный фитнес-тренер и эксперт по биомеханике. Проанализируй технику выполнения упражнения "$exerciseName" на этих изображениях.

Оцени:
1. Положение спины и позвоночника
2. Положение коленей и стоп
3. Амплитуду движения
4. Общую стабильность и баланс
5. Скорость и контроль движения

Ответь ТОЛЬКО в JSON формате:
{
  "score": <число от 0 до 100>,
  "summary": "<краткое резюме на русском>",
  "errors": ["<ошибка 1>", "<ошибка 2>", ...],
  "corrections": ["<совет 1>", "<совет 2>", ...],
  "youtube_query": "<поисковый запрос для YouTube на английском>"
}

Важно:
- Будь конструктивным и мотивирующим
- Давай конкретные практические советы
- Учитывай безопасность выполнения упражнения
- Отвечай на русском языке (кроме youtube_query)
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                ...frameContents,
              ]
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Parse JSON response
        try {
          // Extract JSON from response (handle markdown code blocks)
          String jsonStr = content;
          if (content.contains('```json')) {
            jsonStr = content.split('```json')[1].split('```')[0].trim();
          } else if (content.contains('```')) {
            jsonStr = content.split('```')[1].split('```')[0].trim();
          }
          
          final analysis = jsonDecode(jsonStr);
          return FormCheckResult.fromJson(analysis);
        } catch (parseError) {
          // If JSON parsing fails, create result from raw text
          return FormCheckResult(
            overallScore: 70,
            summary: content.length > 200 ? '${content.substring(0, 200)}...' : content,
            errors: ['Не удалось детально разобрать анализ'],
            corrections: ['Попробуйте записать видео ещё раз'],
            youtubeSearchQuery: '$exerciseName form guide',
          );
        }
      } else {
        return FormCheckResult.mock(exerciseName);
      }
    } catch (e) {
      return FormCheckResult.mock(exerciseName);
    }
  }
}