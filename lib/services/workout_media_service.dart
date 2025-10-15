import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Сервис для работы с медиа упражнений с fallback системой
class WorkoutMediaService {
  static const String _exerciseDbBaseUrl = 'https://exercisedb.p.rapidapi.com';
  static const String _rapidApiKey = 'YOUR_RAPIDAPI_KEY'; // TODO: Заменить на реальный ключ
  
  // Флаг для отключения API при ошибках аутентификации
  static bool _apiDisabled = false;
  
  // Fallback данные для офлайн режима
  static final Map<String, ExerciseData> _fallbackExercises = {
    'barbell bench press': ExerciseData(
      name: 'Жим штанги лёжа',
      bodyPart: 'Грудь',
      target: 'Большая грудная мышца',
      equipment: 'Штанга',
      instructions: [
        'Лягте на скамью, возьмите штангу широким хватом',
        'Медленно опустите штангу к груди',
        'Мощно выжмите штангу вверх',
        'Не отрывайте ягодицы от скамьи'
      ],
      gifUrl: 'assets/gifs/bench_press.gif',
      imageUrl: 'assets/images/exercises/bench_press.jpg',
    ),
    'push up': ExerciseData(
      name: 'Отжимания от пола',
      bodyPart: 'Грудь',
      target: 'Большая грудная мышца',
      equipment: 'Собственный вес',
      instructions: [
        'Примите упор лёжа на прямых руках',
        'Опускайтесь до касания грудью пола',
        'Отжимайтесь, сохраняя прямую линию тела',
        'Не прогибайтесь в пояснице'
      ],
      gifUrl: 'assets/gifs/push_up.gif',
      imageUrl: 'assets/images/exercises/push_up.jpg',
    ),
    'barbell squat': ExerciseData(
      name: 'Приседания со штангой',
      bodyPart: 'Ноги',
      target: 'Квадрицепс',
      equipment: 'Штанга',
      instructions: [
        'Поставьте штангу на плечи, ноги на ширине плеч',
        'Медленно приседайте, отводя таз назад',
        'Опускайтесь до параллели бёдер с полом',
        'Мощно встаньте, толкаясь пятками'
      ],
      gifUrl: 'assets/gifs/squat.gif',
      imageUrl: 'assets/images/exercises/squat.jpg',
    ),
    'pull up': ExerciseData(
      name: 'Подтягивания',
      bodyPart: 'Спина',
      target: 'Широчайшие мышцы спины',
      equipment: 'Турник',
      instructions: [
        'Возьмитесь за турник прямым хватом',
        'Подтягивайтесь до касания подбородком перекладины',
        'Медленно опускайтесь в исходное положение',
        'Не раскачивайтесь и не используйте инерцию'
      ],
      gifUrl: 'assets/gifs/pull_up.gif',
      imageUrl: 'assets/images/exercises/pull_up.jpg',
    ),
    'deadlift': ExerciseData(
      name: 'Становая тяга',
      bodyPart: 'Спина',
      target: 'Выпрямители спины',
      equipment: 'Штанга',
      instructions: [
        'Встаньте над штангой, ноги на ширине плеч',
        'Согните колени и возьмите штангу',
        'Поднимайте штангу, разгибая ноги и спину одновременно',
        'Держите спину прямой на протяжении всего движения'
      ],
      gifUrl: 'assets/gifs/deadlift.gif',
      imageUrl: 'assets/images/exercises/deadlift.jpg',
    ),
  };

  /// Получить данные упражнения с fallback
  static Future<ExerciseData?> getExerciseData(String exerciseName) async {
    try {
      // Попытка получить данные из API
      final apiData = await _fetchFromApi(exerciseName);
      if (apiData != null) {
        return apiData;
      }
    } catch (e) {
      debugPrint('[Workout] API error for "$exerciseName": $e');
    }

    // Fallback на локальные данные
    final fallback = _fallbackExercises[exerciseName.toLowerCase()];
    if (fallback != null) {
      debugPrint('[Workout] Using fallback data for "$exerciseName"');
      return fallback;
    }

    // Создаём базовое упражнение если ничего не найдено
    debugPrint('[Workout] Creating basic exercise for "$exerciseName"');
    return ExerciseData(
      name: _formatExerciseName(exerciseName),
      bodyPart: 'Неизвестная группа мышц',
      target: 'Целевые мышцы',
      equipment: 'Оборудование',
      instructions: [
        'Следуйте правильной технике выполнения',
        'Контролируйте движение на всех фазах',
        'Не забывайте о правильном дыхании',
        'Увеличивайте нагрузку постепенно'
      ],
      gifUrl: 'assets/gifs/placeholder.gif',
      imageUrl: 'assets/images/exercises/placeholder.jpg',
    );
  }

