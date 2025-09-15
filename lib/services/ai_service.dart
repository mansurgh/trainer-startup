import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/ai_response.dart';
import '../models/user_model.dart';
import 'error_service.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  String? get _apiKey {
    try {
      return dotenv.env['OPENAI_API_KEY'] ?? 'demo-key';
    } catch (e) {
      return 'demo-key';
    }
  }

  Future<AIResponse> getResponse(String text, {String? imagePath}) async {
    try {
      if (_apiKey == null || _apiKey == 'demo-key') {
        return _getFallbackResponse(text, imagePath);
      }

      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content': '''Ты персональный AI-тренер PulseFit Pro. Твоя задача - давать краткие, мотивирующие советы по фитнесу и питанию. 
          Отвечай на русском языке, будь дружелюбным и профессиональным. 
          Если пользователь задает вопрос о питании, давай конкретные рекомендации по продуктам и порциям.
          Если о тренировках - давай советы по технике и мотивации.'''
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
        return _getFallbackResponse(text, imagePath);
      }
    } catch (e, stackTrace) {
      ErrorService.logError(ErrorService.handleException(e, stackTrace));
      return _getFallbackResponse(text, imagePath);
    }
  }

  Future<AIResponse> analyzeFood(String imagePath) async {
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
  AIResponse _getFallbackResponse(String text, String? imagePath) {
    if (imagePath != null) {
      return AIResponse(
        type: AIResponseType.tips,
        advice: 'На фото вижу продукты. Совет: добавь больше белка к ужину.\n— Творог 200г\n— Яйца 3шт\n— Овсянка 80г',
        gifUrls: const [],
      );
    }
    return AIResponse(
      type: AIResponseType.general,
      advice: 'Держи краткий ответ-тренера: пей воду, разомнись 5 минут и фокус на технике.',
      gifUrls: const [],
    );
  }

  AIResponse _getFallbackFoodAnalysis() {
    return AIResponse(
      type: AIResponseType.macros,
      advice: 'Оценка еды: добавить источник белка и клетчатку.',
      macros: const MacroNutrients(kcal: 620, protein: 38, fat: 20, carbs: 72),
      gifUrls: const [],
    );
  }

  AIResponse _getFallbackRecipe() {
    return const AIResponse(
      type: AIResponseType.general,
      advice: 'Идея блюда: рис + курица + овощи-брокколи; соус йогурт-чеснок.',
      gifUrls: [],
    );
  }

  AIResponse _getFallbackBodyCheck() {
    return const AIResponse(
      type: AIResponseType.tips,
      advice: 'Осанка ок. Добавь упражнения на заднюю дельту и мобилку Т-спайна.',
      gifUrls: [],
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
}