  /// Попытка получить данные из ExerciseDB API
  static Future<ExerciseData?> _fetchFromApi(String exerciseName) async {
    // Пропускаем API если он отключен из-за ошибок аутентификации
    if (_apiDisabled || _rapidApiKey == 'YOUR_RAPIDAPI_KEY') {
      debugPrint('[Workout] API disabled or key not configured, using fallback');
      return null;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_exerciseDbBaseUrl/exercises/name/$exerciseName'),
        headers: {
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
          'X-RapidAPI-Key': _rapidApiKey,
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        if (data.isNotEmpty) {
          final exercise = data.first;
          return ExerciseData(
            name: exercise['name'] ?? exerciseName,
            bodyPart: exercise['bodyPart'] ?? 'Unknown',
            target: exercise['target'] ?? 'Unknown',
            equipment: exercise['equipment'] ?? 'Unknown',
            instructions: List<String>.from(exercise['instructions'] ?? []),
            gifUrl: exercise['gifUrl'],
            imageUrl: exercise['gifUrl'], // Используем gif как изображение
          );
        }
      } else if (response.statusCode == 403) {
        // Отключаем API при ошибках аутентификации
        _apiDisabled = true;
        debugPrint('[Workout] API subscription error, switching to fallback mode');
      }
    } catch (e) {
      debugPrint('[Workout] API request failed: $e');
    }
    return null;
  }

  /// Форматирование названия упражнения
  static String _formatExerciseName(String name) {
    return name
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Получить цвет для группы мышц
  static Color getBodyPartColor(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'грудь':
      case 'chest':
        return const Color(0xFF7C4DFF); // Фиолетовый
      case 'спина':
      case 'back':
        return const Color(0xFF00E5FF); // Голубой
      case 'ноги':
      case 'legs':
        return const Color(0xFF22C55E); // Зелёный
      case 'плечи':
      case 'shoulders':
        return const Color(0xFFF59E0B); // Янтарный
      case 'руки':
      case 'arms':
        return const Color(0xFFEF4444); // Красный
      default:
        return const Color(0xFF6B7280); // Серый
    }
  }

  /// Получить иконку для оборудования
  static IconData getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'штанга':
      case 'barbell':
        return Icons.fitness_center;
      case 'гантели':
      case 'dumbbell':
        return Icons.sports_gymnastics;
      case 'собственный вес':
      case 'body weight':
        return Icons.person;
      case 'турник':
      case 'cable':
        return Icons.sports_handball;
      default:
        return Icons.sports_gymnastics;
    }
  }

  /// Получить все упражнения для группы мышц
  static List<ExerciseData> getExercisesForBodyPart(String bodyPart) {
    return _fallbackExercises.values
        .where((exercise) => 
            exercise.bodyPart.toLowerCase().contains(bodyPart.toLowerCase()))
        .toList();
  }

  /// Предзагрузить данные популярных упражнений
  static Future<void> preloadPopularExercises() async {
    final popularExercises = [
      'barbell bench press',
      'push up',
      'barbell squat',
      'pull up',
      'deadlift',
      'overhead press',
      'dumbbell row',
      'plank',
    ];

    for (final exercise in popularExercises) {
      await getExerciseData(exercise);
    }
  }
}

/// Модель данных упражнения
class ExerciseData {
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;
  final List<String> instructions;
  final String? gifUrl;
  final String? imageUrl;

  const ExerciseData({
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    required this.instructions,
    this.gifUrl,
    this.imageUrl,
  });

  /// Получить форматированную строку с подходами и повторениями
  String getDefaultSetsReps() {
    switch (bodyPart.toLowerCase()) {
      case 'грудь':
      case 'спина':
        return '4 подхода × 8-12 повторений';
      case 'ноги':
        return '3 подхода × 12-15 повторений';
      case 'плечи':
      case 'руки':
        return '3 подхода × 10-12 повторений';
      default:
        return '3 подхода × 10 повторений';
    }
  }

  /// Получить рекомендуемый отдых между подходами
  String getRestTime() {
    switch (bodyPart.toLowerCase()) {
      case 'ноги':
      case 'спина':
        return '2-3 минуты';
      case 'грудь':
        return '1.5-2 минуты';
      default:
        return '1-1.5 минуты';
    }
  }

  /// Получить советы по технике
  List<String> getTechniqueTips() {
    return [
      'Выполняйте движение медленно и контролируемо',
      'Концентрируйтесь на работе целевых мышц',
      'Не задерживайте дыхание во время выполнения',
      'Используйте полную амплитуду движения',
      'Постепенно увеличивайте нагрузку',
    ];
  }

  @override
  String toString() => 'ExerciseData(name: $name, bodyPart: $bodyPart)';
}